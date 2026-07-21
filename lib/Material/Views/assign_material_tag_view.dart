import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/assign_material_tag_controller.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class AssignMaterialTagView extends GetView<AssignMaterialTagController> {
  const AssignMaterialTagView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => DropdownButtonFormField<MaterialInwardSource>(
                          value: controller.selectedSource.value,
                          decoration: const InputDecoration(
                            labelText: AppStrings.selectSource,
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          hint: Text(
                            AppStrings.selectSource,
                            style: AppTextStyles.body(color: Colors.black54),
                          ),
                          items: MaterialInwardSource.valuesInOrder
                              .map(
                                (source) => DropdownMenuItem(
                                  value: source,
                                  child: Text(
                                    source.label,
                                    style: AppTextStyles.body(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isLoadingMaterials.value
                              ? null
                              : controller.onSourceChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextField(
                          controller: controller.materialController,
                          readOnly: true,
                          onTap: controller.openMaterialSearch,
                          style: AppTextStyles.body(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: AppStrings.selectMaterial,
                            hintText: AppStrings.searchSelectMaterial,
                            prefixIcon: controller.isLoadingMaterials.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.search),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TagField(),
                      const SizedBox(height: 22),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.assignTag,
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(AppStrings.assignTag),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
            AppStrings.assignTag,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _TagField extends GetView<AssignMaterialTagController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.tagController,
      focusNode: controller.tagFocusNode,
      textInputAction: TextInputAction.done,
      style: AppTextStyles.body(color: Colors.black87),
      decoration: InputDecoration(
        labelText: AppStrings.scanEnterTag,
        hintText: AppStrings.scanTagHere,
        prefixIcon: const Icon(Icons.qr_code_2),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => controller.isRfidConnected.value
                  ? const Tooltip(
                      message: AppStrings.rfidReaderConnected,
                      child: Icon(Icons.sensors, color: AppTheme.primary),
                    )
                  : const SizedBox.shrink(),
            ),
            IconButton(
              onPressed: controller.scanQr,
              tooltip: AppStrings.scanQrBarcode,
              icon: const Icon(Icons.qr_code_scanner, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
