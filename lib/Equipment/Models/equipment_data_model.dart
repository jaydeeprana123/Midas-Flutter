class EquipmentDataModel {
  const EquipmentDataModel({
    required this.id,
    required this.equipmentTypeName,
    required this.equipmentCode,
    this.customerId,
    this.customerName,
    this.equipmentTypesId,
    this.equipmentSubTypesId,
    this.equipmentSubTypeName,
    this.customerTagNumber,
    this.inTesting,
    this.tagId,
    this.tagCode,
    this.allFetchDetails,
  });

  final int id;
  final int? customerId;
  final String? customerName;
  final int? equipmentTypesId;
  final String equipmentTypeName;
  final int? equipmentSubTypesId;
  final String? equipmentSubTypeName;
  final String equipmentCode;
  final String? customerTagNumber;
  final bool? inTesting;
  final int? tagId;
  final String? tagCode;
  final String? allFetchDetails;

  /// Shown in search list / selection field, e.g. `Valves (GSSPL/EC/2026/0006)`.
  String get displayLabel {
    final name = equipmentTypeName.trim();
    final code = equipmentCode.trim();
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  factory EquipmentDataModel.fromJson(Map<String, dynamic> json) =>
      EquipmentDataModel(
        id: _toInt(json['id'] ?? json['Id']) ?? 0,
        customerId: _toInt(json['customerId'] ?? json['CustomerId']),
        customerName: _nullableStr(json['customerName'] ?? json['CustomerName']),
        equipmentTypesId: _toInt(
          json['equipmentTypesId'] ?? json['EquipmentTypesId'],
        ),
        equipmentTypeName: _str(
          json['equipmentTypeName'] ?? json['EquipmentTypeName'],
        ),
        equipmentSubTypesId: _toInt(
          json['equipmentSubTypesId'] ?? json['EquipmentSubTypesId'],
        ),
        equipmentSubTypeName: _nullableStr(
          json['equipmentSubTypeName'] ?? json['EquipmentSubTypeName'],
        ),
        equipmentCode: _str(json['equipmentCode'] ?? json['EquipmentCode']),
        customerTagNumber: _nullableStr(
          json['customerTagNumber'] ?? json['CustomerTagNumber'],
        ),
        inTesting: json['inTesting'] as bool? ?? json['InTesting'] as bool?,
        tagId: _toInt(json['tagId'] ?? json['TagId']),
        tagCode: _nullableStr(json['tagCode'] ?? json['TagCode']),
        allFetchDetails: _nullableStr(
          json['allFetchDetails'] ?? json['AllFetchDetails'],
        ),
      );

  static List<EquipmentDataModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map(
          (item) => EquipmentDataModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.id > 0 || item.equipmentCode.isNotEmpty)
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
