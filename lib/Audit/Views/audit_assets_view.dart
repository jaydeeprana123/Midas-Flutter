import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Audit/Controllers/audit_assets_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class AuditAssetsView extends GetView<AuditAssetsController> {
  const AuditAssetsView({super.key});

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
                child: Column(
                  children: [
                    _AuditDropdownCard(),
                    const SizedBox(height: 16),
                    Obx(
                      () => controller.hasSummary.value
                          ? _SummaryCard()
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => controller.hasSummary.value
                          ? _StartStopButtons()
                          : const SizedBox.shrink(),
                    ),
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
          Text(AppStrings.auditAssets, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _AuditDropdownCard extends GetView<AuditAssetsController> {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectAuditName,
            style: AppTextStyles.cardTitle(),
          ),
          const SizedBox(height: 10),
          Obx(
            () => InkWell(
              onTap: controller.isLoadingAudits.value || controller.isScanning.value
                  ? null
                  : () => _openAuditPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC3C3C3)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedAudit.value?.displayLabel ??
                            AppStrings.selectAuditName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          color: controller.selectedAudit.value == null
                              ? Colors.black38
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (controller.isLoadingAudits.value)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => controller.isLoadingSummary.value
                ? const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _openAuditPicker(BuildContext context) {
    final audits = controller.audits;
    if (audits.isEmpty) {
      Get.snackbar(
        AppStrings.auditAssets,
        AppStrings.noAuditsFound,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.selectAuditName,
                  style: AppTextStyles.cardTitle(),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: audits.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final audit = audits[index];
                    return ListTile(
                      title: Text(
                        audit.displayLabel,
                        style: AppTextStyles.body(color: Colors.black87),
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        controller.onAuditSelected(audit);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends GetView<AuditAssetsController> {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SummaryRow(
            label: AppStrings.totalAssets,
            value: () => controller.totalAssets.value,
          ),
          _SummaryRow(
            label: AppStrings.assetsFound,
            value: () => controller.foundAssets.value,
          ),
          _SummaryRow(
            label: AppStrings.missingAssets,
            value: () => controller.missingAssets.value,
          ),
          _SummaryRow(
            label: AppStrings.alienAssets,
            value: () => controller.alienAssets.value,
          ),
          _SummaryRow(
            label: AppStrings.invalidTagCount,
            value: () => controller.invalidTagCount.value,
          ),
          _SummaryRow(
            label: AppStrings.validUnassignedTagCount,
            value: () => controller.validUnassignedTagCount.value,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final int Function() value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.body(color: Colors.black54)),
          ),
          Obx(
            () => Text(
              value().toString(),
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

class _StartStopButtons extends GetView<AuditAssetsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  controller.isScanning.value || controller.isStopping.value
                      ? null
                      : controller.start,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: const Color(0xFFBDBDBD),
              ),
              child: const Text(AppStrings.start),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  controller.isScanning.value && !controller.isStopping.value
                      ? controller.stop
                      : null,
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}
