import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/search_material_lookup_controller.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/pending_material_gps_batch_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/Views/search_material_lookup_view.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/SearchAsset/Models/gps_data_model.dart';
import 'package:midas/Shared/Services/location_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchMaterialController extends GetxController {
  SearchMaterialController({
    required this.rfidService,
    required this.locationService,
    required this.sqliteService,
    required this.connectivityService,
  });

  final RfidService rfidService;
  final LocationService locationService;
  final MaterialSqliteService sqliteService;
  final NetworkConnectivityService connectivityService;

  final materialController = TextEditingController();

  final selectedMaterial = Rxn<MaterialTaggingDetailModel>();
  final isScanning = false.obs;
  final isStarting = false.obs;
  final isStopping = false.obs;
  final isRfidConnected = false.obs;

  final List<GpsDataModel> _gpsReadings = [];
  StreamSubscription<String>? _tagSubscription;

  bool get canStart =>
      selectedMaterial.value != null &&
      !isScanning.value &&
      !isStopping.value &&
      !isStarting.value;

  bool get canStop => isScanning.value && !isStopping.value;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
    locationService.startTracking();
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  Future<void> openMaterialLookup() async {
    if (isScanning.value || isStopping.value) {
      Get.snackbar(
        AppStrings.searchMaterial,
        AppStrings.stopTrackingBeforeChangingMaterial,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to<MaterialTaggingDetailModel>(
      () => const SearchMaterialLookupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SearchMaterialLookupController(
            materialRepository: Get.find<MaterialRepository>(),
            sqliteService: Get.find<MaterialSqliteService>(),
            connectivityService: Get.find<NetworkConnectivityService>(),
          ),
        );
      }),
    );
    if (result == null) return;

    selectedMaterial.value = result;
    materialController.text = result.trackingLabel;
    _gpsReadings.clear();
  }

  /// Upload API is not available yet — only starts RFID inventory.
  Future<void> start() async {
    final material = selectedMaterial.value;
    if (material == null || isScanning.value || isStopping.value) return;

    isStarting.value = true;
    try {
      _gpsReadings.clear();

      final started = await rfidService.startInventory();
      if (!started) {
        Get.snackbar(
          AppStrings.scanFailed,
          AppStrings.rfidReaderUnavailable,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isScanning.value = true;
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToStartMaterialTrackingRetry);
    } finally {
      isStarting.value = false;
    }
  }

  /// Upload API is not available yet — stops RFID and persists offline batches.
  Future<void> stop() async {
    if (!isScanning.value || isStopping.value) return;

    isStopping.value = true;
    isScanning.value = false;
    await rfidService.stopInventory();

    try {
      if (_gpsReadings.isEmpty) {
        await showAppMessageDialog(AppStrings.noTrackingDataScanned);
        return;
      }

      final online = await connectivityService.refresh();
      if (!online) {
        await sqliteService.insertPendingGpsBatch(
          PendingMaterialGpsBatchModel(
            readings: List<GpsDataModel>.from(_gpsReadings),
            materialTagCode: selectedMaterial.value?.tagCode,
          ),
        );
        await showAppMessageDialog(AppStrings.materialTrackingSavedOffline);
      } else {
        // Upload API not ready — keep readings locally for future sync.
        await sqliteService.insertPendingGpsBatch(
          PendingMaterialGpsBatchModel(
            readings: List<GpsDataModel>.from(_gpsReadings),
            materialTagCode: selectedMaterial.value?.tagCode,
          ),
        );
        await showAppMessageDialog(AppStrings.materialTrackingSavedForFutureSync);
      }
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToSaveTrackingDataRetry);
    } finally {
      _gpsReadings.clear();
      isStopping.value = false;
    }
  }

  Future<void> _onTagRead(String epc) async {
    if (!isScanning.value) return;
    final tag = epc.trim();
    if (tag.isEmpty) return;

    await locationService.refresh();
    await rfidService.beep(success: true);

    final reading = GpsDataModel(
      rfidNumber: tag,
      latitude: locationService.latitude,
      longitude: locationService.longitude,
      timestamp: LocationService.deviceTimestamp(),
      isHandHeld: true,
    );

    final existingIndex =
        _gpsReadings.indexWhere((item) => item.rfidNumber == tag);
    if (existingIndex >= 0) {
      _gpsReadings[existingIndex] = _gpsReadings[existingIndex].copyWith(
        latitude: reading.latitude,
        longitude: reading.longitude,
        timestamp: reading.timestamp,
      );
    } else {
      _gpsReadings.add(reading);
    }
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.stopInventory();
    rfidService.disconnect();
    locationService.stopTracking();
    materialController.dispose();
    super.onClose();
  }
}
