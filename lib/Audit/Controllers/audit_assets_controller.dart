import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:midas/Audit/Models/audit_model.dart';
import 'package:midas/Audit/Models/audit_rfids_model.dart';
import 'package:midas/Audit/Models/audit_insert_response.dart';
import 'package:midas/Audit/audit_repository.dart';
import 'package:midas/Shared/Widgets/app_loading_dialog.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';
import 'package:midas/app/constants/app_strings.dart';

class AuditAssetsController extends GetxController {
  AuditAssetsController({
    required this.auditRepository,
    required this.secureStorage,
    required this.rfidService,
  });

  final AuditRepository auditRepository;
  final SecureStorageService secureStorage;
  final RfidService rfidService;

  final audits = <AuditModel>[].obs;
  final selectedAudit = Rxn<AuditModel>();

  final isLoadingAudits = false.obs;
  final isLoadingSummary = false.obs;
  final hasSummary = false.obs;
  final isScanning = false.obs;
  final isSubmitting = false.obs;

  /// True from the moment Stop is pressed until the Stop API response has been
  /// handled and its dialog dismissed. While true, Start stays disabled.
  final isStopping = false.obs;
  final isRfidConnected = false.obs;

  // Audit summary counts shown in the UI.
  final totalAssets = 0.obs;
  final foundAssets = 0.obs;
  final missingAssets = 0.obs;
  final alienAssets = 0.obs;
  final invalidTagCount = 0.obs;
  final validUnassignedTagCount = 0.obs;

  AuditTotals? _totals;

  /// All RFID codes that belong to the selected audit.
  final Set<String> _auditRfids = <String>{};

  /// Audit RFIDs still not found during this scan session.
  final Set<String> _missing = <String>{};

  /// Audit RFIDs matched (found) during this scan session.
  final Set<String> _found = <String>{};

  /// Every unique tag scanned during this session (submitted on Stop).
  /// Mirrors the reference `lstFoundAssets`.
  final Set<String> _scanned = <String>{};

  int _userId = 0;
  StreamSubscription<String>? _tagSubscription;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
    _bootstrap();
  }

  Future<void> _initRfid() async {
    _tagSubscription = rfidService.tagStream.listen(_onTagRead);
    isRfidConnected.value = await rfidService.connect();
  }

  Future<void> _bootstrap() async {
    _userId = await secureStorage.userId ?? 0;
    await fetchAudits();
  }

  Future<void> fetchAudits() async {
    isLoadingAudits.value = true;
    try {
      final list = await auditRepository.getAuditsByUserId(_userId);
      audits.assignAll(list);
    } on DioException catch (e) {
      _showError(AppStrings.fetchFailed, e);
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchAuditsRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAudits.value = false;
    }
  }

  Future<void> onAuditSelected(AuditModel audit) async {
    if (isScanning.value) return;
    selectedAudit.value = audit;
    hasSummary.value = false;
    _resetScanState();

    isLoadingSummary.value = true;
    try {
      final result = await auditRepository.getRfidsByAuditId(audit.id ?? 0);
      _applySummary(result);
      hasSummary.value = true;
    } on DioException catch (e) {
      _showError(AppStrings.fetchFailed, e);
    } catch (_) {
      Get.snackbar(
        AppStrings.fetchFailed,
        AppStrings.unableToFetchAuditSummaryRetry,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void _applySummary(AuditRfidsResult result) {
    _totals = result.totals;
    _auditRfids
      ..clear()
      ..addAll(result.rfids);
    _missing
      ..clear()
      ..addAll(_auditRfids);
    _found.clear();

    totalAssets.value = result.totals.totalAssets;
    foundAssets.value = result.totals.foundAssets;
    missingAssets.value = result.totals.missingAssets;
    alienAssets.value = result.totals.alienAssets;
    invalidTagCount.value = result.totals.invalidTagCount;
    validUnassignedTagCount.value = result.totals.validUnassignedTagCount;
  }

  Future<void> start() async {
    if (!hasSummary.value || selectedAudit.value == null) return;
    if (isScanning.value || isStopping.value) return;
    isScanning.value = true;
    final started = await rfidService.startInventory();
    if (!started) {
      isScanning.value = false;
      Get.snackbar(
        AppStrings.scanFailed,
        AppStrings.rfidReaderUnavailable,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stop() async {
    if (!isScanning.value || isStopping.value) return;
    // Keep Start disabled for the whole stop -> submit -> dialog flow.
    isStopping.value = true;
    isScanning.value = false;
    try {
      await rfidService.stopInventory();
      await _submitAuditData();
    } finally {
      // Re-enable Start only now: after the API completed and, on
      // error/failure, after its dialog was dismissed (both awaited above).
      isStopping.value = false;
    }
  }

  /// Submits the scanned tags to `api/Audit/InsertAuditData/{AuditId}`,
  /// mirroring the reference `postInsetAuditDataAPI(auditId, lstFoundAssets)`.
  Future<void> _submitAuditData() async {
    final auditId = selectedAudit.value?.id;
    if (auditId == null) return;

    // Show the loading overlay while the request is in flight, and hide it as
    // soon as the response (or an error) comes back.
    isSubmitting.value = true;
    showAppLoadingDialog();

    AuditInsertResponse? response;
    Object? error;
    try {
      response = await auditRepository.insertAuditData(
        auditId: auditId,
        scannedTags: _scanned.toList(),
      );
    } catch (e) {
      error = e;
    } finally {
      hideAppLoadingDialog();
      isSubmitting.value = false;
    }

    if (error != null) {
      String message = AppStrings.unableToSaveAuditDataRetry;
      if (error is DioException) {
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      }
      await showAppMessageDialog(message);
      return;
    }

    if (response!.succeeded) {
      Get.snackbar(
        AppStrings.success,
        response.message.isNotEmpty
            ? response.message
            : AppStrings.auditDataSavedSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await showAppMessageDialog(
        response.message.isNotEmpty
            ? response.message
            : AppStrings.unableToSaveAuditData,
      );
    }
  }

  /// Handles each EPC read from the hardware during continuous inventory,
  /// mirroring the reference `AuditAssetsActivity` inventory callback: a tag
  /// that belongs to the audit is counted as found (with a beep), decreasing the
  /// missing count.
  void _onTagRead(String epc) {
    if (!isScanning.value) return;
    final tag = epc.trim();
    if (tag.isEmpty) return;

    // A tag that belongs to the audit is counted as found (with a beep) and
    // decreases the missing count (reference: lstMissingAssets / lstTotalFoundAssets).
    if (_missing.remove(tag)) {
      _found.add(tag);
      rfidService.beep(success: true);

      foundAssets.value = (_totals?.foundAssets ?? 0) + _found.length;
      final remaining = _missing.length - _found.length;
      missingAssets.value = remaining > 0 ? remaining : 0;
    }

    // Every unique tag scanned is recorded for submission (reference: lstFoundAssets).
    _scanned.add(tag);
  }

  void _resetScanState() {
    _auditRfids.clear();
    _missing.clear();
    _found.clear();
    _scanned.clear();
    _totals = null;
    totalAssets.value = 0;
    foundAssets.value = 0;
    missingAssets.value = 0;
    alienAssets.value = 0;
    invalidTagCount.value = 0;
    validUnassignedTagCount.value = 0;
  }

  void _showError(String title, DioException e) {
    final data = e.response?.data;
    Get.snackbar(
      title,
      data is Map && data['message'] != null
          ? data['message'].toString()
          : AppStrings.unableToFetchAuditsRetry,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    rfidService.stopInventory();
    rfidService.disconnect();
    super.onClose();
  }
}
