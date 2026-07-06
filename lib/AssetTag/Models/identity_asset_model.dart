class IdentityAssetModel {
  const IdentityAssetModel({
    required this.assetName,
    required this.assetCode,
    required this.serialNo,
  });

  final String assetName;
  final String assetCode;
  final String serialNo;

  factory IdentityAssetModel.fromJson(Map<String, dynamic> json) =>
      IdentityAssetModel(
        assetName: _toStr(
          json['assetName'] ?? json['AssetName'] ?? json['name'] ?? json['Name'],
        ),
        assetCode: _toStr(
          json['assetCode'] ??
              json['AssetCode'] ??
              json['code'] ??
              json['Code'],
        ),
        serialNo: _toStr(
          json['serialNo'] ??
              json['SerialNo'] ??
              json['assetSerialNo'] ??
              json['AssetSerialNo'] ??
              json['mfgSerialNo'] ??
              json['MfgSerialNo'],
        ),
      );

  static String _toStr(dynamic value) => (value ?? '').toString().trim();
}

class IdentityAssetResult {
  const IdentityAssetResult({
    required this.succeeded,
    required this.message,
    this.asset,
  });

  final bool succeeded;
  final String message;
  final IdentityAssetModel? asset;

  factory IdentityAssetResult.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true || json['IsSuccess'] == true;
    final status = json['status'] ?? json['Status'];
    final succeeded = isSuccess || status == 200;

    final data = json['data'] ?? json['Data'];
    IdentityAssetModel? asset;
    if (data is Map) {
      asset = IdentityAssetModel.fromJson(Map<String, dynamic>.from(data));
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      asset = IdentityAssetModel.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    }

    return IdentityAssetResult(
      succeeded: succeeded,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      asset: asset,
    );
  }
}
