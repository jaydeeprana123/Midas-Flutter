import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/Equipment/Models/equipment_data_model.dart';
import 'package:midas/Equipment/Models/equipment_link_request.dart';
import 'package:midas/Shared/Services/api_client.dart';

class EquipmentRepository {
  EquipmentRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Unlinked (or linked) equipment for search.
  /// `GET /api/EquipmentTagMapping/GetAllEquipmentLinkStatus?IsLink=`
  Future<List<EquipmentDataModel>> getAllEquipmentLinkStatus({
    required bool isLink,
  }) async {
    final json = await _apiClient.getWithQuery(
      '/api/EquipmentTagMapping/GetAllEquipmentLinkStatus',
      queryParameters: {'IsLink': isLink},
    );
    return EquipmentDataModel.listFromResponse(json);
  }

  /// Links RFID/QR tag(s) to equipment.
  /// `POST /api/EquipmentTagMapping/EquipmentTagMappingLinkAsync?IsAndroidApplication=`
  Future<StockInResponseModel> linkEquipmentTag({
    required List<EquipmentLinkRequest> requests,
    bool isAndroidApplication = true,
  }) async {
    final json = await _apiClient.postRaw(
      '/api/EquipmentTagMapping/EquipmentTagMappingLinkAsync',
      data: requests.map((item) => item.toJson()).toList(),
      queryParameters: {'IsAndroidApplication': isAndroidApplication},
    );
    return StockInResponseModel.fromJson(json);
  }
}
