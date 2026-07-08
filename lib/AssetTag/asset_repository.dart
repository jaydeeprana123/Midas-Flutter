import 'package:midas/AssetTag/Models/asset_link_tag_model.dart';
import 'package:midas/AssetTag/Models/bulk_identity_result.dart';
import 'package:midas/AssetTag/Models/identity_asset_model.dart';
import 'package:midas/AssetTag/Models/stock_in_request_model.dart';
import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class AssetRepository {
  AssetRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Searches assets that can be linked with a tag.
  /// `GET /api/Asset/GetAllAssetsForLinkTag?AssetName=&orgId=`
  Future<List<AssetLinkTagModel>> getAssetsForLinkTag({
    required String assetName,
    required int orgId,
  }) async {
    final json = await _apiClient.getWithQuery(
      '/api/Asset/GetAllAssetsForLinkTag',
      queryParameters: {
        'AssetName': assetName,
        'orgId': orgId,
      },
    );
    return AssetLinkTagModel.listFromResponse(json);
  }

  /// Inserts a stock-in record that assigns a tag to an asset.
  /// `POST /api/AssetStockIn/InsertAssetStockInForMobApp`
  Future<StockInResponseModel> insertAssetStockIn(
    StockInRequestModel request,
  ) async {
    final json = await _apiClient.post(
      '/api/AssetStockIn/InsertAssetStockInForMobApp',
      body: request.toJson(),
    );
    return StockInResponseModel.fromJson(json);
  }

  /// Identifies an asset by QR / RFID tag for the mobile app.
  /// `GET /api/Asset/IdentityAssetForMobileApp?assetdata=`
  Future<IdentityAssetResult> identityAssetForMobileApp({
    required String assetData,
  }) async {
    final json = await _apiClient.getWithQuery(
      '/api/Asset/IdentityAssetForMobileApp',
      queryParameters: {'assetdata': assetData},
    );
    return IdentityAssetResult.fromJson(json);
  }

  /// De-assigns a tag from an asset.
  /// `POST /api/AssetStockIn/UpdateAssetStockInDetailsDelinkModel/{TagCode}`
  Future<StockInResponseModel> deassignAssetTag({
    required String tagCode,
  }) async {
    final json = await _apiClient.post(
      '/api/AssetStockIn/UpdateAssetStockInDetailsDelinkModel/${Uri.encodeComponent(tagCode)}',
    );
    return StockInResponseModel.fromJson(json);
  }

  /// Identifies multiple assets by tag codes for the mobile app.
  /// `POST /api/Asset/BulkIdentityAssetsForMobileApp`
  Future<BulkIdentityResult> bulkIdentityAssetsForMobileApp(
    List<String> tagCodes,
  ) async {
    final json = await _apiClient.postRaw(
      '/api/Asset/BulkIdentityAssetsForMobileApp',
      data: tagCodes,
    );
    return BulkIdentityResult.fromJson(json);
  }
}
