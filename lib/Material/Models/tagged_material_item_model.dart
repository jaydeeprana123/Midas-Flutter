class TaggedMaterialItemModel {
  const TaggedMaterialItemModel({
    required this.detailId,
    required this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.tagCode,
    this.locationCode,
    this.materialTagingId,
  });

  final int detailId;
  final int? materialTagingId;
  final int materialId;
  final String materialName;
  final String materialCode;
  final String tagCode;
  final String? locationCode;

  bool get hasLocation =>
      locationCode != null && locationCode!.trim().isNotEmpty;

  factory TaggedMaterialItemModel.fromJson(Map<String, dynamic> json) {
    return TaggedMaterialItemModel(
      detailId: _toInt(json['id'] ?? json['Id']) ?? 0,
      materialTagingId:
          _toInt(json['materialTagingId'] ?? json['MaterialTagingId']),
      materialId: _toInt(json['materialId'] ?? json['MaterialId']) ?? 0,
      materialName: _str(json['materialName'] ?? json['MaterialName']),
      materialCode: _str(
        json['materialCode'] ?? json['MaterialCode'] ?? json['code'],
      ),
      tagCode: _str(json['tagCode'] ?? json['TagCode']),
      locationCode: _nullableStr(
        json['locationCode'] ?? json['LocationCode'],
      ),
    );
  }

  static List<TaggedMaterialItemModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map(
          (item) =>
              TaggedMaterialItemModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.detailId > 0)
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

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static String? _nullableStr(dynamic value) {
    final text = _str(value);
    return text.isEmpty ? null : text;
  }
}
