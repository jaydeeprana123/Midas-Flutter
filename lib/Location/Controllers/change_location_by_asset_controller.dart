import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/Models/location_asset_model.dart';
import 'package:midas/Location/Models/update_asset_location_model.dart';
import 'package:midas/Location/Views/scan_asset_qr_change_location_view.dart';
import 'package:midas/Location/location_change_type.dart';
import 'package:midas/Location/location_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class ChangeLocationByAssetController extends GetxController {
  ChangeLocationByAssetController({
    required this.locationRepository,
    required this.assetRepository,
    required this.rfidService,
  });

  final LocationRepository locationRepository;
  final AssetRepository assetRepository;
  final RfidService rfidService;

  final destinationLocationController = TextEditingController();
  final scanAssetTagController = TextEditingController();

  final pendingTagCodes = <String>[].obs;
  final identifiedAssets = <LocationAssetModel>[].obs;
  final remarks = <ChangeLocationRemarkModel>[].obs;
  final selectedRemark = Rxn<ChangeLocationRemarkModel>();
  final changeType = Rxn<LocationChangeType>();

  final isLoadingRemarks = false.obs;
  final isSubmittingBulk = false.obs;
  final isUpdating = false.obs;
  final isRfidConnected = false.obs;
  final isAssetScanScreenOpen = false.obs;

  StreamSubscription<String>? _tagSubscription;

  bool get isShift => changeType.value == LocationChangeType.shift;
  bool get isTransit => changeType.value == LocationChangeType.transit;
  bool get hasChangeType => changeType.value != null;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    if (isAssetScanScreenOpen.value) {
      if (addPendingTag(tag)) {
        scanAssetTagController.clear();
      }
    } else if (isShift) {
      destinationLocationController.text = tag;
    }
  }

  Future<void> scanDestinationQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      destinationLocationController.text = code;
    }
  }

  Future<void> scanAssetTagQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      if (addPendingTag(code)) {
        scanAssetTagController.clear();
      }
    }
  }

  Future<void> onChangeTypeSelected(LocationChangeType type) async {
    if (changeType.value == type) return;
    changeType.value = type;
    selectedRemark.value = null;
    remarks.clear();
    if (!isShift) {
      destinationLocationController.clear();
    }
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
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchAssetDetailsRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToFetchAssetDetailsRetry);
    } finally {
      isLoadingRemarks.value = false;
    }
  }

  Future<void> openAssetScanScreen() async {
    _syncPendingTagsFromIdentifiedAssets();
    isAssetScanScreenOpen.value = true;
    final result = await Get.to<List<LocationAssetModel>>(
      () => const ScanAssetQrChangeLocationView(),
    );
    isAssetScanScreenOpen.value = false;
    scanAssetTagController.clear();
    if (result != null) {
      identifiedAssets.assignAll(result);
    }
  }

  void _syncPendingTagsFromIdentifiedAssets() {
    for (final asset in identifiedAssets) {
      final tag = asset.tagCode.trim();
      if (tag.isNotEmpty && !pendingTagCodes.contains(tag)) {
        pendingTagCodes.add(tag);
      }
    }
  }

  bool addPendingTag(String code) {
    final tag = code.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.assetQrRequired,
        AppStrings.enterAssetQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (pendingTagCodes.contains(tag)) {
      Get.snackbar(
        AppStrings.duplicateAssetTag,
        AppStrings.assetTagAlreadyAdded,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    pendingTagCodes.add(tag);
    return true;
  }

  void removePendingTag(int index) {
    if (index < 0 || index >= pendingTagCodes.length) return;
    pendingTagCodes.removeAt(index);
  }

  void removeIdentifiedAsset(int index) {
    if (index < 0 || index >= identifiedAssets.length) return;
    final removed = identifiedAssets.removeAt(index);
    pendingTagCodes.remove(removed.tagCode);
  }

  Future<void> submitBulkIdentity() async {
    if (pendingTagCodes.isEmpty) {
      Get.snackbar(
        AppStrings.assetsRequired,
        AppStrings.addAtLeastOneAssetTag,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmittingBulk.value = true;
    try {
      final result = await assetRepository.bulkIdentityAssetsForMobileApp(
        List<String>.from(pendingTagCodes),
      );

      if (result.succeeded && result.assets.isNotEmpty) {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.success,
        );
        Get.back(result: result.assets);
      } else {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToIdentifyAssets,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToIdentifyAssets,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToIdentifyAssets);
    } finally {
      isSubmittingBulk.value = false;
    }
  }

  Future<void> updateAssetLocation() async {
    if (changeType.value == null) {
      Get.snackbar(
        AppStrings.changeTypeRequired,
        AppStrings.selectShiftOrTransit,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedRemark.value == null) {
      Get.snackbar(
        AppStrings.remarkRequired,
        AppStrings.selectRemarkFromDropdown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (identifiedAssets.isEmpty) {
      Get.snackbar(
        AppStrings.identifiedAssetsRequired,
        AppStrings.identifyAssetsBeforeUpdate,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isShift && destinationLocationController.text.trim().isEmpty) {
      Get.snackbar(
        AppStrings.destinationLocationRequired,
        AppStrings.enterDestinationLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final remark = selectedRemark.value!;
    isUpdating.value = true;
    try {
      final response = await locationRepository.updateAssetLocation(
        UpdateAssetLocationModel(
          locationCode: isShift ? destinationLocationController.text.trim() : '',
          isTransit: isTransit,
          tagCodes: identifiedAssets.map((asset) => asset.tagCode).toList(),
          changeLocationRemarkId: remark.id,
          remarks: remark.name,
        ),
      );

      await showAppMessageDialog(
        response.message.isNotEmpty
            ? response.message
            : response.succeeded
                ? AppStrings.locationChangedSuccessfully
                : AppStrings.unableToChangeLocation,
      );

      if (response.succeeded) {
        _resetForm();
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToChangeLocationRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToChangeLocationRetry);
    } finally {
      isUpdating.value = false;
    }
  }

  void _resetForm() {
    changeType.value = null;
    selectedRemark.value = null;
    remarks.clear();
    pendingTagCodes.clear();
    identifiedAssets.clear();
    destinationLocationController.clear();
    scanAssetTagController.clear();
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.disconnect();
    destinationLocationController.dispose();
    scanAssetTagController.dispose();
    super.onClose();
  }
}
