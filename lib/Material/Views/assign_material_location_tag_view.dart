import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/assign_material_location_tag_controller.dart';
import 'package:midas/Material/Models/material_inward_source.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class AssignMaterialLocationTagView
    extends GetView<AssignMaterialLocationTagController> {
  const AssignMaterialLocationTagView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                                  style:
                                      AppTextStyles.body(color: Colors.black54),
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
                            Obx(() {
                              final loadingMaterials =
                                  controller.isLoadingMaterials.value;
                              final loadingTags =
                                  controller.isLoadingTaggedMaterials.value;
                              return TextField(
                                controller: controller.materialSearchController,
                                readOnly: true,
                                onTap: controller.openMaterialSearch,
                                style:
                                    AppTextStyles.body(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: AppStrings.selectMaterial,
                                  hintText: AppStrings.searchSelectMaterial,
                                  prefixIcon: (loadingMaterials || loadingTags)
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
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (controller.selectedMaterial.value !=
                                          null)
                                        IconButton(
                                          onPressed:
                                              controller.clearSelectedMaterial,
                                          icon: const Icon(Icons.clear, size: 20),
                                        ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            Obx(() {
                              final tags = controller.selectedTagCodes;
                              if (tags.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'Tags: ${tags.join(', ')}',
                                  style: AppTextStyles.body(
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            _LocationField(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final hasSelection = controller.selectedMaterial.value != null;
              final hasLocation = controller.hasLocationCode.value;
              final tagCount = controller.selectedTagCodes.length;
              final loadingTags = controller.isLoadingTaggedMaterials.value;
              final isAssigning = controller.isAssigning.value;
              final canAssign = hasLocation &&
                  hasSelection &&
                  tagCount > 0 &&
                  !loadingTags &&
                  !isAssigning;
              if (!hasSelection) return const SizedBox.shrink();
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canAssign
                          ? controller.assignLocationWithMaterial
                          : null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: isAssigning
                            ? AppTheme.primary
                            : const Color(0xFFBDBDBD),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: isAssigning
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(AppStrings.assignLocationWithMaterial),
                    ),
                  ),
                ),
              );
            }),
          ],
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
            AppStrings.assignLocationTag,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends GetView<AssignMaterialLocationTagController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.locationController,
      focusNode: controller.locationFocusNode,
      autofocus: true,
      textInputAction: TextInputAction.done,
      style: AppTextStyles.body(color: Colors.black87),
      decoration: InputDecoration(
        labelText: AppStrings.scanLocationQrHere,
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
              onPressed: controller.scanLocationQr,
              tooltip: AppStrings.scanQrBarcode,
              icon: const Icon(Icons.qr_code_scanner, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
