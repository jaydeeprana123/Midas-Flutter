import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/Location/Models/add_asset_location_model.dart';
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
}
