import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/material_multi_select_search_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class MaterialMultiSelectSearchView
    extends GetView<MaterialMultiSelectSearchController> {
  const MaterialMultiSelectSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                      controller: controller.searchController,
                      autofocus: true,
                      onChanged: controller.onQueryChanged,
                      style: AppTextStyles.body(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: AppStrings.selectMaterial,
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
            Expanded(child: _ResultsList()),
            Obx(() {
              if (!controller.canSubmit) return const SizedBox.shrink();
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.submit,
                      child: Text(
                        '${AppStrings.submit} (${controller.selectedKeys.length})',
                      ),
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

class _ResultsList extends GetView<MaterialMultiSelectSearchController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.allMaterials.isEmpty) {
        return Center(
          child: Text(
            AppStrings.noMaterialsFound,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      if (controller.filteredMaterials.isEmpty) {
        return Center(
          child: Text(
            controller.hasQuery.value
                ? AppStrings.noResultsFound
                : AppStrings.startTypingToSearchMaterial,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      // Read selection inside Obx (not only in itemBuilder) so toggles rebuild.
      final selectedSnapshot = Set<String>.from(controller.selectedKeys);

      return ListView.separated(
        itemCount: controller.filteredMaterials.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final material = controller.filteredMaterials[index];
          final selected = selectedSnapshot.contains(material.selectionKey);
          return CheckboxListTile(
            key: ValueKey('${material.selectionKey}-$selected'),
            value: selected,
            onChanged: (_) => controller.toggleSelection(material),
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
            subtitle: material.listSubtitle.isEmpty
                ? null
                : Text(
                    material.listSubtitle,
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
