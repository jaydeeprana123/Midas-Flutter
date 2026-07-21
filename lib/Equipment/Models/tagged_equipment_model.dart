class TaggedEquipmentModel {
  const TaggedEquipmentModel({
    required this.id,
    required this.equipmentId,
    required this.equipmentCode,
    required this.equipmentTypeName,
    this.tagTypeId,
    this.tagId,
    this.tagCode,
    this.rfidTagCode,
    this.equipmentSubTypeName,
    this.tagTypeName,
    this.createdByName,
  });

  final int id;
  final int equipmentId;
  final String equipmentCode;
  final String equipmentTypeName;
  final int? tagTypeId;
  final int? tagId;
  final String? tagCode;
  final String? rfidTagCode;
  final String? equipmentSubTypeName;
  final String? tagTypeName;
  final String? createdByName;

  /// Shown in search list / selection field, e.g. `Valves (GSSPL/EC/2026/0006)`.
  String get displayLabel {
    final name = equipmentTypeName.trim();
    final code = equipmentCode.trim();
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  factory TaggedEquipmentModel.fromJson(Map<String, dynamic> json) =>
      TaggedEquipmentModel(
        id: _toInt(json['id'] ?? json['Id']) ?? 0,
        equipmentId: _toInt(json['equipmentId'] ?? json['EquipmentId']) ?? 0,
        equipmentCode: _str(json['equipmentCode'] ?? json['EquipmentCode']),
        equipmentTypeName: _str(
          json['equipmentTypeName'] ?? json['EquipmentTypeName'],
        ),
        tagTypeId: _toInt(json['tagTypeId'] ?? json['TagTypeId']),
        tagId: _toInt(json['tagId'] ?? json['TagId']),
        tagCode: _nullableStr(json['tagCode'] ?? json['TagCode']),
        rfidTagCode: _nullableStr(json['rfidTagCode'] ?? json['RfidTagCode']),
        equipmentSubTypeName: _nullableStr(
          json['equipmentSubTypeName'] ?? json['EquipmentSubTypeName'],
        ),
        tagTypeName: _nullableStr(json['tagTypeName'] ?? json['TagTypeName']),
        createdByName: _nullableStr(json['createdByName'] ?? json['CreatedByName']),
      );

  static List<TaggedEquipmentModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map(
          (item) =>
              TaggedEquipmentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.equipmentCode.isNotEmpty || item.id > 0)
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
    }
    return const [];
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static String? _nullableStr(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
