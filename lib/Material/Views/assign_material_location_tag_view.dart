import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Controllers/assign_material_location_tag_controller.dart';
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
                            _LocationField(),
                            const SizedBox(height: 16),
                            _MaterialTagField(),
                            const SizedBox(height: 22),
                            Obx(() {
                              if (controller.materialDetails.value != null) {
                                return const SizedBox.shrink();
                              }
                              return ElevatedButton(
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
                              );
                            }),
                            Obx(() {
                              final details = controller.materialDetails.value;
                              if (details == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _MaterialDetailsCard(
                                  materialName: details.materialName,
                                  materialCode: details.materialCode,
                                  tagCode: details.tagCode,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.materialDetails.value == null) {
                return const SizedBox.shrink();
              }
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isAssigning.value
                          ? null
                          : controller.assignLocationWithMaterial,
                      child: controller.isAssigning.value
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
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => controller.materialTagFocusNode.requestFocus(),
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

class _MaterialTagField extends GetView<AssignMaterialLocationTagController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.materialTagController,
      focusNode: controller.materialTagFocusNode,
      textInputAction: TextInputAction.done,
      style: AppTextStyles.body(color: Colors.black87),
      decoration: InputDecoration(
        labelText: AppStrings.scanMaterialTagQr,
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
              onPressed: controller.scanMaterialTagQr,
              tooltip: AppStrings.scanQrBarcode,
              icon: const Icon(Icons.qr_code_scanner, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialDetailsCard extends StatelessWidget {
  const _MaterialDetailsCard({
    required this.materialName,
    required this.materialCode,
    required this.tagCode,
  });

  final String materialName;
  final String materialCode;
  final String tagCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.materialDetails,
            style: AppTextStyles.body(
              color: Colors.black87,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: AppStrings.materialNameLabel, value: materialName),
          const SizedBox(height: 8),
          _DetailRow(label: AppStrings.materialCodeLabel, value: materialCode),
          const SizedBox(height: 8),
          _DetailRow(label: AppStrings.tagCodeLabel, value: tagCode),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: AppTextStyles.body(
              color: AppTheme.primary,
              weight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value.isEmpty ? AppStrings.emptyValue : value,
            style: AppTextStyles.body(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
