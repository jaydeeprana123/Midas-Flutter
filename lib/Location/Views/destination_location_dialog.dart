import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/change_location_by_location_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

Future<void> showDestinationLocationDialog(
  ChangeLocationByLocationController controller,
) {
  return Get.dialog<void>(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.destinationLocationController,
              style: AppTextStyles.body(color: Colors.black87),
              decoration: InputDecoration(
                label: Text(
                  AppStrings.scanDestinationLocationQr,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.body(color: Colors.black54),
                ),
                floatingLabelStyle: AppTextStyles.body(color: AppTheme.primary),
                floatingLabelAlignment: FloatingLabelAlignment.start,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: const Icon(Icons.qr_code_2),
                suffixIcon: IconButton(
                  onPressed: controller.scanDestinationQr,
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  tooltip: AppStrings.scanQrBarcode,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submitDestinationLocation,
                child: controller.isSubmitting.value
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
          ],
        ),
      ),
    ),
    barrierDismissible: !controller.isSubmitting.value,
  );
}
