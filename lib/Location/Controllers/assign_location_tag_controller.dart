import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Location/Models/add_asset_location_model.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/Location/location_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';

class AssignLocationTagController extends GetxController {
  AssignLocationTagController({
    required this.locationRepository,
    required this.rfidService,
  });

  final LocationRepository locationRepository;
  final RfidService rfidService;

  final locationController = TextEditingController();
  final dialogAssetController = TextEditingController();
  final assetTags = <String>[].obs;

  final isSubmitting = false.obs;
  final isRfidConnected = false.obs;
  final isAssetDialogOpen = false.obs;

  StreamSubscription<String>? _tagSubscription;

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
    if (isAssetDialogOpen.value) {
      dialogAssetController.text = tag;
    } else {
      locationController.text = tag;
    }
  }

  Future<void> scanLocationQr() => _scanQr(forAsset: false);

  Future<void> scanAssetQr() => _scanQr(forAsset: true);

  Future<void> _scanQr({required bool forAsset}) async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code == null || code.isEmpty) return;

    if (forAsset || isAssetDialogOpen.value) {
      dialogAssetController.text = code;
    } else {
      locationController.text = code;
    }
  }

  void beginAssetDialog() {
    dialogAssetController.clear();
    isAssetDialogOpen.value = true;
  }

  void endAssetDialog() {
    isAssetDialogOpen.value = false;
    dialogAssetController.clear();
  }

  bool addAssetTag(String code) {
    final tag = code.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.assetQrRequired,
        AppStrings.enterAssetQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (assetTags.contains(tag)) {
      Get.snackbar(
        AppStrings.duplicateAsset,
        AppStrings.assetTagAlreadyInList,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    assetTags.add(tag);
    return true;
  }

  void submitAssetFromDialog() {
    if (addAssetTag(dialogAssetController.text)) {
      Get.back();
    }
  }

  void removeAssetTag(int index) {
    if (index < 0 || index >= assetTags.length) return;
    assetTags.removeAt(index);
  }

  Future<void> assignLocationWithAsset() async {
    final locationCode = locationController.text.trim();
    if (locationCode.isEmpty) {
      Get.snackbar(
        AppStrings.locationRequired,
        AppStrings.enterLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (assetTags.isEmpty) {
      Get.snackbar(
        AppStrings.assetsRequired,
        AppStrings.addAtLeastOneAssetQr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await locationRepository.insertAssetLocation(
        AddAssetLocationModel(
          locationCode: locationCode,
          tagCodes: List<String>.from(assetTags),
        ),
      );

      if (response.succeeded) {
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.locationAssignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
      } else {
        Get.snackbar(
          AppStrings.assignFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToAssignLocation,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.assignFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToAssignLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.unableToAssignLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    locationController.clear();
    assetTags.clear();
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.disconnect();
    locationController.dispose();
    dialogAssetController.dispose();
    super.onClose();
  }
}
