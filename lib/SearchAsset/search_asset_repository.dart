import 'package:midas/SearchAsset/Models/dashboard_search_asset_model.dart';
import 'package:midas/SearchAsset/Models/gps_data_model.dart';
import 'package:midas/SearchAsset/Models/search_asset_item_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class SearchAssetRepository {
  SearchAssetRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /api/Asset/SearchAssetForMobileApp?assetname=`
  Future<List<SearchAssetItemModel>> searchAssetsForMobileApp(
    String assetName,
  ) async {
    final json = await _apiClient.getWithQuery(
      '/api/Asset/SearchAssetForMobileApp',
      queryParameters: {'assetname': assetName},
    );
    return SearchAssetItemModel.listFromResponse(json);
  }

  /// `GET /api/Asset/DashboardSearchAsset?assetname=`
  Future<DashboardSearchResult> dashboardSearchAsset(String tagCode) async {
    final json = await _apiClient.getWithQuery(
      '/api/Asset/DashboardSearchAsset',
      queryParameters: {'assetname': tagCode},
    );
    return DashboardSearchResult.fromResponse(json);
  }

  /// `POST /api/GPS/InsertGPSData` with a JSON array of GPS readings.
  Future<GpsInsertResponse> insertGpsData(List<GpsDataModel> readings) async {
    final json = await _apiClient.postRaw(
      '/api/GPS/InsertGPSData',
      data: readings.map((item) => item.toJson()).toList(),
    );
    return GpsInsertResponse.fromJson(json);
  }
}
