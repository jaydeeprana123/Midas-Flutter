import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Equipment/Models/fetched_equipment_model.dart';
import 'package:midas/Equipment/equipment_repository.dart';
import 'package:midas/Shared/Services/api_client.dart';
import 'package:midas/Shared/Services/job_card_download_service.dart';
import 'package:midas/Shared/Services/local_storage_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class IdentifyEquipmentController extends GetxController {
  IdentifyEquipmentController({
    required this.equipmentRepository,
    required this.rfidService,
    required this.localStorage,
    required this.secureStorage,
    required this.jobCardDownloadService,
  });

  final EquipmentRepository equipmentRepository;
  final RfidService rfidService;
  final LocalStorageService localStorage;
  final SecureStorageService secureStorage;
  final JobCardDownloadService jobCardDownloadService;

  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final fetchedEquipment = Rxn<FetchedEquipmentModel>();
  final isFetching = false.obs;
  final isDownloadingJobCard = false.obs;
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

  Future<void> downloadJobCardReport() async {
    final equipment = fetchedEquipment.value;
    final jobCardNumber = equipment?.jobCardNumber?.trim();
    if (equipment == null || !equipment.hasClickableJobCard || jobCardNumber == null) {
      return;
    }

    final token = await secureStorage.token;
    final baseUrl = localStorage.baseUrl ?? ApiClient.defaultBaseUrl;
    if (token == null || token.isEmpty) {
      await showAppMessageDialog(AppStrings.unableToDownloadJobCardReport);
      return;
    }

    isDownloadingJobCard.value = true;
    try {
      await jobCardDownloadService.downloadJobCardReport(
        baseUrl: baseUrl,
        token: token,
        jobCardNumber: jobCardNumber,
      );
    } on PlatformException catch (e) {
      final message = e.code == 'PERMISSION_DENIED'
          ? AppStrings.storagePermissionRequired
          : (e.message?.isNotEmpty == true
              ? e.message!
              : AppStrings.unableToDownloadJobCardReport);
      await showAppMessageDialog(message);
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToDownloadJobCardReport);
    } finally {
      isDownloadingJobCard.value = false;
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
