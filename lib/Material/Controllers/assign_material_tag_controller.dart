import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Views/qr_scanner_view.dart';
import 'package:midas/Material/Models/add_material_tagging_request.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

class AssignMaterialTagController extends GetxController {
  AssignMaterialTagController({
    required this.materialRepository,
    required this.rfidService,
  });

  final MaterialRepository materialRepository;
  final RfidService rfidService;

  final materialController = TextEditingController();
  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();

  final selectedSource = Rxn<MaterialInwardSource>();
  final selectedMaterial = Rxn<MaterialByInwardTypeModel>();
  final materials = <MaterialByInwardTypeModel>[].obs;

  final isLoadingMaterials = false.obs;
  final isSubmitting = false.obs;
  final isRfidConnected = false.obs;

  StreamSubscription<String>? _tagSubscription;

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

  Future<void> onSourceChanged(MaterialInwardSource? source) async {
    selectedSource.value = source;
    selectedMaterial.value = null;
    materialController.clear();
    materials.clear();

    if (source == null) return;

    isLoadingMaterials.value = true;
    try {
      final result = await materialRepository.getAllMaterialByInwardTypeId(
        source.id,
      );
      materials.assignAll(result);
    } on DioException catch (e) {
      final data = e.response?.data;
      Get.snackbar(
        AppStrings.fetchFailed,
        data is Map && data['message'] != null
            ? data['message'].toString()
            : AppStrings.unableToFetchMaterialsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMaterials.value = false;
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

    isSubmitting.value = true;
    try {
      final response = await materialRepository.insertMaterialTagging(
        AddMaterialTaggingRequest(
          inwardTypeId: source.id,
          inwardId: material.id > 0 ? material.id : null,
          materialId: material.materialId,
          quantity: 1,
          materialTagingDetails: [
            AddMaterialTaggingDetails(tagCode: tag),
          ],
        ),
      );

      if (response.succeeded) {
        Get.snackbar(
          AppStrings.success,
          response.message.isNotEmpty
              ? response.message
              : AppStrings.materialTagAssignedSuccessfully,
          snackPosition: SnackPosition.BOTTOM,
        );
        _resetForm();
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
    } finally {
      isSubmitting.value = false;
    }
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
