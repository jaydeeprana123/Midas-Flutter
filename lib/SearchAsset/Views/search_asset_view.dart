import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/SearchAsset/Controllers/search_asset_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class SearchAssetView extends GetView<SearchAssetController> {
  const SearchAssetView({super.key});

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
                      _AssetLookupField(),
                      const SizedBox(height: 22),
                      _StartStopButtons(),
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

class _AssetLookupField extends GetView<SearchAssetController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.openAssetLookup,
      child: IgnorePointer(
        child: TextField(
          controller: controller.assetController,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          onTap: controller.openAssetLookup,
          onTapAlwaysCalled: true,
          style: AppTextStyles.body(color: Colors.black87),
          decoration: InputDecoration(
            labelText: AppStrings.assetNameCodeOrTagCode,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Tooltip(
              message: AppStrings.rfidReaderConnected,
              child: Icon(
                Icons.sensors,
                color: AppTheme.primary,
              ),
            ),
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
          Text(AppStrings.searchAsset, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _StartStopButtons extends GetView<SearchAssetController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.canStart ? controller.start : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: const Color(0xFFBDBDBD),
              ),
              child: controller.isStarting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(AppStrings.start),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.canStop ? controller.stop : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                disabledBackgroundColor: const Color(0xFFBDBDBD),
              ),
              child: const Text(AppStrings.stop),
            ),
          ),
        ],
      ),
    );
  }
}
