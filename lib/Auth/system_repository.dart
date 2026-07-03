import 'package:midas/Auth/Models/domain_model.dart';
import 'package:midas/Auth/Models/system_version_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class SystemRepository {
  SystemRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SystemVersionModel> fetchSystemVersionAndLabel() async {
    final json =
        await _apiClient.get('/api/Organization/GetSystemVersionAndOrgLabel');
    final data = _extractData(json);
    return SystemVersionModel.fromJson(data);
  }

  Future<List<DomainModel>> fetchDomains() async {
    final json = await _apiClient.get('/api/Login/GetAllDomains');
    final data = _extractData(json);
    final domains = data['domains'] ?? data['Domains'] ?? data;
    if (domains is List) {
      return domains
          .map((e) => DomainModel.fromDynamic(e))
          .where((e) => e.url.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> root) {
    final data =
        root['data'] ?? root['result'] ?? root['Data'] ?? root['Result'] ?? root;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }
}
