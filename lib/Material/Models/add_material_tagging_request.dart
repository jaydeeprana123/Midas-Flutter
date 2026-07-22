class AddMaterialTaggingRequest {
  const AddMaterialTaggingRequest({
    required this.inwardTypeId,
    required this.materialId,
    required this.quantity,
    required this.materialTagingDetails,
    this.inwardId,
    this.remarks,
  });

  final int inwardTypeId;
  final int? inwardId;
  final int materialId;
  final double quantity;
  final String? remarks;
  final List<AddMaterialTaggingDetails> materialTagingDetails;

  Map<String, dynamic> toJson() => {
        'inwardTypeId': inwardTypeId,
        'inwardId': inwardId,
        'materialId': materialId,
        'quantity': quantity,
        'remarks': remarks,
        'materialTagingDetails':
            materialTagingDetails.map((item) => item.toJson()).toList(),
      };

  factory AddMaterialTaggingRequest.fromJson(Map<String, dynamic> json) {
    final details = json['materialTagingDetails'] ?? json['MaterialTagingDetails'];
    return AddMaterialTaggingRequest(
      inwardTypeId: _toInt(json['inwardTypeId'] ?? json['InwardTypeId']) ?? 0,
      inwardId: _toInt(json['inwardId'] ?? json['InwardId']),
      materialId: _toInt(json['materialId'] ?? json['MaterialId']) ?? 0,
      quantity: _toDouble(json['quantity'] ?? json['Quantity']) ?? 0,
      remarks: _nullableStr(json['remarks'] ?? json['Remarks']),
      materialTagingDetails: details is List
          ? details
              .whereType<Map>()
              .map(
                (item) => AddMaterialTaggingDetails.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
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

  static String? _nullableStr(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}

class AddMaterialTaggingDetails {
  const AddMaterialTaggingDetails({
    required this.tagCode,
    this.tagTypeId,
    this.mfgSerialNo,
    this.batchNo,
    this.isLocationAssign,
    this.isTransit,
  });

  final int? tagTypeId;
  final String? mfgSerialNo;
  final String? batchNo;
  final String tagCode;
  final bool? isLocationAssign;
  final bool? isTransit;

  Map<String, dynamic> toJson() => {
        'tagTypeId': tagTypeId,
        'mfgSerialNo': mfgSerialNo,
        'batchNo': batchNo,
        'tagCode': tagCode,
        'isLocationAssign': isLocationAssign,
        'isTransit': isTransit,
      };

  factory AddMaterialTaggingDetails.fromJson(Map<String, dynamic> json) {
    return AddMaterialTaggingDetails(
      tagTypeId: _toInt(json['tagTypeId'] ?? json['TagTypeId']),
      mfgSerialNo: _nullableStr(json['mfgSerialNo'] ?? json['MfgSerialNo']),
      batchNo: _nullableStr(json['batchNo'] ?? json['BatchNo']),
      tagCode: (json['tagCode'] ?? json['TagCode'] ?? '').toString(),
      isLocationAssign:
          json['isLocationAssign'] as bool? ?? json['IsLocationAssign'] as bool?,
      isTransit: json['isTransit'] as bool? ?? json['IsTransit'] as bool?,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _nullableStr(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}
