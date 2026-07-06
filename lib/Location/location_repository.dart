import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/Location/Models/add_asset_location_model.dart';
import 'package:midas/Location/Models/change_location_remark_model.dart';
import 'package:midas/Location/Models/location_asset_model.dart';
import 'package:midas/Location/Models/update_asset_location_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class LocationRepository {
  LocationRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Assigns a location to one or more asset tags.
  /// `POST /api/Location/InsertAssetLocation`
  Future<StockInResponseModel> insertAssetLocation(
    AddAssetLocationModel request,
  ) async {
    final json = await _apiClient.post(
      '/api/Location/InsertAssetLocation',
      body: request.toJson(),
    );
    return StockInResponseModel.fromJson(json);
  }

  /// Fetches assets assigned to a location code.
  /// `GET /api/Location/GetAssetDetailsByLocationCode/{LocationCode}`
  Future<LocationAssetsResult> getAssetDetailsByLocationCode(
    String locationCode,
  ) async {
    final json = await _apiClient.get(
      '/api/Location/GetAssetDetailsByLocationCode/${Uri.encodeComponent(locationCode)}',
    );
    return LocationAssetsResult.fromJson(json);
  }

  /// Fetches change-location remarks for shift or transit.
  /// `GET /api/ChangelocationRemarks/GetAllChangelocationRemark?IsTransit=`
  Future<List<ChangeLocationRemarkModel>> getChangeLocationRemarks({
    required bool isTransit,
  }) async {
    final json = await _apiClient.getWithQuery(
      '/api/ChangelocationRemarks/GetAllChangelocationRemark',
      queryParameters: {'IsTransit': isTransit},
    );
    return ChangeLocationRemarkModel.listFromResponse(json);
  }

  /// Updates asset locations to a new destination.
  /// `POST /api/Location/UpdateAssetLocation`
  Future<StockInResponseModel> updateAssetLocation(
    UpdateAssetLocationModel request,
  ) async {
    final json = await _apiClient.post(
      '/api/Location/UpdateAssetLocation',
      body: request.toJson(),
    );
    return StockInResponseModel.fromJson(json);
  }
}

class LocationAssetsResult {
  const LocationAssetsResult({
    required this.succeeded,
    required this.message,
    required this.assets,
  });

  final bool succeeded;
  final String message;
  final List<LocationAssetModel> assets;

  factory LocationAssetsResult.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true || json['IsSuccess'] == true;
    final status = json['status'] ?? json['Status'];
    return LocationAssetsResult(
      succeeded: isSuccess || status == 200,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      assets: LocationAssetModel.listFromResponse(json),
    );
  }
}
