class MaterialIndentModel {
  const MaterialIndentModel({
    required this.id,
    required this.indentNo,
    this.department = '',
    this.remarks = '',
    this.details = const [],
  });

  final int id;
  final String indentNo;
  final String department;
  final String remarks;
  final List<MaterialIndentDetailModel> details;

  factory MaterialIndentModel.fromJson(Map<String, dynamic> json) {
    final detailsJson =
        json['materialIndentDetails'] ??
        json['MaterialIndentDetails'] ??
        json['details'] ??
        json['Details'];

    return MaterialIndentModel(
      id: _toInt(json['id'] ?? json['Id']) ?? 0,
      indentNo: _str(json['indentNo'] ?? json['IndentNo']),
      department: _str(json['department'] ?? json['Department']),
      remarks: _str(json['remarks'] ?? json['Remarks']),
      details: MaterialIndentDetailModel.listFromJson(detailsJson),
    );
  }

  static MaterialIndentModel? fromResponse(dynamic response) {
    if (response is Map) {
      final data = response['data'] ?? response['Data'] ?? response;
      if (data is Map) {
        return MaterialIndentModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class MaterialIndentDetailModel {
  const MaterialIndentDetailModel({
    required this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.availableStock,
    required this.indentQty,
    this.unitId,
    this.uomName = '',
    this.indentUomName = '',
  });

  final int materialId;
  final String materialName;
  final String materialCode;
  final double availableStock;
  final double indentQty;
  final int? unitId;
  final String uomName;
  final String indentUomName;

  factory MaterialIndentDetailModel.fromJson(Map<String, dynamic> json) {
    final uom = _str(
      json['uomName'] ?? json['UomName'] ?? json['uom'] ?? json['UOM'],
    );
    final indentUom = _str(
      json['indentUomName'] ??
          json['IndentUomName'] ??
          json['indentUom'] ??
          json['IndentUOM'] ??
          uom,
    );

    return MaterialIndentDetailModel(
      materialId: _toInt(json['materialId'] ?? json['MaterialId']) ?? 0,
      materialName: _str(json['materialName'] ?? json['MaterialName']),
      materialCode: _str(
        json['materialCode'] ?? json['MaterialCode'] ?? json['code'] ?? json['Code'],
      ),
      availableStock:
          _toDouble(json['availableStock'] ?? json['AvailableStock']) ?? 0,
      indentQty:
          _toDouble(
            json['itemQuantity'] ??
                json['ItemQuantity'] ??
                json['indentQty'] ??
                json['IndentQty'],
          ) ??
          0,
      unitId: _toInt(
        json['unitId'] ?? json['UnitId'] ?? json['uomId'] ?? json['UomId'],
      ),
      uomName: uom,
      indentUomName: indentUom,
    );
  }

  static List<MaterialIndentDetailModel> listFromJson(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => MaterialIndentDetailModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.materialId > 0 || item.materialName.isNotEmpty)
        .toList();
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

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
}
