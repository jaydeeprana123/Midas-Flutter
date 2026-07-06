class AddAssetLocationModel {
  AddAssetLocationModel({
    required this.locationCode,
    required this.tagCodes,
  });

  final String locationCode;
  final List<String> tagCodes;

  Map<String, dynamic> toJson() => {
        'locationCode': locationCode,
        'tagCodes': tagCodes,
      };
}
