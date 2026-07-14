import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/SearchAsset/Controllers/search_asset_lookup_controller.dart';
import 'package:midas/SearchAsset/Views/search_asset_lookup_view.dart';
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
  }

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
