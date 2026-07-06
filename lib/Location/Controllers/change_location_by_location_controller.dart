import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/Models/location_asset_model.dart';
import 'package:midas/Location/Models/update_asset_location_model.dart';
import 'package:midas/Location/location_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';

enum LocationChangeType { shift, transit }

class ChangeLocationByLocationController extends GetxController {
  ChangeLocationByLocationController({
    required this.locationRepository,
    required this.rfidService,
  });

  final LocationRepository locationRepository;
  final RfidService rfidService;

  final sourceLocationController = TextEditingController();
  final destinationLocationController = TextEditingController();
  final searchController = TextEditingController();

  final allAssets = <LocationAssetModel>[].obs;
  final selectedTagCodes = <String>{}.obs;
  final remarks = <ChangeLocationRemarkModel>[].obs;
  final selectedRemark = Rxn<ChangeLocationRemarkModel>();
  final changeType = Rxn<LocationChangeType>();
  final searchQuery = ''.obs;

  final hasFetchedDetails = false.obs;
  final isFetching = false.obs;
  final isLoadingRemarks = false.obs;
  final isSubmitting = false.obs;
  final isRfidConnected = false.obs;
  final isDestinationDialogOpen = false.obs;

  StreamSubscription<String>? _tagSubscription;

  List<LocationAssetModel> get filteredAssets {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return allAssets;
    return allAssets.where((asset) {
      return asset.assetName.toLowerCase().contains(query) ||
          asset.tagCode.toLowerCase().contains(query) ||
          asset.assetCode.toLowerCase().contains(query);
    }).toList();
  }

  bool get allFilteredSelected {
    final visible = filteredAssets;
    if (visible.isEmpty) return false;
    return visible.every((asset) => selectedTagCodes.contains(asset.tagCode));
  }

  bool get isTransit => changeType.value == LocationChangeType.transit;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    sourceLocationController.addListener(_onSourceLocationChanged);
    _initRfid();
  }

  void _onSourceLocationChanged() {
    if (hasFetchedDetails.value) {
      _resetDetails();
    }
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    if (isDestinationDialogOpen.value) {
      destinationLocationController.text = tag;
    } else if (!hasFetchedDetails.value) {
      sourceLocationController.text = tag;
    }
  }

  Future<void> scanSourceQr() => _scanQr(forDestination: false);

  Future<void> scanDestinationQr() => _scanQr(forDestination: true);

  Future<void> _scanQr({required bool forDestination}) async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code == null || code.isEmpty) return;

    if (forDestination || isDestinationDialogOpen.value) {
      destinationLocationController.text = code;
    } else {
      sourceLocationController.text = code;
    }
  }

  Future<void> fetchDetails() async {
    final locationCode = sourceLocationController.text.trim();
    if (locationCode.isEmpty) {
      Get.snackbar(
        AppStrings.locationRequired,
        AppStrings.enterLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isFetching.value = true;
    _resetDetails();
    try {
      final result =
          await locationRepository.getAssetDetailsByLocationCode(locationCode);

      if (result.succeeded && result.assets.isNotEmpty) {
        allAssets.assignAll(result.assets);
        hasFetchedDetails.value = true;
      } else {
        Get.snackbar(
          AppStrings.fetchFailed,
          result.message.isNotEmpty
              ? result.message
              : result.assets.isEmpty
                  ? AppStrings.noAssetsAtLocation
                  : AppStrings.unableToFetchLocationDetails,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.fetchFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchLocationDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchLocationDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> onChangeTypeSelected(LocationChangeType type) async {
    if (changeType.value == type) return;
    changeType.value = type;
    selectedRemark.value = null;
    remarks.clear();
    await _loadRemarks();
  }

  Future<void> _loadRemarks() async {
    final type = changeType.value;
    if (type == null) return;

    isLoadingRemarks.value = true;
    try {
      final result = await locationRepository.getChangeLocationRemarks(
        isTransit: type == LocationChangeType.transit,
      );
      remarks.assignAll(result);
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.fetchFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchAssetDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchAssetDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRemarks.value = false;
    }
  }

  void toggleAsset(String tagCode, bool? selected) {
    if (selected == true) {
      selectedTagCodes.add(tagCode);
    } else {
      selectedTagCodes.remove(tagCode);
    }
    selectedTagCodes.refresh();
  }

  void toggleSelectAll(bool? selected) {
    final visible = filteredAssets;
    if (selected == true) {
      selectedTagCodes.addAll(visible.map((asset) => asset.tagCode));
    } else {
      for (final asset in visible) {
        selectedTagCodes.remove(asset.tagCode);
      }
    }
    selectedTagCodes.refresh();
  }

  bool validateChange() {
    if (changeType.value == null) {
      Get.snackbar(
        AppStrings.changeTypeRequired,
        AppStrings.selectShiftOrTransit,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (selectedRemark.value == null) {
      Get.snackbar(
        AppStrings.remarkRequired,
        AppStrings.selectRemarkFromDropdown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (selectedTagCodes.isEmpty) {
      Get.snackbar(
        AppStrings.assetsRequired,
        AppStrings.selectAtLeastOneAsset,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  void beginDestinationDialog() {
    destinationLocationController.clear();
    isDestinationDialogOpen.value = true;
  }

  void endDestinationDialog() {
    isDestinationDialogOpen.value = false;
    destinationLocationController.clear();
  }

  Future<void> submitDestinationLocation() async {
    final destinationCode = destinationLocationController.text.trim();
    if (destinationCode.isEmpty) {
      Get.snackbar(
        AppStrings.destinationLocationRequired,
        AppStrings.enterDestinationLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final remark = selectedRemark.value;
    if (remark == null) return;

    isSubmitting.value = true;
    try {
      final response = await locationRepository.updateAssetLocation(
        UpdateAssetLocationModel(
          locationCode: destinationCode,
          isTransit: isTransit,
          tagCodes: selectedTagCodes.toList(),
          changeLocationRemarkId: remark.id,
          remarks: remark.name,
        ),
      );

      if (response.succeeded) {
        Get.back();
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.locationChangedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
      } else {
        Get.snackbar(
          AppStrings.changeLocationFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToChangeLocation,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.changeLocationFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToChangeLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.changeLocationFailed,
        AppStrings.unableToChangeLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetDetails() {
    hasFetchedDetails.value = false;
    allAssets.clear();
    selectedTagCodes.clear();
    remarks.clear();
    selectedRemark.value = null;
    changeType.value = null;
    searchController.clear();
    searchQuery.value = '';
  }

  void _resetForm() {
    sourceLocationController.clear();
    destinationLocationController.clear();
    _resetDetails();
  }

  @override
  void onClose() {
    sourceLocationController.removeListener(_onSourceLocationChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    sourceLocationController.dispose();
    destinationLocationController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
