import 'package:midas/AssetTag/Models/asset_link_tag_model.dart';
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
}
