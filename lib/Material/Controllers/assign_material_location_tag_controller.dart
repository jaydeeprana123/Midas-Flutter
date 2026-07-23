import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Controllers/material_multi_select_search_controller.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Material/Models/pending_material_link_location_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/Views/material_multi_select_search_view.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';

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
  final materialSearchController = TextEditingController();
  final locationFocusNode = FocusNode();

  final selectedSource = Rxn<MaterialInwardSource>();
  final availableMaterials = <MaterialByInwardTypeModel>[].obs;
  final selectedMaterials = <MaterialByInwardTypeModel>[].obs;

  final isLoadingMaterials = false.obs;
  final isAssigning = false.obs;
  final isRfidConnected = false.obs;
  final hasLocationCode = false.obs;

  StreamSubscription<String>? _tagSubscription;

  bool get canAssign =>
      hasLocationCode.value &&
      selectedMaterials.isNotEmpty &&
      !isAssigning.value;

  @override
  void onInit() {
    super.onInit();
    locationController.addListener(_onLocationChanged);
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

  void _onLocationChanged() {
    hasLocationCode.value = locationController.text.trim().isNotEmpty;
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty) return;
    locationController.text = tag;
    locationController.selection = TextSelection.collapsed(offset: tag.length);
    _focusLocationField();
    rfidService.beep(success: true);
  }

  void _focusLocationField() {
    if (locationFocusNode.canRequestFocus) {
      locationFocusNode.requestFocus();
    }
  }

  Future<void> scanLocationQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      locationController.text = code;
      _focusLocationField();
    }
  }

  Future<void> onSourceChanged(MaterialInwardSource? source) async {
    selectedSource.value = source;
    selectedMaterials.clear();
    availableMaterials.clear();
    materialSearchController.clear();

    if (source == null) return;

    isLoadingMaterials.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _loadMaterialsOnline(source.id);
      } else {
        await _loadMaterialsOffline(source.id);
      }
    } finally {
      isLoadingMaterials.value = false;
    }
  }

  /// Only API used on source select:
  /// GET GetAllMaterialByInwardTypeId/{Id}?onlyTaggedPendingLocation=true
  Future<void> _loadMaterialsOnline(int sourceId) async {
    try {
      final materials = await materialRepository.getAllMaterialByInwardTypeId(
        sourceId,
        onlyTaggedPendingLocation: true,
      );
      availableMaterials.assignAll(materials);
      await sqliteService.replaceAssignLocationMaterials(sourceId, materials);
    } on DioException catch (e) {
      final cached = await sqliteService.getAssignLocationMaterials(sourceId);
      if (cached.isNotEmpty) {
        availableMaterials.assignAll(cached);
        return;
      }
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.fetchFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchMaterialsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      final cached = await sqliteService.getAssignLocationMaterials(sourceId);
      if (cached.isNotEmpty) {
        availableMaterials.assignAll(cached);
        return;
      }
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadMaterialsOffline(int sourceId) async {
    final cached = await sqliteService.getAssignLocationMaterials(sourceId);
    if (cached.isNotEmpty) {
      availableMaterials.assignAll(cached);
      return;
    }
    Get.snackbar(
      AppStrings.fetchFailed,
      AppStrings.noOfflineMaterialsForSource,
      snackPosition: SnackPosition.BOTTOM,
    );
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
    if (availableMaterials.isEmpty) {
      Get.snackbar(
        AppStrings.noMaterialsFound,
        AppStrings.noMaterialsForSelectedSource,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to<List<MaterialByInwardTypeModel>>(
      () => const MaterialMultiSelectSearchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MaterialMultiSelectSearchController());
      }),
      arguments: {
        'materials': availableMaterials.toList(),
        'selected': selectedMaterials.toList(),
      },
    );

    if (result == null) return;
    selectedMaterials.assignAll(result);
    materialSearchController.text = result.isEmpty
        ? ''
        : AppStrings.materialsSelectedCount(result.length);
  }

  void removeSelectedMaterial(MaterialByInwardTypeModel material) {
    selectedMaterials.removeWhere(
      (item) => item.selectionKey == material.selectionKey,
    );
    materialSearchController.text = selectedMaterials.isEmpty
        ? ''
        : AppStrings.materialsSelectedCount(selectedMaterials.length);
  }

  Future<void> assignLocationWithMaterial() async {
    final locationCode = locationController.text.trim();
    if (locationCode.isEmpty) {
      Get.snackbar(
        AppStrings.locationRequired,
        AppStrings.enterLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedMaterials.isEmpty) {
      Get.snackbar(
        AppStrings.materialRequired,
        AppStrings.selectMaterialFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // LinkMaterialLocation body: selected material row ids from
    // GetAllMaterialByInwardTypeId?onlyTaggedPendingLocation=true
    final materialIds = selectedMaterials
        .map((item) => item.materialId)
        .where((id) => id > 0)
        .toSet()
        .toList();

    if (materialIds.isEmpty) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.unableToAssignMaterialLocation,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isAssigning.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _assignOnline(locationCode, materialIds);
      } else {
        await _assignOffline(locationCode, materialIds);
      }
    } finally {
      isAssigning.value = false;
    }
  }

  Future<void> _assignOnline(String locationCode, List<int> materialIds) async {
    try {
      final response = await materialRepository.linkMaterialLocation(
        locationCode: locationCode,
        detailIds: materialIds,
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
        await _assignOffline(locationCode, materialIds);
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
    List<int> materialIds,
  ) async {
    await sqliteService.insertPendingLinkLocation(
      PendingMaterialLinkLocationModel(
        locationCode: locationCode,
        detailIds: materialIds,
        tagCode: selectedMaterials.map((item) => item.code).join(','),
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
    selectedSource.value = null;
    availableMaterials.clear();
    selectedMaterials.clear();
    locationController.clear();
    materialSearchController.clear();
    hasLocationCode.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusLocationField();
    });
  }

  @override
  void onClose() {
    locationController.removeListener(_onLocationChanged);
    _tagSubscription?.cancel();
    rfidService.disconnect();
    locationFocusNode.dispose();
    locationController.dispose();
    materialSearchController.dispose();
    super.onClose();
  }
}
