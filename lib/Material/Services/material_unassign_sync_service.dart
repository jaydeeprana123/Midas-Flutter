import 'package:get/get.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/app_logger.dart';

/// Continuously syncs pending material unassign requests when online.
class MaterialUnassignSyncService extends GetxService {
  MaterialUnassignSyncService({
    required this.materialRepository,
    required this.sqliteService,
    required this.connectivityService,
  });

  final MaterialRepository materialRepository;
  final MaterialSqliteService sqliteService;
  final NetworkConnectivityService connectivityService;

  Worker? _onlineWorker;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    _onlineWorker = ever(connectivityService.isOnline, (online) {
      if (online == true) {
        syncPendingUnassigns();
      }
    });
    if (connectivityService.isOnline.value) {
      syncPendingUnassigns();
    }
  }

  Future<void> syncPendingUnassigns() async {
    if (_isSyncing) return;
    if (!await connectivityService.refresh()) return;

    _isSyncing = true;
    try {
      final pending = await sqliteService.getPendingUnassigns();
      for (final record in pending) {
        if (!connectivityService.isOnline.value) break;
        if (record.id == null || record.detailIds.isEmpty) continue;

        try {
          final response = await materialRepository.deLinkMaterialTag(
            detailIds: record.detailIds,
          );
          if (response.succeeded) {
            await sqliteService.markPendingUnassignSynced(record.id!);
            final tag = record.tagCode;
            if (tag != null && tag.isNotEmpty) {
              await sqliteService.deleteMaterialTagDetailsByTagCode(tag);
            }
            AppLogger.info(
              'Synced pending material unassign id=${record.id}',
            );
          } else {
            AppLogger.info(
              'Pending material unassign id=${record.id} failed: '
              '${response.message}',
            );
          }
        } catch (e) {
          AppLogger.info(
            'Pending material unassign id=${record.id} error: $e',
          );
          // Keep record for retry when connectivity returns.
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  @override
  void onClose() {
    _onlineWorker?.dispose();
    super.onClose();
  }
}
