import 'dart:convert';

AuditRfidsResult auditRfidsResultFromJson(String str) =>
    AuditRfidsResult.fromResponse(json.decode(str));

/// Result of `api/Audit/GetRFIdsByAuditId/{AuditId}` — the audit summary totals
/// plus the list of RFID tags that belong to the audit.
class AuditRfidsResult {
  final List<AuditAssetRfid> assets;
  final AuditTotals totals;

  AuditRfidsResult({
    required this.assets,
    required this.totals,
  });

  /// Non-empty RFID codes belonging to the audit.
  List<String> get rfids => assets
      .map((asset) => asset.rfid.trim())
      .where((rfid) => rfid.isNotEmpty)
      .toList();

  factory AuditRfidsResult.fromResponse(dynamic response) {
    final data = _unwrap(response);
    final rawAssets = data["assetData"] ??
        data["AssetData"] ??
        data["assets"] ??
        data["Assets"];
    final rawTotals = data["totals"] ?? data["Totals"];

    return AuditRfidsResult(
      assets: rawAssets is List
          ? rawAssets
              .whereType<Map>()
              .map((item) =>
                  AuditAssetRfid.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <AuditAssetRfid>[],
      totals: rawTotals is Map
          ? AuditTotals.fromJson(Map<String, dynamic>.from(rawTotals))
          : AuditTotals.empty(),
    );
  }

  static Map<String, dynamic> _unwrap(dynamic response) {
    if (response is Map) {
      final data = response["data"] ?? response["Data"];
      if (data is Map) return Map<String, dynamic>.from(data);
      return Map<String, dynamic>.from(response);
    }
    return <String, dynamic>{};
  }
}

class AuditAssetRfid {
  final int? assetId;
  final int? auditId;
  final String rfid;
  final bool? status;

  AuditAssetRfid({
    this.assetId,
    this.auditId,
    required this.rfid,
    this.status,
  });

  factory AuditAssetRfid.fromJson(Map<String, dynamic> json) => AuditAssetRfid(
        assetId: _toInt(json["assetId"] ?? json["AssetId"]),
        auditId: _toInt(json["auditId"] ?? json["AuditId"]),
        rfid: (json["rfid"] ?? json["Rfid"] ?? json["RFID"] ?? '')
            .toString()
            .trim(),
        status: json["status"] is bool ? json["status"] as bool : null,
      );

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// Audit summary counts shown above the Start / Stop buttons.
class AuditTotals {
  final int totalAssets;
  final int foundAssets;
  final int missingAssets;
  final int alienAssets;
  final int invalidTagCount;
  final int validUnassignedTagCount;

  AuditTotals({
    required this.totalAssets,
    required this.foundAssets,
    required this.missingAssets,
    required this.alienAssets,
    required this.invalidTagCount,
    required this.validUnassignedTagCount,
  });

  factory AuditTotals.empty() => AuditTotals(
        totalAssets: 0,
        foundAssets: 0,
        missingAssets: 0,
        alienAssets: 0,
        invalidTagCount: 0,
        validUnassignedTagCount: 0,
      );

  factory AuditTotals.fromJson(Map<String, dynamic> json) => AuditTotals(
        totalAssets: _toInt(json["totalAssets"] ?? json["totalAsset"]),
        foundAssets: _toInt(json["foundAsset"] ?? json["foundAssets"]),
        missingAssets: _toInt(json["missingAsset"] ?? json["missingAssets"]),
        alienAssets: _toInt(json["alienAsset"] ?? json["alienAssets"]),
        invalidTagCount: _toInt(json["invalidTagCount"]),
        validUnassignedTagCount: _toInt(json["validUnassignedTagCount"]),
      );

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
