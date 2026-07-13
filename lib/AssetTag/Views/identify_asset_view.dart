import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Controllers/identify_asset_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class IdentifyAssetView extends GetView<IdentifyAssetController> {
  const IdentifyAssetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputCard(),
                    Obx(() {
                      if (controller.identityAsset.value == null) {
                        return const SizedBox.shrink();
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: _DetailsCard(),
                      );
                    }),
                  ],
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
          Text(AppStrings.identifyAsset, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _InputCard extends GetView<IdentifyAssetController> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.tagController,
                  style: AppTextStyles.body(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: AppStrings.scanQrOrPressButton,
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
                onTap: controller.scanQr,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.qr_code_scanner, size: 34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isFetching.value ? null : controller.fetchDetails,
              child: controller.isFetching.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(AppStrings.fetchDetails),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends GetView<IdentifyAssetController> {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final asset = controller.identityAsset.value;
      if (asset == null) return const SizedBox.shrink();

      return Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailRow(label: AppStrings.assetName, value: asset.assetName),
            _DetailRow(label: AppStrings.assetCode, value: asset.assetCode),
            _DetailRow(label: AppStrings.serialNo, value: asset.serialNo),
            _DetailRow(label: AppStrings.tagCode, value: asset.tagCode),
            _DetailRow(
              label: AppStrings.locationCode,
              value: asset.locationCode,
            ),
            if (asset.hasLocationPath)
              _DetailRow(
                label: AppStrings.location,
                value: asset.locationPathLabel,
              ),
            _DetailRow(label: AppStrings.remarks, value: asset.remarks),
          ],
        ),
      );
    });
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: AppTextStyles.body(color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body(
                color: Colors.black87,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
