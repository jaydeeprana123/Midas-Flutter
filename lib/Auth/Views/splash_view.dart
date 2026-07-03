import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Auth/Controllers/splash_controller.dart';
import 'package:midas/app/constants/app_assets.dart';
import 'package:midas/app/theme/app_theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure splash controller is created so onReady navigation runs.
    controller;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Image.asset(
          AppAssets.appIcon,
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}
