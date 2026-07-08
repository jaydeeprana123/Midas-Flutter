import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

Future<void> showAppMessageDialog(String message) {
  return Get.dialog<void>(
    AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Text(
        message,
        style: AppTextStyles.body(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            AppStrings.ok,
            style: AppTextStyles.button(color: AppTheme.primary),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
