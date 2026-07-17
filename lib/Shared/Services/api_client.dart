import 'package:dio/dio.dart';
import 'package:midas/Shared/Services/app_logger.dart';

typedef UnauthorizedCallback = Future<void> Function();

class ApiClient {
  ApiClient({required String baseUrl}) : _dio = _createDio(baseUrl) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.apiRequest(
            method: options.method,
            url: options.uri.toString(),
            queryParameters: options.queryParameters.isEmpty
                ? null
                : Map<String, dynamic>.from(options.queryParameters),
            body: options.data,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.apiResponse(
            method: response.requestOptions.method,
            url: response.requestOptions.uri.toString(),
            statusCode: response.statusCode,
            response: response.data,
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.apiResponse(
            method: error.requestOptions.method,
            url: error.requestOptions.uri.toString(),
            statusCode: error.response?.statusCode,
            response: error.response?.data,
            errorMessage: error.message,
          );
          await _handleUnauthorized(error);
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  UnauthorizedCallback? _onUnauthorized;

  Dio get dio => _dio;

  static Dio _createDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }

  void setUnauthorizedHandler(UnauthorizedCallback handler) {
    _onUnauthorized = handler;
  }

  Future<void> _handleUnauthorized(DioException error) async {
    if (error.response?.statusCode != 401) return;

    final path = error.requestOptions.path.toLowerCase();
    if (path.contains('/api/login/loginauthentication')) return;

    final hasAuthHeader =
        error.requestOptions.headers.containsKey('Authorization');
    if (!hasAuthHeader) return;

    await _onUnauthorized?.call();
  }

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _dio.get(path);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> getWithQuery(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.post(
      path,
      data: body,
      queryParameters: queryParameters,
    );
    return _toMap(response.data);
  }

  /// Posts a raw JSON body (e.g. a JSON array).
  Future<Map<String, dynamic>> postRaw(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return _toMap(response.data);
  }

  /// Sends a PUT request with a raw JSON body (e.g. a JSON array).
  Future<Map<String, dynamic>> putRaw(
    String path, {
    required dynamic data,
  }) async {
    final response = await _dio.put(path, data: data);
    return _toMap(response.data);
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'data': data};
    return {'data': data};
  }
}
