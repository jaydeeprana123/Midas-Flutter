import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/change_location_by_location_controller.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/location_change_type.dart';
import 'package:midas/Location/Views/destination_location_dialog.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class ChangeLocationByLocationView
    extends GetView<ChangeLocationByLocationController> {
  const ChangeLocationByLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Obx(() {
                    if (!controller.hasFetchedDetails.value) {
                      return _FetchSection();
                    }
                    return _DetailsSection();
                  }),
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
            AppStrings.assetTrackingSystem,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle(),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.changeLocationByLocation,
            textAlign: TextAlign.center,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _FetchSection extends GetView<ChangeLocationByLocationController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.sourceLocationController,
                style: AppTextStyles.body(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: AppStrings.scanSourceLocation,
                  prefixIcon: const Icon(Icons.qr_code_2),
                  suffixIcon: Obx(
                    () => controller.isRfidConnected.value
                        ? const Tooltip(
                            message: AppStrings.rfidReaderConnected,
                            child: Icon(Icons.sensors, color: AppTheme.primary),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 12),
            InkWell(
              onTap: controller.scanSourceQr,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.qr_code_scanner, size: 34),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isFetching.value
                ? null
                : controller.fetchDetails,
            child: controller.isFetching.value
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(AppStrings.fetchDetails),
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends GetView<ChangeLocationByLocationController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => Row(
            children: [
              Expanded(
                child: RadioListTile<LocationChangeType>(
                  title: Text(
                    AppStrings.shift,
                    style: AppTextStyles.body(color: Colors.black87),
                  ),
                  value: LocationChangeType.shift,
                  groupValue: controller.changeType.value,
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: controller.isLoadingRemarks.value
                      ? null
                      : (value) {
                          if (value != null) {
                            controller.onChangeTypeSelected(value);
                          }
                        },
                ),
              ),
              Expanded(
                child: RadioListTile<LocationChangeType>(
                  title: Text(
                    AppStrings.transit,
                    style: AppTextStyles.body(color: Colors.black87),
                  ),
                  value: LocationChangeType.transit,
                  groupValue: controller.changeType.value,
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: controller.isLoadingRemarks.value
                      ? null
                      : (value) {
                          if (value != null) {
                            controller.onChangeTypeSelected(value);
                          }
                        },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.remarks,
          style: AppTextStyles.body(
            color: Colors.black87,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingRemarks.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return DropdownButtonFormField<ChangeLocationRemarkModel>(
            value: controller.selectedRemark.value,
            decoration: const InputDecoration(
              labelText: AppStrings.selectRemarks,
            ),
            items: controller.remarks
                .map(
                  (remark) => DropdownMenuItem(
                    value: remark,
                    child: Text(
                      remark.name,
                      style: AppTextStyles.body(color: Colors.black87),
                    ),
                  ),
                )
                .toList(),
            onChanged: controller.changeType.value == null
                ? null
                : (value) => controller.selectedRemark.value = value,
          );
        }),
        const SizedBox(height: 16),
        TextField(
          controller: controller.searchController,
          style: AppTextStyles.body(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: AppStrings.assetNameOrTagCode,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.assetsDetails,
                  style: AppTextStyles.body(
                    color: Colors.black87,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              Checkbox(
                value: controller.allFilteredSelected,
                activeColor: AppTheme.primary,
                onChanged: controller.filteredAssets.isEmpty
                    ? null
                    : controller.toggleSelectAll,
              ),
            ],
          ),
        ),
        Obx(() {
          final assets = controller.filteredAssets;
          if (assets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppStrings.noAssetsFound,
                style: AppTextStyles.body(color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final asset = assets[index];
              final isSelected = controller.selectedTagCodes.contains(
                asset.tagCode,
              );
              return CheckboxListTile(
                value: isSelected,
                activeColor: AppTheme.primary,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text(
                  asset.assetName,
                  style: AppTextStyles.body(
                    color: Colors.black87,
                    weight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  asset.tagCode,
                  style: AppTextStyles.body(color: Colors.black54),
                ),
                onChanged: (value) =>
                    controller.toggleAsset(asset.tagCode, value),
              );
            },
          );
        }),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: () async {
            if (!controller.validateChange()) return;
            controller.beginDestinationDialog();
            await showDestinationLocationDialog(controller);
            controller.endDestinationDialog();
          },
          child: const Text(AppStrings.change),
        ),
      ],
    );
  }
}
