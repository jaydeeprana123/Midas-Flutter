import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';
import 'package:midas/presentation/controllers/login_controller.dart';

Future<void> showDomainSelectionDialog(LoginController controller) async {
  final domains = await controller.fetchDomains();
  final tempValue = controller.selectedDomain.value.obs;

  if (domains.isEmpty) {
    Get.snackbar('No Domains', 'No domain list returned from server.',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  await Get.dialog<void>(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: domains
                        .map(
                          (domain) => RadioListTile<String>(
                            value: domain.url,
                            groupValue: tempValue.value,
                            onChanged: (v) {
                              if (v != null) tempValue.value = v;
                            },
                            title: Text(domain.url, style: AppTextStyles.body()),
                            activeColor: AppTheme.primary,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (tempValue.value.isNotEmpty) {
                  await controller.saveDomain(tempValue.value);
                }
                Get.back();
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Text(
                'Mac Address : ${controller.macAddress.value}',
                style: AppTextStyles.body(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
