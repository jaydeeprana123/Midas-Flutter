import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Models/identity_asset_model.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class IdentifyAssetController extends GetxController {
  IdentifyAssetController({
    required this.assetRepository,
    required this.rfidService,
  });

  final AssetRepository assetRepository;
  final RfidService rfidService;

  final tagController = TextEditingController();

  final identityAsset = Rxn<IdentityAssetModel>();
  final isFetching = false.obs;
  final isRfidConnected = false.obs;

  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    tagController.addListener(_onTagChanged);
    _initRfid();
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagChanged() {
    identityAsset.value = null;
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
    identityAsset.value = null;
    try {
      final result = await assetRepository.identityAssetForMobileApp(
        assetData: tag,
      );

      if (result.succeeded && result.asset != null) {
        identityAsset.value = result.asset;
      } else {
        await showAppMessageDialog(
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToFetchAssetDetails,
        );
      }
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
      isFetching.value = false;
    }
  }

  @override
  void onClose() {
    tagController.removeListener(_onTagChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    tagController.dispose();
    super.onClose();
  }
}
