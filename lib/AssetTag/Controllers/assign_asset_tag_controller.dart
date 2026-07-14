import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Models/asset_link_tag_model.dart';
import 'package:midas/AssetTag/Models/stock_in_request_model.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

class AssignAssetTagController extends GetxController {
  AssignAssetTagController({
    required this.assetRepository,
    required this.secureStorage,
    required this.rfidService,
  });

  final AssetRepository assetRepository;
  final SecureStorageService secureStorage;
  final RfidService rfidService;

  final tagController = TextEditingController();
  final assetController = TextEditingController();
  final serialController = TextEditingController();

  /// Focus for the "Scan QR or RFID" field so the cursor lands there when the
  /// screen opens.
  final tagFocusNode = FocusNode();

  final selectedAssetId = Rxn<int>();
  final isSubmitting = false.obs;
  final isRfidConnected = false.obs;

  int _orgId = 0;
  int _userId = 0;
  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
    _initRfid();
  }

  @override
  void onReady() {
    super.onReady();
    // Auto-focus the QR/RFID field once the entry transition completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tagFocusNode.canRequestFocus) {
        tagFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadSession() async {
    _orgId = await secureStorage.orgId ?? 0;
    _userId = await secureStorage.userId ?? 0;
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    tagController.text = tag;
  }

  Future<void> scanQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      tagController.text = code;
    }
  }

  bool get _hasTag => tagController.text.trim().isNotEmpty;

  Future<void> openAssetSearch() async {
    if (!_hasTag) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfidFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.toNamed(AppRoutes.assetSearch);
    if (result is AssetLinkTagModel) {
      selectedAssetId.value = result.assetId;
      assetController.text = result.displayLabel;
    }
  }

  Future<void> assignTag() async {
    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedAssetId.value == null) {
      Get.snackbar(
        AppStrings.assetRequired,
        AppStrings.selectAssetNameOrCode,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await assetRepository.insertAssetStockIn(
        StockInRequestModel(
          orgId: _orgId,
          assetId: selectedAssetId.value!,
          createdById: _userId,
          isDeleted: false,
          assetStockInDetails: [
            StockInDetailModel(
              serialNo: serialController.text.trim(),
              tagCode: tag,
            ),
          ],
        ),
      );

      if (response.succeeded) {
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.tagAssignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
      } else {
        Get.snackbar(
          AppStrings.assignFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToAssignTag,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.assignFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToAssignTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.unableToAssignTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    tagController.clear();
    assetController.clear();
    serialController.clear();
    selectedAssetId.value = null;
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.disconnect();
    tagFocusNode.dispose();
    tagController.dispose();
    assetController.dispose();
    serialController.dispose();
    super.onClose();
  }
}
