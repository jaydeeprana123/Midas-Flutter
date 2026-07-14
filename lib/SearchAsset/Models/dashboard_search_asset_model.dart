import 'dart:convert';

DashboardSearchResult dashboardSearchResultFromJson(String str) =>
    DashboardSearchResult.fromResponse(json.decode(str));

/// Result of `GET /api/Asset/DashboardSearchAsset`.
class DashboardSearchResult {
  final bool isSuccess;
  final String message;
  final List<DashboardSearchAssetModel> assets;

  DashboardSearchResult({
    required this.isSuccess,
    required this.message,
    required this.assets,
  });

  String? get targetRfid {
    for (final asset in assets) {
      final rfid = asset.rfid.trim();
      if (rfid.isNotEmpty) return rfid;
    }
    return null;
  }

  factory DashboardSearchResult.fromResponse(dynamic response) {
    if (response is! Map) {
      return DashboardSearchResult(
        isSuccess: false,
        message: '',
        assets: const [],
      );
    }
    final map = Map<String, dynamic>.from(response);
    final data = map['data'] ?? map['Data'];
    final list = data is List ? data : const [];
    return DashboardSearchResult(
      isSuccess: map['isSuccess'] == true,
      message: (map['message'] ?? '').toString(),
      assets: list
          .whereType<Map>()
          .map((item) =>
              DashboardSearchAssetModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class DashboardSearchAssetModel {
  final String assetCode;
  final String tagCode;
  final String assetName;
  final String rfid;
  final String locationCode;
  final String serialNo;

  DashboardSearchAssetModel({
    required this.assetCode,
    required this.tagCode,
    required this.assetName,
    required this.rfid,
    required this.locationCode,
    required this.serialNo,
  });

  factory DashboardSearchAssetModel.fromJson(Map<String, dynamic> json) =>
      DashboardSearchAssetModel(
        assetCode: _toStr(json['assetCode'] ?? json['AssetCode']),
        tagCode: _toStr(json['tagCode'] ?? json['TagCode']),
        assetName: _toStr(json['assetName'] ?? json['AssetName']),
        rfid: _toStr(json['rfid'] ?? json['Rfid'] ?? json['RFID']),
        locationCode: _toStr(json['locationCode'] ?? json['LocationCode']),
        serialNo: _toStr(json['serialNo'] ?? json['SerialNo']),
      );

  static String _toStr(dynamic value) => (value ?? '').toString().trim();
}
