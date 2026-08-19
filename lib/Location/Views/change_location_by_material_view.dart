import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/change_location_by_material_controller.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/location_change_type.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class ChangeLocationByMaterialView
    extends GetView<ChangeLocationByMaterialController> {
  const ChangeLocationByMaterialView({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChangeTypeSection(),
                    Obx(() {
                      if (!controller.hasChangeType) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          _RemarksSection(),
                        ],
                      );
                    }),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: controller.openMaterialScanScreen,
                      child: const Text(AppStrings.scanMaterialQr),
                    ),
                    Obx(() {
                      if (controller.selectedMaterials.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _SelectedMaterialsList(),
                        ],
                      );
                    }),
                    Obx(() {
                      if (!controller.isShift) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _DestinationField(),
                        ],
                      );
                    }),
                    Obx(() {
                      if (controller.selectedMaterials.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 22),
                          _UpdateButton(),
                        ],
                      );
                    }),
                  ],
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
            AppStrings.changeLocationByMaterial,
            textAlign: TextAlign.center,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _ChangeTypeSection extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
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
    );
  }
}

class _RemarksSection extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
    );
  }
}

class _SelectedMaterialsList extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.selectedMaterials.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final material = controller.selectedMaterials[index];
          final tagCode = material.tagCode.trim();
          final location = material.displayLocation;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.displayLabel,
                        style: AppTextStyles.body(
                          color: Colors.black87,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (tagCode.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.tagCode} : $tagCode',
                          style: AppTextStyles.body(color: Colors.black87),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.currentLocation} :',
                        style: AppTextStyles.body(
                          color: Colors.black54,
                          weight: FontWeight.w600,
                        ),
                      ),
                      if (location.isNotEmpty && location != '-') ...[
                        const SizedBox(height: 2),
                        Text(
                          location,
                          style: AppTextStyles.body(color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeSelectedMaterialAt(index),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                  ),
                  tooltip: AppStrings.removeMaterial,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DestinationField extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.destinationLocationController,
            style: AppTextStyles.body(color: Colors.black87),
            decoration: InputDecoration(
              labelText: AppStrings.scanDestinationLocationQr,
              alignLabelWithHint: true,
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
        InkWell(
          onTap: controller.scanDestinationQr,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.qr_code_scanner, size: 34),
          ),
        ),
      ],
    );
  }
}

class _UpdateButton extends GetView<ChangeLocationByMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isUpdating.value
            ? null
            : controller.updateMaterialLocation,
        child: controller.isUpdating.value
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(AppStrings.update),
      ),
    );
  }
}
