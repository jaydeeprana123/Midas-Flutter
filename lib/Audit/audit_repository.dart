import 'package:midas/Audit/Models/audit_insert_response.dart';
import 'package:midas/Audit/Models/audit_model.dart';
import 'package:midas/Audit/Models/audit_rfids_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class AuditRepository {
  AuditRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Returns the audits assigned to a user.
  /// `GET /api/Audit/GetAuditByUserId/{id}`
  Future<List<AuditModel>> getAuditsByUserId(int userId) async {
    final json = await _apiClient.get('/api/Audit/GetAuditByUserId/$userId');
    return AuditModel.listFromResponse(json);
  }

  /// Returns the RFID list and summary totals for an audit.
  /// `GET /api/Audit/GetRFIdsByAuditId/{AuditId}`
  Future<AuditRfidsResult> getRfidsByAuditId(int auditId) async {
    final json = await _apiClient.get('/api/Audit/GetRFIdsByAuditId/$auditId');
    return AuditRfidsResult.fromResponse(json);
  }

  /// Submits the scanned tags at the end of an audit scan session.
  /// `PUT /api/Audit/InsertAuditData/{AuditId}` with a JSON array of tag codes.
  Future<AuditInsertResponse> insertAuditData({
    required int auditId,
    required List<String> scannedTags,
  }) async {
    final json = await _apiClient.putRaw(
      '/api/Audit/InsertAuditData/$auditId',
      data: scannedTags,
    );
    return AuditInsertResponse.fromJson(json);
  }
}
