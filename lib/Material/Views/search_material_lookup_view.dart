import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/search_material_lookup_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class SearchMaterialLookupView extends GetView<SearchMaterialLookupController> {
  const SearchMaterialLookupView({super.key});

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
                      focusNode: controller.searchFocusNode,
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
            const Expanded(child: _ResultsList()),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends GetView<SearchMaterialLookupController> {
  const _ResultsList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.allMaterials.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.allMaterials.isEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      if (!controller.hasQuery.value) {
        return Center(
          child: Text(
            AppStrings.startTypingToSearchMaterial,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      if (controller.filteredMaterials.isEmpty) {
        return Center(
          child: Text(
            AppStrings.noResultsFound,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.filteredMaterials.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final material = controller.filteredMaterials[index];
          return ListTile(
            title: Text(
              material.displayLabel,
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w600,
              ),
            ),
            subtitle: material.uom == null || material.uom!.isEmpty
                ? null
                : Text(
                    material.uom!,
                    style: AppTextStyles.body(color: Colors.black54),
                  ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            onTap: () => controller.selectMaterial(material),
          );
        },
      );
    });
  }
}
