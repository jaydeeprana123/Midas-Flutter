import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Equipment/Models/equipment_link_request.dart';
import 'package:midas/Equipment/Models/fetched_equipment_model.dart';
import 'package:midas/Equipment/equipment_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/Shared/Widgets/delink_confirmation_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class DelinkEquipmentTagController extends GetxController {
  DelinkEquipmentTagController({
    required this.equipmentRepository,
    required this.rfidService,
  });

  final EquipmentRepository equipmentRepository;
  final RfidService rfidService;

  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final fetchedEquipment = Rxn<FetchedEquipmentModel>();
  final isFetching = false.obs;
  final isDelinking = false.obs;
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
    if (fetchedEquipment.value != null) {
      fetchedEquipment.value = null;
    }
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    fetchedEquipment.value = null;
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
      fetchedEquipment.value = null;
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
    fetchedEquipment.value = null;
    try {
      final result = await equipmentRepository.getTaggedEquipmentDetailsByTagCode(
        tagCode: tag,
      );

      if (result.succeeded && result.equipment != null) {
        fetchedEquipment.value = result.equipment;
      } else {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToFetchEquipmentDetails,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchEquipmentDetailsRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToFetchEquipmentDetailsRetry);
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> delinkTag() async {
    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final equipment = fetchedEquipment.value;
    if (equipment == null) {
      Get.snackbar(
        AppStrings.equipmentDetailsRequired,
        AppStrings.fetchDetailsBeforeDelink,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await showDelinkConfirmationDialog();
    if (confirmed != true) return;

    isDelinking.value = true;
    try {
      final response = await equipmentRepository.delinkEquipmentTag(
        requests: [
          EquipmentLinkRequest(
            equipmentId: equipment.id,
            equipmentCode: equipment.equipmentCode,
            tagCode: tag,
            tagId: equipment.tagId ?? 0,
          ),
        ],
      );

      if (response.succeeded) {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.equipmentTagDelinkedSuccessfully,
        );
        _resetForm();
      } else {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToDelinkEquipmentTag,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToDelinkEquipmentTagRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToDelinkEquipmentTagRetry);
    } finally {
      isDelinking.value = false;
    }
  }

  void _resetForm() {
    tagController.clear();
    fetchedEquipment.value = null;
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
    super.onClose();
  }
}
