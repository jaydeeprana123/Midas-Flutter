import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/tagged_material_item_model.dart';
import 'package:midas/Shared/Services/api_client.dart';
import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/Material/Models/add_material_tagging_request.dart';
import 'package:midas/Shared/Services/app_logger.dart';

class MaterialRepository {
  MaterialRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Materials for a given inward/source type.
  /// `GET /api/MaterialTagging/GetAllMaterialByInwardTypeId/{Id}`
  Future<List<MaterialByInwardTypeModel>> getAllMaterialByInwardTypeId(
    int inwardTypeId, {
    bool? onlyTaggedPendingLocation,
  }) async {
    final json = onlyTaggedPendingLocation == null
        ? await _apiClient.get(
            '/api/MaterialTagging/GetAllMaterialByInwardTypeId/$inwardTypeId',
          )
        : await _apiClient.getWithQuery(
            '/api/MaterialTagging/GetAllMaterialByInwardTypeId/$inwardTypeId',
            queryParameters: {
              'onlyTaggedPendingLocation': onlyTaggedPendingLocation,
            },
          );
    return MaterialByInwardTypeModel.listFromResponse(json);
  }

  /// Tagged materials for an inward/source type.
  /// `GET /api/MaterialTagging/GetAllTaggedMaterialByInwardTypeId/{Id}`
  Future<List<TaggedMaterialItemModel>> getAllTaggedMaterialByInwardTypeId(
    int inwardTypeId,
  ) async {
    final json = await _apiClient.get(
      '/api/MaterialTagging/GetAllTaggedMaterialByInwardTypeId/$inwardTypeId',
    );
    return TaggedMaterialItemModel.listFromResponse(json);
  }

  /// Assigns a tag to a material.
  /// `POST /api/MaterialTagging/InsertMaterialTagging`
  Future<StockInResponseModel> insertMaterialTagging(
    AddMaterialTaggingRequest request,
  ) async {
    final json = await _apiClient.post(
      '/api/MaterialTagging/InsertMaterialTagging',
      body: request.toJson(),
    );
    return StockInResponseModel.fromJson(json);
  }

  /// Fetches material tagging details (filter by tag client-side).
  /// `GET /api/MaterialTagging/GetMaterialTaggingDetails`
  Future<MaterialTaggingDetailsResult> getMaterialTaggingDetails({
    String? tagCode,
  }) async {
    final json = tagCode == null || tagCode.trim().isEmpty
        ? await _apiClient.get('/api/MaterialTagging/GetMaterialTaggingDetails')
        : await _apiClient.getWithQuery(
            '/api/MaterialTagging/GetMaterialTaggingDetails',
            queryParameters: {'tagCode': tagCode.trim()},
          );

    final items = MaterialTaggingDetailModel.listFromResponse(json);
    return MaterialTaggingDetailsResult(
      isSuccess: json['isSuccess'] == true || json['status'] == 200,
      status: _toInt(json['status']) ?? 0,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      items: items,
    );
  }

  /// Unassigns material tag(s) by detail id(s).
  /// `POST /api/MaterialTagging/DeLinkMaterialTag` body: `[detailId, ...]`
  Future<StockInResponseModel> deLinkMaterialTag({
    required List<int> detailIds,
  }) async {
    final json = await _apiClient.postRaw(
      '/api/MaterialTagging/DeLinkMaterialTag',
      data: detailIds,
    );
    return StockInResponseModel.fromJson(json);
  }

  /// Links material tag detail(s) to a location.
  /// `POST /api/MaterialTagging/LinkMaterialLocation?LocationCode=`
  Future<StockInResponseModel> linkMaterialLocation({
    required String locationCode,
    required List<int> detailIds,
  }) async {
    final json = await _apiClient.postRaw(
      '/api/MaterialTagging/LinkMaterialLocation',
      data: detailIds,
      queryParameters: {'LocationCode': locationCode},
    );
    return StockInResponseModel.fromJson(json);
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class MaterialTaggingDetailsResult {
  const MaterialTaggingDetailsResult({
    required this.isSuccess,
    required this.status,
    required this.message,
    required this.items,
  });

  final bool isSuccess;
  final int status;
  final String message;
  final List<MaterialTaggingDetailModel> items;

  bool get succeeded => isSuccess || status == 200;
}
