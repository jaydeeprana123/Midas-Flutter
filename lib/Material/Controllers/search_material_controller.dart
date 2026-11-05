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

  /// Markers drawn from [_gpsReadings]. One entry per RFID tag.
  ///
  /// This list is not cleared when Stop saves and then clears
  /// [_gpsReadings], so the pins stay on the map after scanning ends.
  /// A new Start, or choosing another material, clears it.
  final scanMarkers = <GpsDataModel>[].obs;

  /// Labels for marker taps. Filled only from the selected material and
  /// local sample pins. No extra request is made for the map.
  final List<_MapMaterialLabel> _markerLabels = [];

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
    // _seedDummyMapReadings();
  }

  /// Temporary sample pins so the map can be checked before a live RFID scan.
  /// Start still clears [_gpsReadings] before a real session, so these are
  /// not saved by Stop.
  void _seedDummyMapReadings() {
    const samples =
        <
          ({
            String name,
            String code,
            String tag,
            double latitude,
            double longitude,
          })
        >[
          (
            name: 'Sample Cement',
            code: 'MAT-DEMO-01',
            tag: 'TAG-MAT-DEMO-01',
            latitude: 28.6139,
            longitude: 77.2090,
          ),
          (
            name: 'Sample Steel Rod',
            code: 'MAT-DEMO-02',
            tag: 'TAG-MAT-DEMO-02',
            latitude: 28.6289,
            longitude: 77.2195,
          ),
        ];

    for (final sample in samples) {
      final alreadyStored = _gpsReadings.any(
        (item) => item.rfidNumber == sample.tag,
      );
      if (!alreadyStored) {
        _gpsReadings.add(
          GpsDataModel(
            rfidNumber: sample.tag,
            latitude: sample.latitude,
            longitude: sample.longitude,
            timestamp: LocationService.deviceTimestamp(),
            isHandHeld: true,
          ),
        );
      }

      final alreadyLabeled = _markerLabels.any(
        (material) =>
            material.rfid == sample.tag || material.tagCode == sample.tag,
      );
      if (!alreadyLabeled) {
        _markerLabels.add(
          _MapMaterialLabel(
            materialName: sample.name,
            materialCode: sample.code,
            tagCode: sample.tag,
            rfid: sample.tag,
          ),
        );
      }

      _publishScanMarker(
        _gpsReadings.firstWhere((item) => item.rfidNumber == sample.tag),
      );
    }
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
          ),
        );
      }),
    );
    if (result == null) return;

    selectedMaterial.value = result;
    materialController.text = result.trackingLabel;
    _gpsReadings.clear();
    _markerLabels.clear();
    scanMarkers.clear();
    // _seedDummyMapReadings();
  }

  /// Upload API is not available yet — only starts RFID inventory.
  Future<void> start() async {
    final material = selectedMaterial.value;
    if (material == null || isScanning.value || isStopping.value) return;

    isStarting.value = true;
    try {
      _gpsReadings.clear();
      scanMarkers.clear();
      _markerLabels.clear();

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
        await showAppMessageDialog(
          AppStrings.materialTrackingSavedForFutureSync,
        );
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

    final selectedRfid = selectedMaterial.value?.rfid?.trim() ?? '';
    if (selectedRfid.isEmpty) return;
    if (tag.toUpperCase() != selectedRfid.toUpperCase()) return;

    await locationService.refresh();
    await rfidService.beep(success: true);

    final reading = GpsDataModel(
      rfidNumber: tag,
      latitude: locationService.latitude,
      longitude: locationService.longitude,
      timestamp: LocationService.deviceTimestamp(),
      isHandHeld: true,
    );

    final existingIndex = _gpsReadings.indexWhere(
      (item) => item.rfidNumber == tag,
    );
    if (existingIndex >= 0) {
      _gpsReadings[existingIndex] = _gpsReadings[existingIndex].copyWith(
        latitude: reading.latitude,
        longitude: reading.longitude,
        timestamp: reading.timestamp,
      );
    } else {
      _gpsReadings.add(reading);
    }

    // Duplicate tags stay a single marker: the pin moves to the latest valid
    // fix. An invalid fix does not add a pin and does not move one that
    // already has a valid position. The reading itself still stays in
    // [_gpsReadings] for the existing Stop save.
    final stored = existingIndex >= 0 ? _gpsReadings[existingIndex] : reading;
    _publishScanMarker(stored);
  }

  /// Name, code, and tag shown when a marker is tapped.
  ///
  /// Matched against local sample labels, then the selected material.
  /// The scanned RFID is always shown as the tag when nothing else matches.
  MaterialScanMarkerDetails detailsFor(String rfidNumber) {
    final tag = rfidNumber.trim();
    final needle = tag.toLowerCase();

    for (final material in _markerLabels) {
      final rfid = material.rfid.toLowerCase();
      final tagCode = material.tagCode.toLowerCase();
      final matchesRfid = rfid.isNotEmpty && rfid == needle;
      final matchesTag = tagCode.isNotEmpty && tagCode == needle;
      if (matchesRfid || matchesTag) {
        return MaterialScanMarkerDetails(
          materialName: material.materialName,
          materialCode: material.materialCode,
          tagCode: material.tagCode.isNotEmpty ? material.tagCode : tag,
        );
      }
    }

    final selected = selectedMaterial.value;
    if (selected != null) {
      final rfid = (selected.rfid ?? '').trim().toLowerCase();
      final tagCode = selected.tagCode.trim().toLowerCase();
      final matchesRfid = rfid.isNotEmpty && rfid == needle;
      final matchesTag = tagCode.isNotEmpty && tagCode == needle;
      if (matchesRfid || matchesTag) {
        return MaterialScanMarkerDetails(
          materialName: selected.materialName,
          materialCode: selected.materialCode,
          tagCode: selected.tagCode.isNotEmpty ? selected.tagCode : tag,
        );
      }
    }

    return MaterialScanMarkerDetails(
      materialName: '',
      materialCode: '',
      tagCode: tag,
    );
  }

  void _publishScanMarker(GpsDataModel reading) {
    if (!reading.hasMappableLocation) return;

    final index = scanMarkers.indexWhere(
      (item) => item.rfidNumber == reading.rfidNumber,
    );
    if (index >= 0) {
      scanMarkers[index] = reading;
    } else {
      scanMarkers.add(reading);
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

class MaterialScanMarkerDetails {
  const MaterialScanMarkerDetails({
    required this.materialName,
    required this.materialCode,
    required this.tagCode,
  });

  final String materialName;
  final String materialCode;
  final String tagCode;
}

class _MapMaterialLabel {
  const _MapMaterialLabel({
    required this.materialName,
    required this.materialCode,
    required this.tagCode,
    required this.rfid,
  });

  final String materialName;
  final String materialCode;
  final String tagCode;
  final String rfid;
}
