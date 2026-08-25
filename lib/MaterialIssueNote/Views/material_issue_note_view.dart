import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:midas/MaterialIssueNote/Controllers/material_issue_note_controller.dart';
import 'package:midas/MaterialIssueNote/Models/indent_no_model.dart';
import 'package:midas/MaterialIssueNote/Models/indent_type_model.dart';
import 'package:midas/MaterialIssueNote/Models/material_issue_line_item.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class MaterialIssueNoteView extends GetView<MaterialIssueNoteController> {
  const MaterialIssueNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HeaderCard(),
                    const SizedBox(height: 16),
                    const _MaterialDetailsSection(),
                    const SizedBox(height: 22),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submit,
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(AppStrings.submit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Center(child: MidasToolbarLogo(height: 34)),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.materialTrackingSystem,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle(),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.materialIssueNote,
            textAlign: TextAlign.center,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends GetView<MaterialIssueNoteController> {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => _ReadOnlyField(
              label: AppStrings.issueNoteNo,
              value: controller.issueNoteNo.value,
              isLoading: controller.isLoadingIssueNo.value,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            controller: controller.issueNoteDateController,
            onTap: () => controller.pickIssueNoteDate(context),
            style: AppTextStyles.body(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: AppStrings.issueNoteDate,
              prefixIcon: Icon(Icons.calendar_today_outlined),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<IndentTypeModel>(
              key: ValueKey(
                'indent-type-${controller.selectedIndentType.value?.id ?? 0}-${controller.indentTypes.length}',
              ),
              initialValue: controller.selectedIndentType.value,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: AppStrings.indentTypeRequiredLabel,
                prefixIcon: controller.isLoadingIndentTypes.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : const Icon(Icons.category_outlined),
              ),
              hint: Text(
                AppStrings.selectIndentType,
                style: AppTextStyles.body(color: Colors.black54),
              ),
              items: controller.indentTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.displayLabel,
                        style: AppTextStyles.body(color: Colors.black87),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: controller.isLoadingIndentTypes.value
                  ? null
                  : controller.onIndentTypeChanged,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<IndentNoModel>(
              key: ValueKey(
                'indent-no-${controller.selectedIndentNo.value?.id ?? 0}-${controller.indentNos.length}',
              ),
              initialValue: controller.selectedIndentNo.value,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: AppStrings.indentNoRequiredLabel,
                prefixIcon: controller.isLoadingIndentNos.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : const Icon(Icons.tag_outlined),
              ),
              hint: Text(
                AppStrings.selectIndentNo,
                style: AppTextStyles.body(color: Colors.black54),
              ),
              items: controller.indentNos
                  .map(
                    (indent) => DropdownMenuItem(
                      value: indent,
                      child: Text(
                        indent.displayLabel,
                        style: AppTextStyles.body(color: Colors.black87),
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  controller.selectedIndentType.value == null ||
                      controller.isLoadingIndentNos.value
                  ? null
                  : controller.onIndentNoChanged,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _ReadOnlyField(
              label: AppStrings.department,
              value: controller.department.value,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.remarksController,
            minLines: 2,
            maxLines: 4,
            style: AppTextStyles.body(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: AppStrings.remarks,
              hintText: AppStrings.enterRemarks,
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialDetailsSection extends GetView<MaterialIssueNoteController> {
  const _MaterialDetailsSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMaterials.value) {
        return const _Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
        );
      }

      if (controller.materialLines.isEmpty) {
        return _Card(
          child: Text(
            AppStrings.selectIndentToLoadMaterials,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.materialIssueNoteDetails,
            style: AppTextStyles.cardTitle(),
          ),
          const SizedBox(height: 10),
          ...controller.materialLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MaterialLineCard(line: line),
            ),
          ),
        ],
      );
    });
  }
}

class _MaterialLineCard extends StatelessWidget {
  const _MaterialLineCard({required this.line});

  final MaterialIssueLineItem line;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            line.materialName.isEmpty
                ? AppStrings.materialLabel
                : line.materialName,
            style: AppTextStyles.body(
              color: Colors.black87,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(label: AppStrings.codeLabel, value: line.materialCode),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: AppStrings.uomLabel,
                  value: line.uomName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyField(
                  label: AppStrings.indentUomLabel,
                  value: line.indentUomName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: AppStrings.availableStockLabel,
                  value: _formatQty(line.availableStock),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyField(
                  label: AppStrings.indentQtyLabel,
                  value: _formatQty(line.indentQty),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: line.issuedQtyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTextStyles.body(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: AppStrings.issuedQtyLabel,
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
          Obx(() {
            if (line.qtyError.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                line.qtyError.value,
                style: AppTextStyles.body(color: Colors.red.shade700),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _ReadOnlyField(
                    label: AppStrings.remainingQtyLabel,
                    value: _formatQty(line.remainingQty.value),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _ReadOnlyField(
                    label: AppStrings.finalStockLabel,
                    value: _formatQty(line.finalStock.value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: line.descriptionController,
            minLines: 2,
            maxLines: 3,
            style: AppTextStyles.body(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: AppStrings.descriptionLabel,
              hintText: AppStrings.enterDescription,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: !isLoading && value.isEmpty,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      child: Text(
        isLoading
            ? '...'
            : (value.isEmpty ? AppStrings.emptyValue : value),
        style: AppTextStyles.body(
          color: value.isEmpty ? Colors.black38 : Colors.black87,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _formatQty(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toString();
}
