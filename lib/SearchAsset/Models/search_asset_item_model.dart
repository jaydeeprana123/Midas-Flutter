import 'dart:convert';

List<SearchAssetItemModel> searchAssetItemModelListFromJson(String str) =>
    SearchAssetItemModel.listFromResponse(json.decode(str));

/// Asset returned by `GET /api/Asset/SearchAssetForMobileApp`.
class SearchAssetItemModel {
  int? id;
  String assetName;
  String assetCode;
  String tagCode;

  SearchAssetItemModel({
    this.id,
    required this.assetName,
    required this.assetCode,
    required this.tagCode,
  });

  /// List row label, e.g. `Computer (AGSAA0001)`.
  String get displayLabel {
    final name = assetName.trim();
    final code = assetCode.trim();
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  /// Value shown on the main Search Asset screen after selection,
  /// e.g. `Computer (AGSAA0001)` using tag code in parentheses.
  String get trackingLabel {
    final name = assetName.trim();
    final tag = tagCode.trim();
    if (name.isEmpty) return tag;
    if (tag.isEmpty) return name;
    return '$name ($tag)';
  }

  factory SearchAssetItemModel.fromJson(Map<String, dynamic> json) =>
      SearchAssetItemModel(
        id: _toInt(json['id'] ?? json['Id']),
        assetName: _toStr(json['assetName'] ?? json['AssetName']),
        assetCode: _toStr(json['assetCode'] ?? json['AssetCode']),
        tagCode: _toStr(json['tagCode'] ?? json['TagCode']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'assetName': assetName,
        'assetCode': assetCode,
        'tagCode': tagCode,
      };

  static List<SearchAssetItemModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map((item) =>
            SearchAssetItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data = response['data'] ?? response['Data'];
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
