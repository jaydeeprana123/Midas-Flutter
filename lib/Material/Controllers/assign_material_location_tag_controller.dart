import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/pending_material_link_location_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';

enum _ScanField { location, materialTag }

class AssignMaterialLocationTagController extends GetxController {
  AssignMaterialLocationTagController({
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

  final locationController = TextEditingController();
  final materialTagController = TextEditingController();
  final locationFocusNode = FocusNode();
  final materialTagFocusNode = FocusNode();

  final materialDetails = Rxn<MaterialTaggingDetailModel>();
  final isFetching = false.obs;
  final isAssigning = false.obs;
  final isRfidConnected = false.obs;

  _ScanField _activeField = _ScanField.location;
  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    locationController.addListener(_onInputsChanged);
    materialTagController.addListener(_onInputsChanged);
    locationFocusNode.addListener(_onLocationFocusChanged);
    materialTagFocusNode.addListener(_onMaterialTagFocusChanged);
    _initRfid();
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusLocationField();
    });
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onLocationFocusChanged() {
    if (locationFocusNode.hasFocus) {
      _activeField = _ScanField.location;
    }
  }

  void _onMaterialTagFocusChanged() {
    if (materialTagFocusNode.hasFocus) {
      _activeField = _ScanField.materialTag;
    }
  }

  void _onInputsChanged() {
    materialDetails.value = null;
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    _applyScannedValue(tag);
    rfidService.beep(success: true);
  }

  void _applyScannedValue(String value) {
    if (_activeField == _ScanField.location ||
        locationController.text.trim().isEmpty) {
      locationController.text = value;
      locationController.selection =
          TextSelection.collapsed(offset: value.length);
      _activeField = _ScanField.materialTag;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusMaterialTagField();
      });
      return;
    }

    materialTagController.text = value;
    materialTagController.selection =
        TextSelection.collapsed(offset: value.length);
    _focusMaterialTagField();
  }

  void _focusLocationField() {
    _activeField = _ScanField.location;
    if (locationFocusNode.canRequestFocus) {
      locationFocusNode.requestFocus();
    }
  }

  void _focusMaterialTagField() {
    _activeField = _ScanField.materialTag;
    if (materialTagFocusNode.canRequestFocus) {
      materialTagFocusNode.requestFocus();
    }
  }

  Future<void> scanLocationQr() async {
    _activeField = _ScanField.location;
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      locationController.text = code;
      _activeField = _ScanField.materialTag;
      _focusMaterialTagField();
    }
  }

  Future<void> scanMaterialTagQr() async {
    _activeField = _ScanField.materialTag;
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      materialTagController.text = code;
      _focusMaterialTagField();
    }
  }


  Future<void> fetchDetails() async {
    final locationCode = locationController.text.trim();
    final tag = materialTagController.text.trim();

    if (locationCode.isEmpty) {
      Get.snackbar(
        AppStrings.locationRequired,
        AppStrings.enterLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanMaterialTagQrRequired,
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

  Future<void> assignLocationWithMaterial() async {
    final locationCode = locationController.text.trim();
    final details = materialDetails.value;

    if (locationCode.isEmpty) {
      Get.snackbar(
        AppStrings.locationRequired,
        AppStrings.enterLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (details == null) {
      Get.snackbar(
        AppStrings.materialDetailsRequired,
        AppStrings.fetchDetailsBeforeAssignLocation,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isAssigning.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _assignOnline(locationCode, details);
      } else {
        await _assignOffline(locationCode, details);
      }
    } finally {
      isAssigning.value = false;
    }
  }

  Future<void> _assignOnline(
    String locationCode,
    MaterialTaggingDetailModel details,
  ) async {
    try {
      final response = await materialRepository.linkMaterialLocation(
        locationCode: locationCode,
        detailIds: [details.detailId],
      );

      if (response.succeeded) {
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.materialLocationAssignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
        await syncService.syncPendingOperations();
      } else {
        Get.snackbar(
          AppStrings.assignFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToAssignMaterialLocation,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        await _assignOffline(locationCode, details);
        return;
      }
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.assignFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToAssignMaterialLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.unableToAssignMaterialLocationRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _assignOffline(
    String locationCode,
    MaterialTaggingDetailModel details,
  ) async {
    await sqliteService.insertPendingLinkLocation(
      PendingMaterialLinkLocationModel(
        locationCode: locationCode,
        detailIds: [details.detailId],
        tagCode: details.tagCode,
      ),
    );

    Get.snackbar(
      AppStrings.savedForSync,
      AppStrings.materialLinkLocationSavedOffline,
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
    locationController.clear();
    materialTagController.clear();
    materialDetails.value = null;
    _activeField = _ScanField.location;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusLocationField();
    });
  }

  @override
  void onClose() {
    locationController.removeListener(_onInputsChanged);
    materialTagController.removeListener(_onInputsChanged);
    locationFocusNode.removeListener(_onLocationFocusChanged);
    materialTagFocusNode.removeListener(_onMaterialTagFocusChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    locationFocusNode.dispose();
    materialTagFocusNode.dispose();
    locationController.dispose();
    materialTagController.dispose();
    super.onClose();
  }
}
