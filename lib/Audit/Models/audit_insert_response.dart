import 'dart:convert';

AuditInsertResponse auditInsertResponseFromJson(String str) =>
    AuditInsertResponse.fromJson(json.decode(str));

/// Response envelope for `PUT api/Audit/InsertAuditData/{AuditId}`.
class AuditInsertResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final dynamic data;

  AuditInsertResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.data,
  });

  bool get succeeded => isSuccess;

  factory AuditInsertResponse.fromJson(Map<String, dynamic> json) =>
      AuditInsertResponse(
        isSuccess: json["isSuccess"] == true,
        status: _toInt(json["status"]),
        message: (json["message"] ?? '').toString(),
        data: json["data"],
      );

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
