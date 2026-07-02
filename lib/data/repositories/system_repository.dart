import 'package:midas/data/models/app_domain.dart';
import 'package:midas/data/models/org_info.dart';
import 'package:midas/data/services/api_client.dart';

class SystemRepository {
  SystemRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<OrgInfo> fetchSystemVersionAndLabel() async {
    final json = await _apiClient.get('/api/Organization/GetSystemVersionAndOrgLabel');
    final data = _extractData(json);
    return OrgInfo.fromJson(data);
  }

  Future<List<AppDomain>> fetchDomains() async {
    final json = await _apiClient.get('/api/Login/GetAllDomains');
    final data = _extractData(json);
    final domains = data['domains'] ?? data['Domains'] ?? data;
    if (domains is List) {
      return domains
          .map((e) => AppDomain.fromDynamic(e))
          .where((e) => e.url.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> root) {
    final data = root['data'] ?? root['result'] ?? root['Data'] ?? root['Result'] ?? root;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }
}
