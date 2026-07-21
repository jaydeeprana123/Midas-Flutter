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
}
