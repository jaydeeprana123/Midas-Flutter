import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Controllers/deassign_asset_tag_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class DeassignAssetTagView extends GetView<DeassignAssetTagController> {
  const DeassignAssetTagView({super.key});

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
                  child: Column(
                    children: [
                      _TagField(),
                      const SizedBox(height: 22),
                      Obx(() {
                        if (controller.identityAsset.value != null) {
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
                        final asset = controller.identityAsset.value;
                        if (asset == null) return const SizedBox.shrink();

                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            _DetailField(
                              label: AppStrings.assetName,
                              value: asset.assetName,
                            ),
                            const SizedBox(height: 16),
                            _DetailField(
                              label: AppStrings.assetCode,
                              value: asset.assetCode,
                            ),
                            const SizedBox(height: 16),
                            _DetailField(
                              label: AppStrings.serialNo,
                              value: asset.serialNo,
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton(
                              onPressed: controller.isDeassigning.value
                                  ? null
                                  : controller.deassignTag,
                              child: controller.isDeassigning.value
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(AppStrings.deAssignAssetTag),
                            ),
                          ],
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
          Text(AppStrings.deAssignAssetTag, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _TagField extends GetView<DeassignAssetTagController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.tagController,
            style: AppTextStyles.body(color: Colors.black87),
            decoration: InputDecoration(
              labelText: AppStrings.scanQrOrPressButton,
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
          onTap: controller.scanQr,
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

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: value.isEmpty,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: AppTextStyles.body(color: Colors.black54),
      ),
      child: Text(
        value.isNotEmpty ? value : AppStrings.emptyValue,
        style: AppTextStyles.body(color: Colors.black87),
      ),
    );
  }
}
