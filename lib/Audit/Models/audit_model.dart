import 'dart:convert';

AuditModel auditModelFromJson(String str) =>
    AuditModel.fromJson(json.decode(str));

String auditModelToJson(AuditModel data) => json.encode(data.toJson());

/// A single audit returned by `api/Audit/GetAuditByUserId/{id}`.
class AuditModel {
  int? id;
  String auditName;
  String auditCode;

  AuditModel({
    this.id,
    required this.auditName,
    required this.auditCode,
  });

  /// Label shown in the "Select Audit Name" dropdown, e.g. `Test AUD/2526/0002`.
  String get displayLabel {
    final name = auditName.trim();
    final code = auditCode.trim();
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name $code';
  }

  factory AuditModel.fromJson(Map<String, dynamic> json) => AuditModel(
        id: _toInt(json["id"] ?? json["Id"] ?? json["auditId"] ?? json["AuditId"]),
        auditName: _toStr(json["auditName"] ?? json["AuditName"]),
        auditCode: _toStr(json["auditCode"] ?? json["AuditCode"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "auditName": auditName,
        "auditCode": auditCode,
      };

  /// Extracts the audit list from the API envelope
  /// (`{ "data": { "audits": [...] } }`).
  static List<AuditModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map((item) => AuditModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data = response["data"] ?? response["Data"] ?? response;
      if (data is Map) {
        final audits = data["audits"] ?? data["Audits"] ?? data["auditList"];
        if (audits is List) return audits;
      }
      if (data is List) return data;
    }
    return const [];
  }

  static String _toStr(dynamic value) => (value ?? '').toString().trim();

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
