import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Controllers/assign_asset_tag_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class AssignAssetTagView extends GetView<AssignAssetTagController> {
  const AssignAssetTagView({super.key});

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
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: 2,
                        minLines: 1,
                        controller: controller.assetController,
                        readOnly: true,
                        onTap: controller.openAssetSearch,
                        style: AppTextStyles.body(color: Colors.black87),
                        decoration: const InputDecoration(
                          labelText: AppStrings.assetNameOrCode,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.serialController,
                        style: AppTextStyles.body(color: Colors.black87),
                        decoration: const InputDecoration(
                          labelText: AppStrings.assetSerialNumber,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.assignTag,
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(AppStrings.assignTag),
                        ),
                      ),
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
          Text(AppStrings.assignAssetTag, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _TagField extends GetView<AssignAssetTagController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.tagController,
            focusNode: controller.tagFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
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
