import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Equipment/Controllers/search_tagged_equipment_controller.dart';
import 'package:midas/Equipment/Models/tagged_equipment_model.dart';
import 'package:midas/Equipment/Views/search_tagged_equipment_view.dart';
import 'package:midas/Equipment/equipment_repository.dart';
import 'package:midas/SearchAsset/Models/gps_data_model.dart';
import 'package:midas/Shared/Services/location_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_loading_dialog.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchEquipmentFindController extends GetxController {
  SearchEquipmentFindController({
    required this.equipmentRepository,
    required this.rfidService,
    required this.locationService,
  });

  final EquipmentRepository equipmentRepository;
  final RfidService rfidService;
  final LocationService locationService;

  final equipmentController = TextEditingController();

  final selectedEquipment = Rxn<TaggedEquipmentModel>();
  final isScanning = false.obs;
  final isStarting = false.obs;
  final isStopping = false.obs;
  final isRfidConnected = false.obs;

  final List<GpsDataModel> _gpsReadings = [];
  StreamSubscription<String>? _tagSubscription;

  bool get canStart =>
      selectedEquipment.value != null &&
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

  Future<void> openEquipmentLookup() async {
    if (isScanning.value || isStopping.value) {
      Get.snackbar(
        AppStrings.searchEquipment,
        AppStrings.stopTrackingBeforeChangingEquipment,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to<TaggedEquipmentModel>(
      () => const SearchTaggedEquipmentView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SearchTaggedEquipmentController(
            equipmentRepository: Get.find<EquipmentRepository>(),
          ),
        );
      }),
    );
    if (result == null) return;

    selectedEquipment.value = result;
    equipmentController.text = result.displayLabel;
    _gpsReadings.clear();
  }

  Future<void> start() async {
    if (selectedEquipment.value == null ||
        isScanning.value ||
        isStopping.value) {
      return;
    }

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
      await showAppMessageDialog(AppStrings.unableToStartEquipmentTracking);
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> stop() async {
    if (!isScanning.value || isStopping.value) return;

    isStopping.value = true;
    isScanning.value = false;
    await rfidService.stopInventory();

    if (_gpsReadings.isNotEmpty) {
      Get.snackbar(
        AppStrings.searchEquipment,
        AppStrings.uploadingDataToServer,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      showAppLoadingDialog();
      try {
        final response = await equipmentRepository.insertGpsData(_gpsReadings);
        hideAppLoadingDialog();
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : response.succeeded
                  ? AppStrings.trackingDataSavedSuccessfully
                  : AppStrings.unableToSaveTrackingData,
        );
      } on DioException catch (e) {
        hideAppLoadingDialog();
        final data = e.response?.data;
        await showAppMessageDialog(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : AppStrings.unableToSaveTrackingDataRetry,
        );
      } catch (_) {
        hideAppLoadingDialog();
        await showAppMessageDialog(AppStrings.unableToSaveTrackingDataRetry);
      }
    } else {
      await showAppMessageDialog(AppStrings.noEquipmentTrackingDataScanned);
    }

    _resetAfterStop();
  }

  void _resetAfterStop() {
    _gpsReadings.clear();
    selectedEquipment.value = null;
    equipmentController.clear();
    isStopping.value = false;
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
    equipmentController.dispose();
    super.onClose();
  }
}
