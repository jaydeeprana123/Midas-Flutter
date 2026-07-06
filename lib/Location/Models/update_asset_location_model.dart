class UpdateAssetLocationModel {
  UpdateAssetLocationModel({
    required this.locationCode,
    required this.isTransit,
    required this.tagCodes,
    required this.changeLocationRemarkId,
    this.remarks,
  });

  final String locationCode;
  final bool isTransit;
  final List<String> tagCodes;
  final int changeLocationRemarkId;
  final String? remarks;

  Map<String, dynamic> toJson() => {
        'locationCode': locationCode,
        'isTransit': isTransit,
        'tagCodes': tagCodes,
        'changeLocationRemarkId': changeLocationRemarkId,
        if (remarks != null && remarks!.isNotEmpty) 'remarks': remarks,
      };
}
