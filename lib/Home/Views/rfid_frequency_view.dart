import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Home/Controllers/rfid_frequency_controller.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class RfidFrequencyView extends GetView<RfidFrequencyController> {
  const RfidFrequencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.rfidFrequencySettings,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.loginTitle(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final current = controller.currentFrequency.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.currentFrequency,
                          style: AppTextStyles.userLabel(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          current == null
                              ? AppStrings.notAvailable
                              : current.toString(),
                          style: AppTextStyles.userValue(),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          key: ValueKey(controller.selectedFrequency.value),
                          initialValue: controller.selectedFrequency.value,
                          decoration: const InputDecoration(
                            labelText: AppStrings.selectFrequency,
                          ),
                          items: RfidFrequencyController.frequencies
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isApplying.value ||
                                  !controller.isConnected.value
                              ? null
                              : controller.onFrequencySelected,
                        ),
                        if (controller.isApplying.value) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
