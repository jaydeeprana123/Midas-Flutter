import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Services/material_unassign_sync_service.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

/// Observes app lifecycle and shows a small background sync indicator.
class MaterialSyncLifecycleWrapper extends StatefulWidget {
  const MaterialSyncLifecycleWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<MaterialSyncLifecycleWrapper> createState() =>
      _MaterialSyncLifecycleWrapperState();
}

class _MaterialSyncLifecycleWrapperState extends State<MaterialSyncLifecycleWrapper>
    with WidgetsBindingObserver {
  MaterialUnassignSyncService? _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncService = Get.isRegistered<MaterialUnassignSyncService>()
          ? Get.find<MaterialUnassignSyncService>()
          : null;
      _syncService?.syncPendingOperations();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncService?.syncPendingOperations();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MaterialUnassignSyncService>()) {
      return widget.child;
    }

    final syncService = Get.find<MaterialUnassignSyncService>();
    return Stack(
      children: [
        widget.child,
        Obx(() {
          if (!syncService.isSyncing.value) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.syncingInBackground,
                          style: AppTextStyles.body(
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
