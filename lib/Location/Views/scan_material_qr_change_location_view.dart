import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/change_location_by_material_controller.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class ScanMaterialQrChangeLocationView
    extends GetView<ChangeLocationByMaterialController> {
  const ScanMaterialQrChangeLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.searchMaterialController,
                      autofocus: true,
                      onChanged: controller.onSearchQueryChanged,
                      style: AppTextStyles.body(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: AppStrings.searchMaterial,
                        hintText: AppStrings.searchSelectMaterial,
                        prefixIcon: const Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _SelectedMaterialsSection()),
                  SliverToBoxAdapter(child: _SearchResultsHeader()),
                  _SearchResultsSliver(),
                ],
              ),
            ),
            Obx(() {
              if (!controller.canSubmitSelectedMaterials) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: controller.submitSelectedMaterials,
                  child: const Text(AppStrings.submit),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SelectedMaterialsSection
    extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedMaterials.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.selectedMaterialsCountLabel(
                controller.selectedMaterials.length,
              ),
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.selectedMaterials.map(
              (material) => _SelectedMaterialRow(material: material),
            ),
            const Divider(height: 24),
          ],
        ),
      );
    });
  }
}

class _SelectedMaterialRow extends GetView<ChangeLocationByMaterialController> {
  const _SelectedMaterialRow({required this.material});

  final MaterialTaggingDetailModel material;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: true,
      onChanged: (_) => controller.removeSelectedMaterial(material),
      controlAffinity: ListTileControlAffinity.leading,
      checkColor: Colors.white,
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.primary;
        }
        return Colors.white;
      }),
      side: const BorderSide(color: AppTheme.primary, width: 1.6),
      title: Text(
        material.displayLabel,
        style: AppTextStyles.body(
          color: Colors.black87,
          weight: FontWeight.w600,
        ),
      ),
      secondary: TextButton(
        onPressed: () => controller.removeSelectedMaterial(material),
        child: Text(
          AppStrings.remove,
          style: AppTextStyles.body(
            color: Colors.red,
            weight: FontWeight.w600,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SearchResultsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        AppStrings.searchMaterial,
        style: AppTextStyles.body(
          color: Colors.black87,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchResultsSliver extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearchingMaterials.value &&
          controller.searchResults.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.searchErrorMessage.value.isNotEmpty &&
          controller.searchResults.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                controller.searchErrorMessage.value,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: Colors.black54),
              ),
            ),
          ),
        );
      }

      if (!controller.hasSearchQuery.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              AppStrings.startTypingToSearchMaterial,
              style: AppTextStyles.body(color: Colors.black54),
            ),
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              AppStrings.noResultsFound,
              style: AppTextStyles.body(color: Colors.black54),
            ),
          ),
        );
      }

      final selectedSnapshot = {
        for (final item in controller.selectedMaterials) item.selectionKey,
      };

      return SliverList.separated(
        itemCount: controller.searchResults.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final material = controller.searchResults[index];
          final selected = selectedSnapshot.contains(material.selectionKey);
          return CheckboxListTile(
            key: ValueKey('${material.selectionKey}-$selected'),
            value: selected,
            onChanged: (_) => controller.toggleMaterialSelection(material),
            controlAffinity: ListTileControlAffinity.leading,
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primary;
              }
              return Colors.white;
            }),
            side: const BorderSide(color: AppTheme.primary, width: 1.6),
            title: Text(
              material.displayLabel,
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w600,
              ),
            ),
            subtitle: material.tagCode.trim().isEmpty
                ? null
                : Text(
                    material.tagCode,
                    style: AppTextStyles.body(color: Colors.black54),
                  ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          );
        },
      );
    });
  }
}
