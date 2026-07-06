import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Controllers/asset_search_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class AssetSearchView extends GetView<AssetSearchController> {
  const AssetSearchView({super.key});

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
                        labelText: AppStrings.assetNameOrCode,
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

class _ResultsList extends GetView<AssetSearchController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!controller.hasQuery.value) {
        return Center(
          child: Text(
            AppStrings.typeToSearchAssets,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }
      if (controller.results.isEmpty) {
        return Center(
          child: Text(
            AppStrings.noAssetsFound,
            style: AppTextStyles.body(color: Colors.black54),
          ),
        );
      }
      return ListView.separated(
        itemCount: controller.results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final asset = controller.results[index];
          return ListTile(
            title: Text(
              asset.displayLabel,
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w600,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            onTap: () => controller.selectAsset(asset),
          );
        },
      );
    });
  }
}
