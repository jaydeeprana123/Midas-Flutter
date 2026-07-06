import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Location/Controllers/assign_location_tag_controller.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';

Future<void> showAddAssetQrDialog(AssignLocationTagController controller) {
  return Get.dialog<void>(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.dialogAssetController,
                    style: AppTextStyles.body(color: Colors.black87),
                    decoration: const InputDecoration(
                      labelText: AppStrings.scanAssetQr,
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                  ),
                ),
                // const SizedBox(width: 8),
                InkWell(
                  onTap: controller.scanAssetQr,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.qr_code_scanner, size: 34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submitAssetFromDialog,
                child: const Text(AppStrings.submit),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
