import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/change_location_by_asset_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class ScanAssetQrChangeLocationView
    extends GetView<ChangeLocationByAssetController> {
  const ScanAssetQrChangeLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.scanAssetTagController,
                        style: AppTextStyles.body(color: Colors.black87),
                        onSubmitted: (value) {
                          if (controller.addPendingTag(value)) {
                            controller.scanAssetTagController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: AppStrings.scanAssetQrOrPressButton,
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.qr_code_2),
                          suffixIcon: Obx(
                            () => controller.isRfidConnected.value
                                ? const Tooltip(
                                    message: AppStrings.rfidReaderConnected,
                                    child: Icon(
                                      Icons.sensors,
                                      color: AppTheme.primary,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: controller.scanAssetTagQr,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.qr_code_scanner, size: 34),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.pendingTagCodes.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.pendingTagCodes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tag = controller.pendingTagCodes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tag,
                              style: AppTextStyles.body(color: Colors.black87),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.removePendingTag(index),
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: AppStrings.removeAsset,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmittingBulk.value
                      ? null
                      : controller.submitBulkIdentity,
                  child: controller.isSubmittingBulk.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(AppStrings.submit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
