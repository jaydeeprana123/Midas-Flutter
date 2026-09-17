import 'dart:convert';

List<AssetLinkTagModel> assetLinkTagModelListFromJson(String str) =>
    AssetLinkTagModel.listFromResponse(json.decode(str));

String assetLinkTagModelListToJson(List<AssetLinkTagModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AssetLinkTagModel {
  int assetId;
  int? orgId;
  String organizationName;
  String assetName;
  String assetCode;
  int? quantity;
  bool hasSerialNo;
  int? untaggedQuantity;
  int? remainingQuantity;
  int? taggedQuantity;

  AssetLinkTagModel({
    required this.assetId,
    this.orgId,
    this.organizationName = '',
    required this.assetName,
    required this.assetCode,
    this.quantity,
    this.hasSerialNo = false,
    this.untaggedQuantity,
    this.remainingQuantity,
    this.taggedQuantity,
  });

  /// Text shown in the search list, e.g.
  /// `Computer (AV/S/COMP.EQP./ICTLAPTOP/82/24-25) (1)`.
  String get displayLabel {
    final buffer = StringBuffer(assetName);
    if (assetCode.isNotEmpty) buffer.write(' ($assetCode)');
    if (quantity != null) buffer.write(' ($quantity)');
    return buffer.toString();
  }

  factory AssetLinkTagModel.fromJson(Map<String, dynamic> json) =>
      AssetLinkTagModel(
        assetId: _toInt(
              json["assetId"] ?? json["AssetId"] ?? json["id"] ?? json["Id"],
            ) ??
            0,
        assetName: _toStr(
          json["assetName"] ?? json["AssetName"] ?? json["name"] ?? json["Name"],
        ),
        assetCode: _toStr(
          json["assetCode"] ??
              json["AssetCode"] ??
              json["assetCodeName"] ??
              json["AssetCodeName"] ??
              json["code"] ??
              json["Code"],
        ),
        orgId: _toInt(json["orgId"] ?? json["OrgId"]),
        organizationName: _toStr(
          json["organizationName"] ?? json["OrganizationName"],
        ),
        quantity: _toInt(
          json["quantity"] ??
              json["Quantity"] ??
              json["qty"] ??
              json["Qty"] ??
              json["availableQuantity"] ??
              json["AvailableQuantity"],
        ),
        hasSerialNo: _toBool(json["hasSerialNo"] ?? json["HasSerialNo"]),
        untaggedQuantity: _toInt(
          json["untaggedQuantity"] ?? json["UntaggedQuantity"],
        ),
        remainingQuantity: _toInt(
          json["remainingQuantity"] ?? json["RemainingQuantity"],
        ),
        taggedQuantity: _toInt(
          json["taggedQuantity"] ?? json["TaggedQuantity"],
        ),
      );

  Map<String, dynamic> toJson() => {
        "assetId": assetId,
        "orgId": orgId,
        "organizationName": organizationName,
        "assetName": assetName,
        "assetCode": assetCode,
        "quantity": quantity,
        "hasSerialNo": hasSerialNo,
        "untaggedQuantity": untaggedQuantity,
        "remainingQuantity": remainingQuantity,
        "taggedQuantity": taggedQuantity,
      };

  /// Extracts the list of assets from a variety of possible envelope shapes.
  static List<AssetLinkTagModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map((item) => AssetLinkTagModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data = response['data'] ??
          response['Data'] ??
          response['result'] ??
          response['Result'];
      if (data is List) return data;
      if (data is Map) {
        final nested = data['items'] ?? data['Items'] ?? data['list'];
        if (nested is List) return nested;
      }
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

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
