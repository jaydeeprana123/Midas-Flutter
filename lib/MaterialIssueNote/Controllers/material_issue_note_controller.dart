import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/MaterialIssueNote/Models/add_material_issue_note_request.dart';
import 'package:midas/MaterialIssueNote/Models/indent_no_model.dart';
import 'package:midas/MaterialIssueNote/Models/indent_type_model.dart';
import 'package:midas/MaterialIssueNote/Models/material_issue_line_item.dart';
import 'package:midas/MaterialIssueNote/material_issue_note_repository.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class MaterialIssueNoteController extends GetxController {
  MaterialIssueNoteController({required this.repository});

  final MaterialIssueNoteRepository repository;

  final remarksController = TextEditingController();
  final departmentController = TextEditingController();
  final issueNoteDateController = TextEditingController();

  final issueNoteNo = ''.obs;
  final issueNoteDate = DateTime.now().obs;

  final indentTypes = <IndentTypeModel>[].obs;
  final indentNos = <IndentNoModel>[].obs;
  final materialLines = <MaterialIssueLineItem>[].obs;

  final selectedIndentType = Rxn<IndentTypeModel>();
  final selectedIndentNo = Rxn<IndentNoModel>();

  final isLoadingIssueNo = false.obs;
  final isLoadingIndentTypes = false.obs;
  final isLoadingIndentNos = false.obs;
  final isLoadingMaterials = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setIssueNoteDate(DateTime.now());
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      generateIssueNoteNumber(),
      fetchIndentTypes(),
    ]);
  }

  Future<void> generateIssueNoteNumber() async {
    isLoadingIssueNo.value = true;
    try {
      final number = await repository.generateMaterialIssueNoteNumber();
      issueNoteNo.value = number;
      if (number.isEmpty) {
        Get.snackbar(
          AppStrings.fetchFailed,
          AppStrings.unableToGenerateIssueNoteNo,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      _showApiSnackbar(AppStrings.fetchFailed, e, AppStrings.unableToGenerateIssueNoteNo);
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToGenerateIssueNoteNo,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingIssueNo.value = false;
    }
  }

  Future<void> fetchIndentTypes() async {
    isLoadingIndentTypes.value = true;
    try {
      final list = await repository.getAllIndentTypes();
      indentTypes.assignAll(list);
    } on DioException catch (e) {
      _showApiSnackbar(
        AppStrings.fetchFailed,
        e,
        AppStrings.unableToFetchIndentTypes,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchIndentTypes,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingIndentTypes.value = false;
    }
  }

  Future<void> onIndentTypeChanged(IndentTypeModel? type) async {
    selectedIndentType.value = type;
    selectedIndentNo.value = null;
    indentNos.clear();
    departmentController.clear();
    _clearMaterialLines();

    if (type == null) return;

    isLoadingIndentNos.value = true;
    try {
      final list = await repository.getAllIndentNoByIndentTypeId(type.id);
      indentNos.assignAll(list);
      if (list.isEmpty) {
        Get.snackbar(
          AppStrings.noIndentNosFound,
          AppStrings.noIndentNosForSelectedType,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      _showApiSnackbar(
        AppStrings.fetchFailed,
        e,
        AppStrings.unableToFetchIndentNos,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchIndentNos,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingIndentNos.value = false;
    }
  }

  Future<void> onIndentNoChanged(IndentNoModel? indent) async {
    selectedIndentNo.value = indent;
    departmentController.clear();
    _clearMaterialLines();

    if (indent == null) return;

    isLoadingMaterials.value = true;
    try {
      final result = await repository.getMaterialIndentById(indent.id);
      if (result == null) {
        Get.snackbar(
          AppStrings.fetchFailed,
          AppStrings.unableToFetchMaterialIndent,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      departmentController.text = result.department;
      materialLines.assignAll(
        result.details.map(MaterialIssueLineItem.fromDetail).toList(),
      );

      if (materialLines.isEmpty) {
        Get.snackbar(
          AppStrings.noMaterialsFound,
          AppStrings.noMaterialsForSelectedIndent,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      _showApiSnackbar(
        AppStrings.fetchFailed,
        e,
        AppStrings.unableToFetchMaterialIndent,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchMaterialIndent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMaterials.value = false;
    }
  }

  Future<void> pickIssueNoteDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: issueNoteDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      _setIssueNoteDate(selected);
    }
  }

  void _setIssueNoteDate(DateTime date) {
    issueNoteDate.value = date;
    issueNoteDateController.text = _formatDate(date);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> submit() async {
    if (issueNoteNo.value.trim().isEmpty) {
      Get.snackbar(
        AppStrings.issueNoteNoRequired,
        AppStrings.unableToGenerateIssueNoteNo,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final indentType = selectedIndentType.value;
    if (indentType == null) {
      Get.snackbar(
        AppStrings.indentTypeRequired,
        AppStrings.selectIndentTypeFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final indentNo = selectedIndentNo.value;
    if (indentNo == null) {
      Get.snackbar(
        AppStrings.indentNoRequired,
        AppStrings.selectIndentNoFirst,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (materialLines.isEmpty) {
      Get.snackbar(
        AppStrings.materialDetailsRequired,
        AppStrings.noMaterialsForSelectedIndent,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    var hasQtyError = false;
    for (final line in materialLines) {
      if (!line.validateForSubmit()) {
        hasQtyError = true;
      }
    }
    if (hasQtyError) {
      Get.snackbar(
        AppStrings.invalidIssuedQty,
        AppStrings.issuedQtyValidationMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final request = AddMaterialIssueNoteRequest(
      indentTypeId: indentType.id,
      indentId: indentNo.id,
      issueNoteNo: issueNoteNo.value.trim(),
      issueNoteDate: issueNoteDate.value,
      remarks: remarksController.text.trim().isEmpty
          ? null
          : remarksController.text.trim(),
      materialIssueNoteDetails: materialLines
          .map(
            (line) => AddMaterialIssueNoteDetails(
              materialId: line.materialId,
              availableStock: line.availableStock,
              indentQty: line.indentQty,
              issuedQty: line.issuedQty,
              remainingQty: line.remainingQty.value,
              finalStock: line.finalStock.value,
              description: line.descriptionController.text.trim().isEmpty
                  ? null
                  : line.descriptionController.text.trim(),
              uomId: line.uomId,
            ),
          )
          .toList(),
    );

    isSubmitting.value = true;
    try {
      final response = await repository.insertMaterialIssueNote(request);
      if (response.succeeded) {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.materialIssueNoteSaved,
        );
        await _resetAfterSuccess();
      } else {
        await showAppMessageDialog(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.unableToSubmitMaterialIssueNote,
        );
      }
    } on DioException catch (e) {
      await showAppMessageDialog(_apiMessage(e, AppStrings.unableToSubmitMaterialIssueNoteRetry));
    } catch (_) {
      await showAppMessageDialog(AppStrings.unableToSubmitMaterialIssueNoteRetry);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _resetAfterSuccess() async {
    selectedIndentType.value = null;
    selectedIndentNo.value = null;
    indentNos.clear();
    departmentController.clear();
    remarksController.clear();
    _setIssueNoteDate(DateTime.now());
    _clearMaterialLines();
    await generateIssueNoteNumber();
  }

  void _clearMaterialLines() {
    final previous = List<MaterialIssueLineItem>.from(materialLines);
    materialLines.clear();
    for (final line in previous) {
      line.dispose();
    }
  }

  void _showApiSnackbar(String title, DioException error, String fallback) {
    Get.snackbar(
      title,
      _apiMessage(error, fallback),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _apiMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['Message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return fallback;
  }

  @override
  void onClose() {
    remarksController.dispose();
    departmentController.dispose();
    issueNoteDateController.dispose();
    _clearMaterialLines();
    super.onClose();
  }
}
