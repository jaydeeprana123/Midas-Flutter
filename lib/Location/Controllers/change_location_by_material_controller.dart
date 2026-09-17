import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/Views/scan_material_qr_change_location_view.dart';
import 'package:midas/Location/location_change_type.dart';
import 'package:midas/Location/location_repository.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class ChangeLocationByMaterialController extends GetxController {
  ChangeLocationByMaterialController({
    required this.locationRepository,
    required this.materialRepository,
    required this.rfidService,
  });

  final LocationRepository locationRepository;
  final MaterialRepository materialRepository;
  final RfidService rfidService;

  final destinationLocationController = TextEditingController();
  final searchMaterialController = TextEditingController();

  final selectedMaterials = <MaterialTaggingDetailModel>[].obs;
  final searchResults = <MaterialTaggingDetailModel>[].obs;
  final remarks = <ChangeLocationRemarkModel>[].obs;
  final selectedRemark = Rxn<ChangeLocationRemarkModel>();
  final changeType = Rxn<LocationChangeType>();

  final isLoadingRemarks = false.obs;
  final isSearchingMaterials = false.obs;
  final isUpdating = false.obs;
  final isRfidConnected = false.obs;
  final isMaterialScanScreenOpen = false.obs;
  final hasSearchQuery = false.obs;
  final searchErrorMessage = ''.obs;

  StreamSubscription<String>? _tagSubscription;
  Timer? _searchDebounce;
  int _searchRequestToken = 0;

  bool get isShift => changeType.value == LocationChangeType.shift;
  bool get isTransit => changeType.value == LocationChangeType.transit;
  bool get hasChangeType => changeType.value != null;
  bool get canSubmitSelectedMaterials => selectedMaterials.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  void _onTagRead(String tag) {
    if (tag.isEmpty || isMaterialScanScreenOpen.value) return;
    if (isShift) {
      destinationLocationController.text = tag;
    }
  }

  Future<void> scanDestinationQr() async {
    final code = await Get.to<String>(() => const QrScannerView());
    if (code != null && code.isNotEmpty) {
      destinationLocationController.text = code;
    }
  }

  Future<void> onChangeTypeSelected(LocationChangeType type) async {
    if (changeType.value == type) return;
    changeType.value = type;
    selectedRemark.value = null;
    remarks.clear();
    if (!isShift) {
      destinationLocationController.clear();
    }
    await _loadRemarks();
  }

  Future<void> _loadRemarks() async {
    final type = changeType.value;
    if (type == null) return;

    isLoadingRemarks.value = true;
    try {
      final result = await locationRepository.getChangeLocationRemarks(
        isTransit: type == LocationChangeType.transit,
      );
      remarks.assignAll(result);
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
      isLoadingRemarks.value = false;
    }
  }

  Future<void> openMaterialScanScreen() async {
    isMaterialScanScreenOpen.value = true;
    final result = await Get.to<List<MaterialTaggingDetailModel>>(
      () => const ScanMaterialQrChangeLocationView(),
    );
    isMaterialScanScreenOpen.value = false;
    _clearSearchState();
    if (result != null) {
      selectedMaterials.assignAll(result);
    }
  }

  void onSearchQueryChanged(String value) {
    final query = value.trim();
    hasSearchQuery.value = query.isNotEmpty;
    searchErrorMessage.value = '';
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      searchResults.clear();
      isSearchingMaterials.value = false;
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _searchMaterials(query);
    });
  }

  Future<void> _searchMaterials(String query) async {
    final token = ++_searchRequestToken;
    isSearchingMaterials.value = true;
    searchErrorMessage.value = '';
    try {
      final materials =
          await materialRepository.searchMaterialForMobileApp(query);
      if (token != _searchRequestToken) return;
      searchResults.assignAll(materials);
    } on DioException catch (e) {
      if (token != _searchRequestToken) return;
      searchResults.clear();
      if (_isNotFound(e)) return;
      final data = e.response?.data;
      searchErrorMessage.value = data is Map && data['message'] != null
          ? data['message'].toString()
          : AppStrings.unableToFetchMaterialDetailsRetry;
    } catch (_) {
      if (token != _searchRequestToken) return;
      searchResults.clear();
      searchErrorMessage.value = AppStrings.unableToFetchMaterialDetailsRetry;
    } finally {
      if (token == _searchRequestToken) isSearchingMaterials.value = false;
    }
  }

  bool _isNotFound(DioException e) {
    final status = e.response?.statusCode;
    if (status == 404) return true;
    final data = e.response?.data;
    if (data is Map) {
      final apiStatus = data['status'];
      if (apiStatus == 404) return true;
      final message = (data['message'] ?? '').toString().toLowerCase();
      if (message.contains('not found')) return true;
    }
    return false;
  }

  void toggleMaterialSelection(MaterialTaggingDetailModel material) {
    final index = selectedMaterials.indexWhere(
      (item) => item.selectionKey == material.selectionKey,
    );
    if (index >= 0) {
      selectedMaterials.removeAt(index);
    } else {
      selectedMaterials.add(material);
    }
  }

  void removeSelectedMaterial(MaterialTaggingDetailModel material) {
    selectedMaterials.removeWhere(
      (item) => item.selectionKey == material.selectionKey,
    );
  }

  void removeSelectedMaterialAt(int index) {
    if (index < 0 || index >= selectedMaterials.length) return;
    selectedMaterials.removeAt(index);
  }

  void submitSelectedMaterials() {
    if (selectedMaterials.isEmpty) return;
    Get.back(result: List<MaterialTaggingDetailModel>.from(selectedMaterials));
  }

  Future<void> updateMaterialLocation() async {
    if (changeType.value == null) {
      Get.snackbar(
        AppStrings.changeTypeRequired,
        AppStrings.selectShiftOrTransit,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedRemark.value == null) {
      Get.snackbar(
        AppStrings.remarkRequired,
        AppStrings.selectRemarkFromDropdown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedMaterials.isEmpty) {
      Get.snackbar(
        AppStrings.selectedMaterialsRequired,
        AppStrings.selectMaterialsBeforeUpdate,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isShift && destinationLocationController.text.trim().isEmpty) {
      Get.snackbar(
        AppStrings.destinationLocationRequired,
        AppStrings.enterDestinationLocationQrRfid,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final tagCodes = selectedMaterials
        .map((material) => material.tagCode.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    if (tagCodes.isEmpty) {
      Get.snackbar(
        AppStrings.selectedMaterialsRequired,
        AppStrings.selectedMaterialsMissingTagDetails,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isUpdating.value = true;
    try {
      final response = await materialRepository.linkMaterialLocation(
        locationCode: isShift ? destinationLocationController.text.trim() : '',
        tagCodes: tagCodes,
      );

      await showAppMessageDialog(
        response.message.isNotEmpty
            ? response.message
            : response.succeeded
                ? AppStrings.locationChangedSuccessfully
                : AppStrings.unableToChangeLocation,
      );

      if (response.succeeded) {
        _resetForm();
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      await showAppMessageDialog(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToChangeLocationRetry,
      );
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToChangeLocationRetry);
    } finally {
      isUpdating.value = false;
    }
  }

  void _clearSearchState() {
    _searchDebounce?.cancel();
    searchMaterialController.clear();
    searchResults.clear();
    hasSearchQuery.value = false;
    searchErrorMessage.value = '';
    isSearchingMaterials.value = false;
  }

  void _resetForm() {
    changeType.value = null;
    selectedRemark.value = null;
    remarks.clear();
    selectedMaterials.clear();
    destinationLocationController.clear();
    _clearSearchState();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _tagSubscription?.cancel();
    rfidService.disconnect();
    destinationLocationController.dispose();
    searchMaterialController.dispose();
    super.onClose();
  }
}
