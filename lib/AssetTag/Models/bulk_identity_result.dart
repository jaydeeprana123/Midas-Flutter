import 'package:midas/Location/Models/location_asset_model.dart';

class BulkIdentityResult {
  const BulkIdentityResult({
    required this.succeeded,
    required this.message,
    required this.assets,
  });

  final bool succeeded;
  final String message;
  final List<LocationAssetModel> assets;

  factory BulkIdentityResult.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true || json['IsSuccess'] == true;
    final status = json['status'] ?? json['Status'];
    return BulkIdentityResult(
      succeeded: isSuccess || status == 200,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      assets: LocationAssetModel.listFromBulkIdentity(json),
    );
  }
}
