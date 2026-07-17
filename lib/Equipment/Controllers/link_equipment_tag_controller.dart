import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Equipment/Models/equipment_data_model.dart';
import 'package:midas/Equipment/Models/equipment_link_request.dart';
import 'package:midas/Equipment/equipment_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

class LinkEquipmentTagController extends GetxController {
  LinkEquipmentTagController({
    required this.equipmentRepository,
    required this.rfidService,
  });

  final EquipmentRepository equipmentRepository;
  final RfidService rfidService;

  final tagController = TextEditingController();
  final equipmentController = TextEditingController();
  final tagFocusNode = FocusNode();

  final selectedEquipment = Rxn<EquipmentDataModel>();
  final isSubmitting = false.obs;
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
    if (tagController.text.trim().isEmpty) {
      selectedEquipment.value = null;
      equipmentController.clear();
    }
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    selectedEquipment.value = null;
    equipmentController.clear();
    tagController.text = tag;
    tagController.selection = TextSelection.collapsed(offset: tag.length);
    _focusTagField();
    rfidService.beep(success: true);
  }

  void _focusTagField() {
    if (tagFocusNode.canRequestFocus) {
      tagFocusNode.requestFocus();
    }
  }

  Future<void> scanQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      selectedEquipment.value = null;
      equipmentController.clear();
      tagController.text = code;
      _focusTagField();
    }
  }

  bool get _hasTag => tagController.text.trim().isNotEmpty;

  Future<void> openEquipmentSearch() async {
    if (!_hasTag) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfidFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.toNamed(AppRoutes.searchEquipment);
    if (result is EquipmentDataModel) {
      selectedEquipment.value = result;
      equipmentController.text = result.displayLabel;
    }
  }

  Future<void> linkTag() async {
    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final equipment = selectedEquipment.value;
    if (equipment == null) {
      Get.snackbar(
        AppStrings.equipmentRequired,
        AppStrings.selectEquipmentFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await equipmentRepository.linkEquipmentTag(
        requests: [
          EquipmentLinkRequest(
            equipmentId: equipment.id,
            equipmentCode: equipment.equipmentCode,
            tagCode: tag,
            tagId: 0,
          ),
        ],
      );

      if (response.succeeded) {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.equipmentTagLinkedSuccessfully,
        );
        _resetForm();
      } else {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToLinkEquipmentTag,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToLinkEquipmentTagRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToLinkEquipmentTagRetry);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    tagController.clear();
    equipmentController.clear();
    selectedEquipment.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusTagField();
    });
  }

  @override
  void onClose() {
    tagController.removeListener(_onTagChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    tagFocusNode.dispose();
    tagController.dispose();
    equipmentController.dispose();
    super.onClose();
  }
}
