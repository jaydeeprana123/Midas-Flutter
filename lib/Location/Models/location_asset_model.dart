import 'package:midas/Location/Models/location_path_model.dart';

class LocationAssetModel {
  const LocationAssetModel({
    required this.assetName,
    required this.tagCode,
    this.assetCode = '',
    this.serialNo = '',
    this.locationCode = '',
    this.path,
  });

  final String assetName;
  final String tagCode;
  final String assetCode;
  final String serialNo;
  final String locationCode;
  final LocationPathModel? path;

  String get locationPathLabel => path?.displayPath ?? '';

  factory LocationAssetModel.fromJson(Map<String, dynamic> json) =>
      LocationAssetModel(
        assetName: _str(json['assetName'] ?? json['AssetName']),
        tagCode: _str(
          json['tagCodes'] ??
              json['TagCodes'] ??
              json['tagCode'] ??
              json['TagCode'],
        ),
        assetCode: _str(json['assetCode'] ?? json['AssetCode']),
        serialNo: _str(json['serialNo'] ?? json['SerialNo']),
        locationCode: _str(json['locationCode'] ?? json['LocationCode']),
        path: json['path'] is Map || json['Path'] is Map
            ? LocationPathModel.fromJson(
                Map<String, dynamic>.from(
                  (json['path'] ?? json['Path']) as Map,
                ),
              )
            : null,
      );

  static List<LocationAssetModel> listFromResponse(dynamic response) {
    if (response is! Map) return const [];

    final data = response['data'] ?? response['Data'];
    if (data is! Map) return const [];

    final assets = data['asset'] ?? data['Asset'];
    if (assets is! List) return const [];

    return assets
        .whereType<Map>()
        .map((item) => LocationAssetModel.fromJson(Map<String, dynamic>.from(item)))
        .where((asset) => asset.tagCode.isNotEmpty)
        .toList();
  }

  static List<LocationAssetModel> listFromBulkIdentity(dynamic response) {
    if (response is! Map) return const [];

    final data = response['data'] ?? response['Data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((item) => LocationAssetModel.fromJson(Map<String, dynamic>.from(item)))
        .where((asset) => asset.tagCode.isNotEmpty)
        .toList();
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();
}
