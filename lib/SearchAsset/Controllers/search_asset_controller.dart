import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/SearchAsset/Controllers/search_asset_lookup_controller.dart';
import 'package:midas/SearchAsset/Views/search_asset_lookup_view.dart';
import 'package:midas/SearchAsset/Models/dashboard_search_asset_model.dart';
import 'package:midas/SearchAsset/Models/gps_data_model.dart';
import 'package:midas/SearchAsset/Models/search_asset_item_model.dart';
import 'package:midas/SearchAsset/search_asset_repository.dart';
import 'package:midas/Shared/Services/location_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_loading_dialog.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchAssetController extends GetxController {
  SearchAssetController({
    required this.searchAssetRepository,
    required this.rfidService,
    required this.locationService,
  });

  final SearchAssetRepository searchAssetRepository;
  final RfidService rfidService;
  final LocationService locationService;

  final assetController = TextEditingController();

  final selectedAsset = Rxn<SearchAssetItemModel>();
  final isScanning = false.obs;
  final isStarting = false.obs;
  final isStopping = false.obs;
  final isRfidConnected = false.obs;

  final List<GpsDataModel> _gpsReadings = [];

  /// Markers drawn from [_gpsReadings]. One entry per RFID tag.
  ///
  /// This list is not cleared when Stop uploads and then clears
  /// [_gpsReadings], so the pins stay on the map after scanning ends.
  /// A new Start, or choosing another asset, clears it.
  final scanMarkers = <GpsDataModel>[].obs;

  /// Assets already returned by the Start dashboard lookup. Used only to
  /// label markers. No extra request is made for the map.
  final List<DashboardSearchAssetModel> _trackedAssets = [];

  StreamSubscription<String>? _tagSubscription;

  bool get canStart =>
      selectedAsset.value != null &&
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

  // Temporary sample pins so the map can be checked before a live RFID scan.
  // Start still clears _gpsReadings before a real session, so these are
  // not uploaded.
  // void _seedDummyMapReadings() {
  //   const samples = <({
  //     String name,
  //     String code,
  //     String tag,
  //     double latitude,
  //     double longitude,
  //   })>[
  //     (
  //       name: 'Sample Laptop',
  //       code: 'AST-DEMO-01',
  //       tag: 'TAG-DEMO-01',
  //       latitude: 28.6139,
  //       longitude: 77.2090,
  //     ),
  //     (
  //       name: 'Sample Printer',
  //       code: 'AST-DEMO-02',
  //       tag: 'TAG-DEMO-02',
  //       latitude: 28.6289,
  //       longitude: 77.2195,
  //     ),
  //   ];
  //
  //   for (final sample in samples) {
  //     final alreadyStored = _gpsReadings.any(
  //       (item) => item.rfidNumber == sample.tag,
  //     );
  //     if (!alreadyStored) {
  //       _gpsReadings.add(
  //         GpsDataModel(
  //           rfidNumber: sample.tag,
  //           latitude: sample.latitude,
  //           longitude: sample.longitude,
  //           timestamp: LocationService.deviceTimestamp(),
  //           isHandHeld: true,
  //         ),
  //       );
  //     }
  //
  //     final alreadyLabeled = _trackedAssets.any(
  //       (asset) =>
  //           asset.rfid == sample.tag || asset.tagCode == sample.tag,
  //     );
  //     if (!alreadyLabeled) {
  //       _trackedAssets.add(
  //         DashboardSearchAssetModel(
  //           assetCode: sample.code,
  //           tagCode: sample.tag,
  //           assetName: sample.name,
  //           rfid: sample.tag,
  //           locationCode: '',
  //           serialNo: '',
  //         ),
  //       );
  //     }
  //
  //     _publishScanMarker(
  //       _gpsReadings.firstWhere((item) => item.rfidNumber == sample.tag),
  //     );
  //   }
  // }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  Future<void> openAssetLookup() async {
    if (isScanning.value || isStopping.value) {
      Get.snackbar(
        AppStrings.searchAsset,
        AppStrings.stopTrackingBeforeChangingAsset,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to<SearchAssetItemModel>(
      () => const SearchAssetLookupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SearchAssetLookupController(
            searchAssetRepository: Get.find<SearchAssetRepository>(),
          ),
        );
      }),
    );
    if (result == null) return;

    selectedAsset.value = result;
    assetController.text = result.trackingLabel;
    _gpsReadings.clear();
    _trackedAssets.clear();
    scanMarkers.clear();
    // _seedDummyMapReadings();
  }

  Future<void> start() async {
    final asset = selectedAsset.value;
    if (asset == null || isScanning.value || isStopping.value) return;

    isStarting.value = true;
    try {
      final result = await searchAssetRepository.dashboardSearchAsset(
        asset.tagCode,
      );

      if (!result.isSuccess || result.assets.isEmpty) {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToStartAssetTracking,
        );
        return;
      }

      _gpsReadings.clear();
      scanMarkers.clear();
      _trackedAssets
        ..clear()
        ..addAll(result.assets);

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
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToStartAssetTrackingRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToStartAssetTrackingRetry);
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> stop() async {
    if (!isScanning.value || isStopping.value) return;

    isStopping.value = true;
    isScanning.value = false;
    await rfidService.stopInventory();

    showAppLoadingDialog();
    try {
      if (_gpsReadings.isNotEmpty) {
        final response = await searchAssetRepository.insertGpsData(_gpsReadings);
        hideAppLoadingDialog();
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : response.succeeded
                  ? AppStrings.trackingDataSavedSuccessfully
                  : AppStrings.unableToSaveTrackingData,
        );
      } else {
        hideAppLoadingDialog();
        await showAppMessageDialog(AppStrings.noTrackingDataScanned);
      }
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

    // Duplicate tags stay a single marker: the pin moves to the latest valid
    // fix. An invalid fix does not add a pin and does not move one that
    // already has a valid position. The reading itself still stays in
    // [_gpsReadings] for the existing Stop upload.
    final stored = existingIndex >= 0 ? _gpsReadings[existingIndex] : reading;
    _publishScanMarker(stored);
  }

  /// Name, code, and tag shown when a marker is tapped.
  ///
  /// Matched against the asset list already loaded at Start, then the
  /// selected asset. The scanned RFID is always shown as the tag.
  ScanMarkerDetails detailsFor(String rfidNumber) {
    final tag = rfidNumber.trim();
    final needle = tag.toLowerCase();

    for (final asset in _trackedAssets) {
      final rfid = asset.rfid.toLowerCase();
      final tagCode = asset.tagCode.toLowerCase();
      final matchesRfid = rfid.isNotEmpty && rfid == needle;
      final matchesTag = tagCode.isNotEmpty && tagCode == needle;
      if (matchesRfid || matchesTag) {
        return ScanMarkerDetails(
          assetName: asset.assetName,
          assetCode: asset.assetCode,
          tagCode: asset.tagCode.isNotEmpty ? asset.tagCode : tag,
        );
      }
    }

    final selected = selectedAsset.value;
    if (selected != null && selected.tagCode.trim().toLowerCase() == needle) {
      return ScanMarkerDetails(
        assetName: selected.assetName,
        assetCode: selected.assetCode,
        tagCode: selected.tagCode.isNotEmpty ? selected.tagCode : tag,
      );
    }

    return ScanMarkerDetails(
      assetName: '',
      assetCode: '',
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
    assetController.dispose();
    super.onClose();
  }
}

class ScanMarkerDetails {
  const ScanMarkerDetails({
    required this.assetName,
    required this.assetCode,
    required this.tagCode,
  });

  final String assetName;
  final String assetCode;
  final String tagCode;
}
