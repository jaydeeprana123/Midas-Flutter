class MaterialTaggingDetailModel {
  const MaterialTaggingDetailModel({
    required this.detailId,
    required this.tagCode,
    required this.materialName,
    required this.materialCode,
    this.materialTaggingId,
    this.materialId,
    this.location,
    this.rawJson,
  });

  final int detailId;
  final int? materialTaggingId;
  final int? materialId;
  final String tagCode;
  final String materialName;
  final String materialCode;
  final String? location;
  final String? rawJson;

  String get displayLocation =>
      (location == null || location!.trim().isEmpty) ? '-' : location!.trim();

  Map<String, dynamic> toSqliteMap() => {
        'tag_code': tagCode,
        'detail_id': detailId,
        'material_tagging_id': materialTaggingId,
        'material_id': materialId,
        'material_name': materialName,
        'material_code': materialCode,
        'location': location,
        'raw_json': rawJson,
        'updated_at': DateTime.now().toIso8601String(),
      };

  factory MaterialTaggingDetailModel.fromSqlite(Map<String, dynamic> row) {
    return MaterialTaggingDetailModel(
      detailId: _toInt(row['detail_id']) ?? 0,
      materialTaggingId: _toInt(row['material_tagging_id']),
      materialId: _toInt(row['material_id']),
      tagCode: _str(row['tag_code']),
      materialName: _str(row['material_name']),
      materialCode: _str(row['material_code']),
      location: _nullableStr(row['location']),
      rawJson: _nullableStr(row['raw_json']),
    );
  }

  /// Flattens GetMaterialTaggingDetails response into one row per tag detail.
  static List<MaterialTaggingDetailModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    final results = <MaterialTaggingDetailModel>[];

    for (final item in list.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final materialName = _str(map['materialName'] ?? map['MaterialName']);
      final materialCode = _str(map['code'] ?? map['Code'] ?? map['materialCode']);
      final materialId = _toInt(map['materialId'] ?? map['MaterialId']);
      final taggingId = _toInt(map['id'] ?? map['Id']);
      final details = map['materialTagingDetails'] ??
          map['materialTaggingDetails'] ??
          map['MaterialTagingDetails'];

      if (details is! List) continue;

      for (final detail in details.whereType<Map>()) {
        final detailMap = Map<String, dynamic>.from(detail);
        final tagCode = _str(detailMap['tagCode'] ?? detailMap['TagCode']);
        final detailId = _toInt(detailMap['id'] ?? detailMap['Id']) ?? 0;
        if (tagCode.isEmpty || detailId <= 0) continue;

        results.add(
          MaterialTaggingDetailModel(
            detailId: detailId,
            materialTaggingId: taggingId,
            materialId: materialId,
            tagCode: tagCode,
            materialName: materialName,
            materialCode: materialCode,
            location: _nullableStr(
              detailMap['locationCode'] ??
                  detailMap['LocationCode'] ??
                  detailMap['location'] ??
                  detailMap['Location'],
            ),
            rawJson: null,
          ),
        );
      }
    }

    return results;
  }

  static MaterialTaggingDetailModel? findByTagCode(
    List<MaterialTaggingDetailModel> items,
    String tagCode,
  ) {
    final lower = tagCode.trim().toLowerCase();
    if (lower.isEmpty) return null;
    for (final item in items) {
      if (item.tagCode.trim().toLowerCase() == lower) return item;
    }
    return null;
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
