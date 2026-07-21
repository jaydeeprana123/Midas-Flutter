import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Equipment/Controllers/search_tagged_equipment_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class SearchTaggedEquipmentView extends GetView<SearchTaggedEquipmentController> {
  const SearchTaggedEquipmentView({super.key});

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
                        labelText: AppStrings.equipmentNameOrCode,
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
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends GetView<SearchTaggedEquipmentController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.allEquipment.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.allEquipment.isEmpty) {
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
            AppStrings.startTypingToSearchEquipment,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      if (controller.filteredEquipment.isEmpty) {
        return Center(
          child: Text(
            AppStrings.noResultsFound,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.filteredEquipment.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final equipment = controller.filteredEquipment[index];
          return ListTile(
            title: Text(
              equipment.displayLabel,
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w600,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            onTap: () => controller.selectEquipment(equipment),
          );
        },
      );
    });
  }
}
