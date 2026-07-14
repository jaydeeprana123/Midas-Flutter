import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/theme/app_theme.dart';

/// Shows a blocking, non-dismissible loading indicator overlay.
/// Pair every [showAppLoadingDialog] with a [hideAppLoadingDialog].
void showAppLoadingDialog() {
  if (Get.isDialogOpen ?? false) return;
  Get.dialog<void>(
    const PopScope(
      canPop: false,
      child: Center(
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: SizedBox(
              height: 42,
              width: 42,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

/// Dismisses the loading overlay shown by [showAppLoadingDialog], if any.
void hideAppLoadingDialog() {
  if (Get.isDialogOpen ?? false) Get.back();
}
