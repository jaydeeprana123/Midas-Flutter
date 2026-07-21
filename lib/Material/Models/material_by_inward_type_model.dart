class MaterialByInwardTypeModel {
  const MaterialByInwardTypeModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.code,
    this.uom,
    this.inwardTypeId,
    this.uoMid,
    this.quantity = 0,
    this.taggedQuantity = 0,
    this.remarks,
  });

  final int id;
  final int materialId;
  final String materialName;
  final String code;
  final String? uom;
  final int? inwardTypeId;
  final int? uoMid;
  final double quantity;
  final double taggedQuantity;
  final String? remarks;

  /// Shown in search list / selection field, e.g. `Mild Steel Sheet (MS001)`.
  String get displayLabel {
    final name = materialName.trim();
    final materialCode = code.trim();
    if (name.isEmpty) return materialCode;
    if (materialCode.isEmpty) return name;
    return '$name ($materialCode)';
  }

  factory MaterialByInwardTypeModel.fromJson(Map<String, dynamic> json) {
    return MaterialByInwardTypeModel(
      id: _toInt(json['id'] ?? json['Id']) ?? 0,
      materialId: _toInt(json['materialId'] ?? json['MaterialId']) ?? 0,
      materialName: _str(json['materialName'] ?? json['MaterialName']),
      code: _str(json['code'] ?? json['Code']),
      uom: _nullableStr(json['uom'] ?? json['Uom'] ?? json['UOM']),
      inwardTypeId: _toInt(json['inwardTypeId'] ?? json['InwardTypeId']),
      uoMid: _toInt(json['uoMid'] ?? json['UoMid'] ?? json['UOMId']),
      quantity: _toDouble(json['quantity'] ?? json['Quantity']) ?? 0,
      taggedQuantity:
          _toDouble(json['taggedQuantity'] ?? json['TaggedQuantity']) ?? 0,
      remarks: _nullableStr(json['remarks'] ?? json['Remarks']),
    );
  }

  static List<MaterialByInwardTypeModel> listFromResponse(dynamic response) {
    final list = _extractList(response);
    return list
        .whereType<Map>()
        .map(
          (item) => MaterialByInwardTypeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.materialId > 0 || item.materialName.isNotEmpty)
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

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static String? _nullableStr(dynamic value) {
    final text = _str(value);
    return text.isEmpty ? null : text;
  }
}
