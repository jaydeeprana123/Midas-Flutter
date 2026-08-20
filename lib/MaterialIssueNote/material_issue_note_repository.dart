import 'package:midas/AssetTag/Models/stock_in_response_model.dart';
import 'package:midas/MaterialIssueNote/Models/add_material_issue_note_request.dart';
import 'package:midas/MaterialIssueNote/Models/indent_no_model.dart';
import 'package:midas/MaterialIssueNote/Models/indent_type_model.dart';
import 'package:midas/MaterialIssueNote/Models/material_indent_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class MaterialIssueNoteRepository {
  MaterialIssueNoteRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /api/MaterialIssueNote/GenerateMaterialIsuueNoteNumber`
  Future<String> generateMaterialIssueNoteNumber() async {
    final json = await _apiClient.get(
      '/api/MaterialIssueNote/GenerateMaterialIsuueNoteNumber',
    );
    return _extractString(json['data'] ?? json['Data']);
  }

  /// `GET /api/MaterialIssueNote/GetAllIndentType`
  Future<List<IndentTypeModel>> getAllIndentTypes() async {
    final json = await _apiClient.get('/api/MaterialIssueNote/GetAllIndentType');
    return IndentTypeModel.listFromResponse(json);
  }

  /// `GET /api/MaterialIssueNote/GetAllIndentNoByIndentTypeId/{indentTypeId}`
  Future<List<IndentNoModel>> getAllIndentNoByIndentTypeId(
    int indentTypeId,
  ) async {
    final json = await _apiClient.get(
      '/api/MaterialIssueNote/GetAllIndentNoByIndentTypeId/$indentTypeId',
    );
    return IndentNoModel.listFromResponse(json);
  }

  /// `GET /api/MaterialIndent/GetMaterialIndentById/{indentEntryId}`
  Future<MaterialIndentModel?> getMaterialIndentById(int indentEntryId) async {
    final json = await _apiClient.get(
      '/api/MaterialIndent/GetMaterialIndentById/$indentEntryId',
    );
    return MaterialIndentModel.fromResponse(json);
  }

  /// `POST /api/MaterialIssueNote/InsertMaterialIssueNote`
  Future<StockInResponseModel> insertMaterialIssueNote(
    AddMaterialIssueNoteRequest request,
  ) async {
    final json = await _apiClient.post(
      '/api/MaterialIssueNote/InsertMaterialIssueNote',
      body: request.toJson(),
    );
    return StockInResponseModel.fromJson(json);
  }

  static String _extractString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map) {
      return (value['issueNoteNo'] ??
              value['IssueNoteNo'] ??
              value['number'] ??
              value['Number'] ??
              '')
          .toString()
          .trim();
    }
    return value.toString().trim();
  }
}
