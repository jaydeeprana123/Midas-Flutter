import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Equipment/Controllers/identify_equipment_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class IdentifyEquipmentView extends GetView<IdentifyEquipmentController> {
  const IdentifyEquipmentView({super.key});

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
                      _TagField(),
                      const SizedBox(height: 22),
                      Obx(() {
                        if (controller.fetchedEquipment.value != null) {
                          return const SizedBox.shrink();
                        }
                        return ElevatedButton(
                          onPressed: controller.isFetching.value
                              ? null
                              : controller.fetchDetails,
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
                        );
                      }),
                      Obx(() {
                        final equipment = controller.fetchedEquipment.value;
                        if (equipment == null) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            if (equipment.hasClickableJobCard)
                              _JobCardRow(
                                jobCardNumber: equipment.jobCardNumber!,
                                isLoading: controller.isDownloadingJobCard.value,
                                onTap: controller.downloadJobCardReport,
                              ),
                            ...equipment.detailPairs.map(
                              (pair) => _DetailRow(
                                label: pair.key,
                                value: pair.value,
                              ),
                            ),
                          ],
                        );
                      }),
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
            AppStrings.equipmentMaintenanceSystem,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle(),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.identifyEquipment,
            style: AppTextStyles.loginTitle(),
          ),
        ],
      ),
    );
  }
}

class _TagField extends GetView<IdentifyEquipmentController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.tagController,
            focusNode: controller.tagFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.body(color: Colors.black87),
            decoration: InputDecoration(
              labelText: AppStrings.scanQrOrPressButton,
              prefixIcon: const Icon(Icons.qr_code_2),
              suffixIcon: Obx(
                () => controller.isRfidConnected.value
                    ? const Tooltip(
                        message: AppStrings.rfidReaderConnected,
                        child: Icon(Icons.sensors, color: AppTheme.primary),
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
    );
  }
}

class _JobCardRow extends StatelessWidget {
  const _JobCardRow({
    required this.jobCardNumber,
    required this.isLoading,
    required this.onTap,
  });

  final String jobCardNumber;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.jobCardNumber} : ',
            style: AppTextStyles.body(color: Colors.black54),
          ),
          Expanded(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: onTap,
                    child: Text(
                      jobCardNumber,
                      style: AppTextStyles.body(
                        color: Colors.blue,
                        weight: FontWeight.w700,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
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
