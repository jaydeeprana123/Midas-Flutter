import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Material/Models/pending_material_link_location_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

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
  final selectedMaterial = Rxn<MaterialByInwardTypeModel>();

  /// Response from GetAllTaggedMaterialdataByMaterialId for the selected material.
  final taggedMaterials = <MaterialByInwardTypeModel>[].obs;

  final isLoadingMaterials = false.obs;
  final isLoadingTaggedMaterials = false.obs;
  final isAssigning = false.obs;
  final isRfidConnected = false.obs;
  final hasLocationCode = false.obs;

  StreamSubscription<String>? _tagSubscription;

  List<String> get selectedTagCodes => taggedMaterials
      .expand((item) => item.tagCodes)
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();

  bool get canAssign =>
      hasLocationCode.value &&
      selectedMaterial.value != null &&
      selectedTagCodes.isNotEmpty &&
      !isLoadingTaggedMaterials.value &&
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
    selectedMaterial.value = null;
    taggedMaterials.clear();
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

  /// Source select API:
  /// GET GetAllMaterialByInwardTypeId/{Id}
  Future<void> _loadMaterialsOnline(int sourceId) async {
    try {
      final materials = await materialRepository.getAllMaterialByInwardTypeId(
        sourceId,
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

    final result = await Get.toNamed(
      AppRoutes.materialSearch,
      arguments: availableMaterials.toList(),
    );

    if (result is! MaterialByInwardTypeModel) return;

    selectedMaterial.value = result;
    materialSearchController.text = result.displayLabel;
    taggedMaterials.clear();
    await _loadTaggedMaterialsForSelection(result);
  }

  /// After single material selection:
  /// GET GetAllTaggedMaterialdataByMaterialId/{id}
  Future<void> _loadTaggedMaterialsForSelection(
    MaterialByInwardTypeModel material,
  ) async {
    // Requirement: pass the selected material's `id` into the path.
    final lookupId = material.materialId;
    if (lookupId <= 0) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialDetails,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoadingTaggedMaterials.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _loadTaggedMaterialsOnline(lookupId);
      } else {
        await _loadTaggedMaterialsOffline(lookupId);
      }
    } finally {
      isLoadingTaggedMaterials.value = false;
    }
  }

  Future<void> _loadTaggedMaterialsOnline(int lookupId) async {
    try {
      final result = await materialRepository.getAllTagMaterialByMaterialId(
        lookupId,
      );
      taggedMaterials.assignAll(result);
      await sqliteService.replaceTaggedMaterialsByLookupId(lookupId, result);

      if (result.isEmpty || selectedTagCodes.isEmpty) {
        Get.snackbar(
          AppStrings.fetchFailed,
          AppStrings.noTaggedMaterialsFoundForSelection,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final cached = await sqliteService.getTaggedMaterialsByLookupId(lookupId);
      if (cached.isNotEmpty) {
        taggedMaterials.assignAll(cached);
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
      final cached = await sqliteService.getTaggedMaterialsByLookupId(lookupId);
      if (cached.isNotEmpty) {
        taggedMaterials.assignAll(cached);
        return;
      }
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialDetailsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadTaggedMaterialsOffline(int lookupId) async {
    final cached = await sqliteService.getTaggedMaterialsByLookupId(lookupId);
    if (cached.isNotEmpty) {
      taggedMaterials.assignAll(cached);
      return;
    }
    Get.snackbar(
      AppStrings.fetchFailed,
      AppStrings.noOfflineTaggedMaterialsForSelection,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearSelectedMaterial() {
    selectedMaterial.value = null;
    taggedMaterials.clear();
    materialSearchController.clear();
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
    if (selectedMaterial.value == null) {
      Get.snackbar(
        AppStrings.materialRequired,
        AppStrings.selectMaterialFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final tagCodes = selectedTagCodes;
    if (tagCodes.isEmpty) {
      Get.snackbar(
        AppStrings.assignFailed,
        AppStrings.noTaggedMaterialsFoundForSelection,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isAssigning.value = true;
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _assignOnline(locationCode, tagCodes);
      } else {
        await _assignOffline(locationCode, tagCodes);
      }
    } finally {
      isAssigning.value = false;
    }
  }

  Future<void> _assignOnline(String locationCode, List<String> tagCodes) async {
    try {
      final response = await materialRepository.linkMaterialLocation(
        locationCode: locationCode,
        tagCodes: tagCodes,
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
        await _assignOffline(locationCode, tagCodes);
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
    List<String> tagCodes,
  ) async {
    await sqliteService.insertPendingLinkLocation(
      PendingMaterialLinkLocationModel(
        locationCode: locationCode,
        tagCodes: tagCodes,
        tagCode: tagCodes.join(','),
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
    selectedMaterial.value = null;
    taggedMaterials.clear();
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
