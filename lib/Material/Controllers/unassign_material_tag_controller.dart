import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/pending_material_unassign_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';

class UnassignMaterialTagController extends GetxController {
  UnassignMaterialTagController({
    required this.materialRepository,
    required this.rfidService,
    required this.sqliteService,
    required this.connectivityService,
    required this.syncService,
  });

  final MaterialRepository materialRepository;
  final RfidService rfidService;
  final MaterialSqliteService sqliteService;
  final NetworkConnectivityService connectivityService;
  final MaterialUnassignSyncService syncService;

  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final materialDetails = Rxn<MaterialTaggingDetailModel>();
  final isFetching = false.obs;
  final isUnassigning = false.obs;
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
    materialDetails.value = null;
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
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
    materialDetails.value = null;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _fetchOnline(tag);
      } else {
        await _fetchOffline(tag);
      }
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> _fetchOnline(String tag) async {
    try {
      final result = await materialRepository.getMaterialTaggingDetails(
        tagCode: tag,
      );

      if (!result.succeeded) {
        Get.snackbar(
          AppStrings.fetchFailed,
          result.message.isNotEmpty
              ? result.message
              : AppStrings.unableToFetchMaterialDetails,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Cache full response locally for offline access.
      await sqliteService.upsertMaterialTagDetails(result.items);

      final match = MaterialTaggingDetailModel.findByTagCode(result.items, tag);
      if (match == null) {
        Get.snackbar(
          AppStrings.fetchFailed,
          AppStrings.materialTagDetailsNotFound,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      materialDetails.value = match;
    } on DioException catch (e) {
      // Fall back to SQLite if the network request fails.
      final cached = await sqliteService.getMaterialTagDetailsByTagCode(tag);
      if (cached != null) {
        materialDetails.value = cached;
        return;
      }
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.fetchFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchMaterialDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      final cached = await sqliteService.getMaterialTagDetailsByTagCode(tag);
      if (cached != null) {
        materialDetails.value = cached;
        return;
      }
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _fetchOffline(String tag) async {
    final cached = await sqliteService.getMaterialTagDetailsByTagCode(tag);
    if (cached != null) {
      materialDetails.value = cached;
      return;
    }
    Get.snackbar(
      AppStrings.fetchFailed,
      AppStrings.noOfflineMaterialDetails,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> unassignTag() async {
    final tag = tagController.text.trim();
    final details = materialDetails.value;
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (details == null) {
      Get.snackbar(
        AppStrings.materialDetailsRequired,
        AppStrings.fetchDetailsBeforeUnassign,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isUnassigning.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _unassignOnline(details);
      } else {
        await _unassignOffline(details);
      }
    } finally {
      isUnassigning.value = false;
    }
  }

  Future<void> _unassignOnline(MaterialTaggingDetailModel details) async {
    try {
      final response = await materialRepository.deLinkMaterialTag(
        detailIds: [details.detailId],
      );

      if (response.succeeded) {
        await sqliteService.deleteMaterialTagDetailsByTagCode(details.tagCode);
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.materialTagUnassignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
        await syncService.syncPendingUnassigns();
      } else {
        Get.snackbar(
          AppStrings.unassignFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToUnassignMaterialTag,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      // Treat connection failures as offline pending sync.
      if (_isNetworkFailure(e)) {
        await _unassignOffline(details);
        return;
      }
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.unassignFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToUnassignMaterialTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.unassignFailed,
        AppStrings.unableToUnassignMaterialTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _unassignOffline(MaterialTaggingDetailModel details) async {
    await sqliteService.insertPendingUnassign(
      PendingMaterialUnassignModel(
        detailIds: [details.detailId],
        tagCode: details.tagCode,
      ),
    );
    await sqliteService.deleteMaterialTagDetailsByTagCode(details.tagCode);

    Get.snackbar(
      AppStrings.savedForSync,
      AppStrings.materialUnassignSavedOffline,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
    _resetForm();
  }

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown;
  }

  void _resetForm() {
    tagController.clear();
    materialDetails.value = null;
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
