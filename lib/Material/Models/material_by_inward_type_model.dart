import 'dart:convert';

class MaterialInwardTaggingDetailModel {
  const MaterialInwardTaggingDetailModel({
    required this.id,
    required this.tagCode,
    this.materialTagingId,
    this.midasSerialNo,
    this.isLocationAssign = false,
    this.isTagAssign = false,
    this.locationCode,
  });

  final int id;
  final int? materialTagingId;
  final String tagCode;
  final String? midasSerialNo;
  final bool isLocationAssign;
  final bool isTagAssign;
  final String? locationCode;

  factory MaterialInwardTaggingDetailModel.fromJson(Map<String, dynamic> json) {
    return MaterialInwardTaggingDetailModel(
      id: _toInt(json['id'] ?? json['Id']) ?? 0,
      materialTagingId:
          _toInt(json['materialTagingId'] ?? json['MaterialTagingId']),
      tagCode: _str(json['tagCode'] ?? json['TagCode']),
      midasSerialNo:
          _nullableStr(json['midasSerialNo'] ?? json['MidasSerialNo']),
      isLocationAssign:
          json['isLocationAssign'] == true || json['IsLocationAssign'] == true,
      isTagAssign: json['isTagAssign'] == true || json['IsTagAssign'] == true,
      locationCode:
          _nullableStr(json['locationCode'] ?? json['LocationCode']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'materialTagingId': materialTagingId,
        'tagCode': tagCode,
        'midasSerialNo': midasSerialNo,
        'isLocationAssign': isLocationAssign,
        'isTagAssign': isTagAssign,
        'locationCode': locationCode,
      };

  static List<MaterialInwardTaggingDetailModel> listFromJson(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => MaterialInwardTaggingDetailModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.tagCode.isNotEmpty)
        .toList();
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

class MaterialByInwardTypeModel {
  const MaterialByInwardTypeModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.code,
    this.uom,
    this.inwardTypeId,
    this.inwardTypeName,
    this.inwardId,
    this.rowIndex,
    this.uoMid,
    this.quantity = 0,
    this.taggedQuantity = 0,
    this.remarks,
    this.materialTagingDetails = const [],
  });

  final int id;
  final int materialId;
  final String materialName;
  final String code;
  final String? uom;
  final int? inwardTypeId;
  final String? inwardTypeName;
  final int? inwardId;
  final int? rowIndex;
  final int? uoMid;
  final double quantity;
  final double taggedQuantity;
  final String? remarks;
  final List<MaterialInwardTaggingDetailModel> materialTagingDetails;

  /// Shown in search list / selection field, e.g. `Mild Steel Sheet (MS001)`.
  String get displayLabel {
    final name = materialName.trim();
    final materialCode = code.trim();
    if (name.isEmpty) return materialCode;
    if (materialCode.isEmpty) return name;
    return '$name ($materialCode)';
  }

  /// Unique key for multi-select identity.
  String get selectionKey => 'm$materialId-$id';

  /// Tag codes from nested `materialTagingDetails` for LinkMaterialLocation.
  List<String> get tagCodes => materialTagingDetails
      .map((detail) => detail.tagCode.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  String get listSubtitle {
    final parts = <String>[];
    if (uom != null && uom!.trim().isNotEmpty) {
      parts.add(uom!.trim());
    }
    if (materialTagingDetails.isNotEmpty) {
      final tags = tagCodes.join(', ');
      if (tags.isNotEmpty) {
        parts.add('Tag: $tags');
      }
    } else if (taggedQuantity > 0) {
      parts.add(
        'Tagged: ${taggedQuantity % 1 == 0 ? taggedQuantity.toInt() : taggedQuantity}',
      );
    }
    return parts.join(' · ');
  }

  factory MaterialByInwardTypeModel.fromJson(Map<String, dynamic> json) {
    final details = MaterialInwardTaggingDetailModel.listFromJson(
      json['materialTagingDetails'] ??
          json['materialTaggingDetails'] ??
          json['MaterialTagingDetails'],
    );
    final taggedQty =
        _toDouble(json['taggedQuantity'] ?? json['TaggedQuantity']);

    return MaterialByInwardTypeModel(
      id: _toInt(json['id'] ?? json['Id']) ?? 0,
      materialId: _toInt(json['materialId'] ?? json['MaterialId']) ?? 0,
      materialName: _str(json['materialName'] ?? json['MaterialName']),
      code: _str(json['code'] ?? json['Code']),
      uom: _nullableStr(json['uom'] ?? json['Uom'] ?? json['UOM']),
      inwardTypeId: _toInt(json['inwardTypeId'] ?? json['InwardTypeId']),
      inwardTypeName:
          _nullableStr(json['inwardTypeName'] ?? json['InwardTypeName']),
      inwardId: _toInt(json['inwardId'] ?? json['InwardId']),
      rowIndex: _toInt(json['rowIndex'] ?? json['RowIndex']),
      uoMid: _toInt(json['uoMid'] ?? json['UoMid'] ?? json['UOMId']),
      quantity: _toDouble(json['quantity'] ?? json['Quantity']) ?? 0,
      taggedQuantity: taggedQty ?? (details.isNotEmpty ? details.length.toDouble() : 0),
      remarks: _nullableStr(json['remarks'] ?? json['Remarks']),
      materialTagingDetails: details,
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

  Map<String, dynamic> toSqliteMap(int inwardTypeId) => {
        'inward_type_id': inwardTypeId,
        'material_row_id': id,
        'material_id': materialId,
        'material_name': materialName,
        'code': code,
        'uom': uom,
        'uo_mid': uoMid,
        'quantity': quantity,
        'tagged_quantity': taggedQuantity,
        'remarks': remarks,
        'tagging_details_json': jsonEncode(
          materialTagingDetails.map((item) => item.toJson()).toList(),
        ),
      };

  factory MaterialByInwardTypeModel.fromSqlite(Map<String, dynamic> row) {
    final detailsRaw = row['tagging_details_json'];
    List<MaterialInwardTaggingDetailModel> details = const [];
    if (detailsRaw is String && detailsRaw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(detailsRaw);
        details = MaterialInwardTaggingDetailModel.listFromJson(decoded);
      } catch (_) {}
    }

    return MaterialByInwardTypeModel(
      id: _toInt(row['material_row_id']) ?? 0,
      materialId: _toInt(row['material_id']) ?? 0,
      materialName: _str(row['material_name']),
      code: _str(row['code']),
      uom: _nullableStr(row['uom']),
      inwardTypeId: _toInt(row['inward_type_id']),
      uoMid: _toInt(row['uo_mid']),
      quantity: _toDouble(row['quantity']) ?? 0,
      taggedQuantity: _toDouble(row['tagged_quantity']) ?? 0,
      remarks: _nullableStr(row['remarks']),
      materialTagingDetails: details,
    );
  }
}
