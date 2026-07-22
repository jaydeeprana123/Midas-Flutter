import 'package:get/get.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/Shared/Services/app_logger.dart';

/// Syncs pending material offline operations when connectivity returns.
class MaterialUnassignSyncService extends GetxService {
  MaterialUnassignSyncService({
    required this.materialRepository,
    required this.sqliteService,
    required this.connectivityService,
  });

  final MaterialRepository materialRepository;
  final MaterialSqliteService sqliteService;
  final NetworkConnectivityService connectivityService;

  final isSyncing = false.obs;

  Worker? _onlineWorker;
  bool _syncInProgress = false;

  @override
  void onInit() {
    super.onInit();
    _onlineWorker = ever(connectivityService.isOnline, (online) {
      if (online == true) {
        syncPendingOperations();
      }
    });
    if (connectivityService.isOnline.value) {
      syncPendingOperations();
    }
  }

  Future<void> syncPendingOperations() async {
    if (_syncInProgress) return;
    if (!await connectivityService.refresh()) return;

    _syncInProgress = true;
    isSyncing.value = true;
    try {
      await _syncPendingAssignTags();
      await _syncPendingUnassigns();
      await _syncPendingLinkLocations();
    } finally {
      _syncInProgress = false;
      isSyncing.value = false;
    }
  }

  Future<void> syncPendingUnassigns() => syncPendingOperations();

  Future<void> _syncPendingAssignTags() async {
    final pending = await sqliteService.getPendingAssignTags();
    for (final record in pending) {
      if (!connectivityService.isOnline.value) break;
      if (record.id == null) continue;

      try {
        final response = await materialRepository.insertMaterialTagging(
          record.request,
        );
        if (response.succeeded) {
          await sqliteService.markPendingAssignTagSynced(record.id!);
          AppLogger.info(
            'Synced pending material assign tag id=${record.id}',
          );
        } else {
          AppLogger.info(
            'Pending material assign tag id=${record.id} failed: '
            '${response.message}',
          );
        }
      } catch (e) {
        AppLogger.info(
          'Pending material assign tag id=${record.id} error: $e',
        );
      }
    }
  }

  Future<void> _syncPendingUnassigns() async {
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
      }
    }
  }

  Future<void> _syncPendingLinkLocations() async {
    final pending = await sqliteService.getPendingLinkLocations();
    for (final record in pending) {
      if (!connectivityService.isOnline.value) break;
      if (record.id == null ||
          record.detailIds.isEmpty ||
          record.locationCode.isEmpty) {
        continue;
      }

      try {
        final response = await materialRepository.linkMaterialLocation(
          locationCode: record.locationCode,
          detailIds: record.detailIds,
        );
        if (response.succeeded) {
          await sqliteService.markPendingLinkLocationSynced(record.id!);
          AppLogger.info(
            'Synced pending material link location id=${record.id}',
          );
        } else {
          AppLogger.info(
            'Pending material link location id=${record.id} failed: '
            '${response.message}',
          );
        }
      } catch (e) {
        AppLogger.info(
          'Pending material link location id=${record.id} error: $e',
        );
      }
    }
  }

  @override
  void onClose() {
    _onlineWorker?.dispose();
    super.onClose();
  }
}
