import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

Future<bool?> showDelinkConfirmationDialog() {
  return Get.dialog<bool>(
    AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppStrings.confirmDelink,
        style: AppTextStyles.body(
          color: Colors.black87,
          weight: FontWeight.w700,
        ),
      ),
      content: Text(
        AppStrings.confirmDelinkEquipmentMessage,
        style: AppTextStyles.body(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            AppStrings.no,
            style: AppTextStyles.button(color: AppTheme.primary),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            AppStrings.yes,
            style: AppTextStyles.button(color: AppTheme.primary),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
