import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/identify_material_model.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class IdentifyMaterialController extends GetxController {
  IdentifyMaterialController({
    required this.materialRepository,
    required this.rfidService,
  });

  final MaterialRepository materialRepository;
  final RfidService rfidService;

  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final identifyMaterial = Rxn<IdentifyMaterialModel>();
  final isFetching = false.obs;
  final isRfidConnected = false.obs;

  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    tagController.addListener(_onTagChanged);
    _initRfid();
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusTagField();
    });
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagChanged() {
    identifyMaterial.value = null;
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    tagController.text = tag;
    tagController.selection = TextSelection.collapsed(offset: tag.length);
    _focusTagField();
  }

  void _focusTagField() {
    if (tagFocusNode.canRequestFocus) {
      tagFocusNode.requestFocus();
    }
  }

  Future<void> scanQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      tagController.text = code;
      _focusTagField();
    }
  }

  Future<void> fetchDetails() async {
    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isFetching.value = true;
    identifyMaterial.value = null;
    try {
      final result = await materialRepository.identifyMaterialForMobileApp(
        materialData: tag,
      );

      if (result.succeeded && result.material != null) {
        identifyMaterial.value = result.material;
      } else {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToFetchMaterialDetails,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchMaterialDetailsRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToFetchMaterialDetailsRetry);
    } finally {
      isFetching.value = false;
    }
  }

  @override
  void onClose() {
    tagController.removeListener(_onTagChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    tagFocusNode.dispose();
    tagController.dispose();
    super.onClose();
  }
}
