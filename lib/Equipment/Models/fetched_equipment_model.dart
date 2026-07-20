class FetchedEquipmentModel {
  const FetchedEquipmentModel({
    required this.id,
    required this.equipmentCode,
    this.customerId,
    this.customerName,
    this.equipmentTypesId,
    this.equipmentTypeName,
    this.equipmentSubTypesId,
    this.equipmentSubTypeName,
    this.customerTagNumber,
    this.inTesting,
    this.jobCardNumber,
    this.tagId,
    this.tagCode,
    this.allFetchDetails,
  });

  final int id;
  final int? customerId;
  final String? customerName;
  final int? equipmentTypesId;
  final String? equipmentTypeName;
  final int? equipmentSubTypesId;
  final String? equipmentSubTypeName;
  final String equipmentCode;
  final String? customerTagNumber;
  final bool? inTesting;
  final String? jobCardNumber;
  final int? tagId;
  final String? tagCode;
  final String? allFetchDetails;

  bool get hasClickableJobCard {
    final value = jobCardNumber?.trim();
    if (value == null || value.isEmpty) return false;
    return value.toUpperCase() != 'N/A';
  }

  List<MapEntry<String, String>> get detailPairs {
    final raw = allFetchDetails?.trim();
    if (raw == null || raw.isEmpty) return const [];

    return raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((pair) {
          final separatorIndex = pair.indexOf(':');
          if (separatorIndex == -1) return null;
          final key = pair.substring(0, separatorIndex).trim();
          final value = pair.substring(separatorIndex + 1).trim();
          if (key.isEmpty) return null;
          return MapEntry(key, value);
        })
        .whereType<MapEntry<String, String>>()
        .toList();
  }

  factory FetchedEquipmentModel.fromJson(Map<String, dynamic> json) =>
      FetchedEquipmentModel(
        id: _toInt(json['id'] ?? json['Id']) ?? 0,
        customerId: _toInt(json['customerId'] ?? json['CustomerId']),
        customerName: _nullableStr(json['customerName'] ?? json['CustomerName']),
        equipmentTypesId: _toInt(
          json['equipmentTypesId'] ?? json['EquipmentTypesId'],
        ),
        equipmentTypeName: _nullableStr(
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
        jobCardNumber: _nullableStr(json['jobCardNumber'] ?? json['JobCardNumber']),
        tagId: _toInt(json['tagId'] ?? json['TagId']),
        tagCode: _nullableStr(json['tagCode'] ?? json['TagCode']),
        allFetchDetails: _nullableStr(
          json['allFetchDetails'] ?? json['AllFetchDetails'],
        ),
      );

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

class FetchedEquipmentResult {
  const FetchedEquipmentResult({
    required this.succeeded,
    required this.message,
    this.equipment,
  });

  final bool succeeded;
  final String message;
  final FetchedEquipmentModel? equipment;

  factory FetchedEquipmentResult.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true || json['IsSuccess'] == true;
    final status = json['status'] ?? json['Status'];
    final succeeded = isSuccess || status == 200;

    final data = json['data'] ?? json['Data'];
    FetchedEquipmentModel? equipment;
    if (data is Map) {
      equipment = FetchedEquipmentModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return FetchedEquipmentResult(
      succeeded: succeeded,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      equipment: equipment,
    );
  }
}
