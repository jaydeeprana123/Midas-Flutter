import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/add_material_tagging_request.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Material/Models/pending_material_assign_tag_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

class AssignMaterialTagController extends GetxController {
  AssignMaterialTagController({
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

  final materialController = TextEditingController();
  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final selectedSource = Rxn<MaterialInwardSource>();
  final selectedMaterial = Rxn<MaterialByInwardTypeModel>();
  final materials = <MaterialByInwardTypeModel>[].obs;
  final _allMaterials = <MaterialByInwardTypeModel>[];
  var _allMaterialsLoaded = false;

  final isLoadingMaterials = false.obs;
  final isSubmitting = false.obs;
  final isRfidConnected = false.obs;

  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(_loadAllMaterials());
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
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

  void onSourceChanged(MaterialInwardSource? source) {
    selectedSource.value = source;
    selectedMaterial.value = null;
    materialController.clear();
    materials.clear();

    if (source == null) return;
    _applySourceFilter(source.id);
  }

  Future<void> _loadAllMaterials() async {
    if (isLoadingMaterials.value) return;

    isLoadingMaterials.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _fetchAllMaterialsOnline();
      } else {
        await _fetchAllMaterialsOffline();
      }
      _allMaterialsLoaded = true;
    } finally {
      isLoadingMaterials.value = false;
      final source = selectedSource.value;
      if (source != null) {
        _applySourceFilter(source.id);
      }
    }
  }

  Future<void> _fetchAllMaterialsOnline() async {
    try {
      final result = await materialRepository.getAllMaterialsForAllSources();
      _allMaterials
        ..clear()
        ..addAll(result);
      await sqliteService.replaceAllMaterialsForAssignTag(result);
    } on DioException catch (e) {
      await _fetchAllMaterialsOffline(
        showErrorOnEmpty: true,
        errorMessage: e.response?.data is Map &&
                (e.response?.data as Map)['message'] != null
            ? (e.response?.data as Map)['message'].toString()
            : AppStrings.unableToFetchMaterialsRetry,
      );
    } catch (_) {
      await _fetchAllMaterialsOffline(
        showErrorOnEmpty: true,
        errorMessage: AppStrings.unableToFetchMaterialsRetry,
      );
    }
  }

  Future<void> _fetchAllMaterialsOffline({
    bool showErrorOnEmpty = false,
    String? errorMessage,
  }) async {
    final cached = await sqliteService.getAllMaterialsForAssignTag();
    _allMaterials
      ..clear()
      ..addAll(cached);

    if (cached.isEmpty && showErrorOnEmpty) {
      Get.snackbar(
        AppStrings.fetchFailed,
        errorMessage ?? AppStrings.noOfflineMaterialsForSource,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _applySourceFilter(int sourceId) {
    final filtered = _allMaterials
        .where((material) => material.inwardTypeId == sourceId)
        .toList();
    materials.assignAll(filtered);

    if (filtered.isEmpty && _allMaterialsLoaded) {
      Get.snackbar(
        AppStrings.noMaterialsFound,
        AppStrings.noMaterialsForSelectedSource,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openMaterialSearch() async {
    if (selectedSource.value == null) {
      Get.snackbar(
        AppStrings.sourceRequired,
        AppStrings.selectSourceFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isLoadingMaterials.value) return;
    if (materials.isEmpty) {
      Get.snackbar(
        AppStrings.noMaterialsFound,
        AppStrings.noMaterialsForSelectedSource,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.toNamed(
      AppRoutes.materialSearch,
      arguments: materials.toList(),
    );
    if (result is MaterialByInwardTypeModel) {
      selectedMaterial.value = result;
      materialController.text = result.displayLabel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusTagField();
      });
    }
  }

  Future<void> scanQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      tagController.text = code;
      _focusTagField();
    }
  }

  AddMaterialTaggingRequest _buildRequest({
    required MaterialInwardSource source,
    required MaterialByInwardTypeModel material,
    required String tag,
  }) {
    return AddMaterialTaggingRequest(
      inwardTypeId: source.id,
      inwardId: material.id > 0 ? material.id : null,
      materialId: material.materialId,
      quantity: material.quantity - material.taggedQuantity,
      materialTagingDetails: [AddMaterialTaggingDetails(tagCode: tag)],
    );
  }

  Future<void> assignTag() async {
    final source = selectedSource.value;
    if (source == null) {
      Get.snackbar(
        AppStrings.sourceRequired,
        AppStrings.selectSourceFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final material = selectedMaterial.value;
    if (material == null) {
      Get.snackbar(
        AppStrings.materialRequired,
        AppStrings.selectMaterialFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      Get.snackbar(
        AppStrings.qrRfidRequired,
        AppStrings.scanOrEnterQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final request = _buildRequest(source: source, material: material, tag: tag);

    isSubmitting.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _assignOnline(request);
      } else {
        await _assignOffline(request);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _assignOnline(AddMaterialTaggingRequest request) async {
    try {
      final response = await materialRepository.insertMaterialTagging(request);

      if (response.succeeded) {
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.materialTagAssignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
        await syncService.syncPendingOperations();
      } else {
        Get.snackbar(
          AppStrings.assignFailed,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToAssignMaterialTag,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        await _assignOffline(request);
        return;
      }
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.assignFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToAssignMaterialTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.unableToAssignMaterialTagRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _assignOffline(AddMaterialTaggingRequest request) async {
    final isDuplicate = await sqliteService.hasPendingAssignTag(request);
    if (isDuplicate) {
      Get.snackbar(
        AppStrings.savedForSync,
        AppStrings.materialAssignAlreadyPending,
        snackPosition: SnackPosition.BOTTOM,
      );
      _resetForm();
      return;
    }

    await sqliteService.insertPendingAssignTag(
      PendingMaterialAssignTagModel(request: request),
    );

    Get.snackbar(
      AppStrings.savedForSync,
      AppStrings.materialAssignSavedOffline,
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
    selectedSource.value = null;
    selectedMaterial.value = null;
    materials.clear();
    materialController.clear();
    tagController.clear();
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.disconnect();
    tagFocusNode.dispose();
    materialController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
