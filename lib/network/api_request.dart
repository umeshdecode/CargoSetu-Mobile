import 'dart:developer';

import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

/// Central API client with auto-auth and token refresh.
///
/// All authenticated requests automatically attach the Bearer token
/// from GetStorage. On 401/403, it attempts a token refresh before
/// retrying the original request once.
class ApiRequest {
  static final ApiRequest _instance = ApiRequest._internal();
  factory ApiRequest() => _instance;

  late final Dio _dio;
  late final Dio _refreshDio;
  final GetStorage _storage = GetStorage();
  bool _isRefreshing = false;

  ApiRequest._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Dedicated clean Dio instance for token refresh to avoid interceptor recursion
    _refreshDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Attach Bearer token to all non-public requests.
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read(Constant.token);
    final isPublicEndpoint = _isPublicUrl(options.uri.toString());

    if (token != null && token.toString().isNotEmpty && !isPublicEndpoint) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  /// Handle 401/403 by refreshing token and retrying.
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if ((err.response?.statusCode == 401 || err.response?.statusCode == 403) &&
        !_isRefreshing &&
        !_isPublicUrl(err.requestOptions.uri.toString())) {
      _isRefreshing = true;

      try {
        final oldToken = _storage.read(Constant.token);
        if (oldToken == null || oldToken.toString().isEmpty) {
          handler.next(err);
          return;
        }

        // Attempt token refresh using isolated refresh client
        final refreshResponse = await _refreshDio.get(
          Urls.refreshToken,
          options: Options(
            headers: {'Authorization': 'Bearer $oldToken'},
          ),
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final data = refreshResponse.data;
          final newToken = data is Map ? data['accessToken'] : null;
          if (newToken != null && newToken.toString().isNotEmpty) {
            _storage.write(Constant.token, newToken.toString());
            log('🔄 Token refreshed successfully in ApiRequest');

            // Retry original request with new token
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await _dio.fetch(retryOptions);
            handler.resolve(retryResponse);
            return;
          }
        }
      } catch (e) {
        log('❌ Token refresh in interceptor failed: $e');
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Direct token refresh method callable from services / controllers
  Future<Map<String, dynamic>?> refreshToken() async {
    try {
      final oldToken = _storage.read(Constant.token);
      if (oldToken == null || oldToken.toString().isEmpty) return null;

      final response = await _refreshDio.get(
        Urls.refreshToken,
        options: Options(
          headers: {'Authorization': 'Bearer $oldToken'},
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['accessToken'];
        if (newToken != null) {
          _storage.write(Constant.token, newToken.toString());
        }
        return data;
      }
      return null;
    } catch (e) {
      log('❌ Direct refreshToken error: $e');
      return null;
    }
  }

  /// Check if URL is a public (non-auth) endpoint.
  bool _isPublicUrl(String url) {
    const publicPaths = [
      '/auth/login',
      '/auth/user/register',
      '/auth/otp/send',
      '/auth/otp/verify',
      '/auth/google/login',
      '/auth/google/signup',
      '/auth/check-user',
      '/refreshtoken',
    ];
    return publicPaths.any((path) => url.contains(path));
  }

  // ─── HTTP METHODS ─────────────────────────────────────────

  /// POST request with JSON body.
  Future<Response> post({
    required String url,
    dynamic data,
    String? token,
  }) async {
    return _dio.post(
      url,
      data: data,
      options: _tokenOverride(token),
    );
  }

  /// GET request.
  Future<Response> get({
    required String url,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    return _dio.get(
      url,
      queryParameters: queryParams,
      options: _tokenOverride(token),
    );
  }

  /// PUT request with JSON body.
  Future<Response> put({
    required String url,
    dynamic data,
    String? token,
  }) async {
    return _dio.put(
      url,
      data: data,
      options: _tokenOverride(token),
    );
  }

  /// DELETE request.
  Future<Response> delete({
    required String url,
    String? token,
  }) async {
    return _dio.delete(
      url,
      options: _tokenOverride(token),
    );
  }

  /// POST request with multipart/form-data (for file uploads).
  Future<Response> postMultipart({
    required String url,
    required FormData data,
    String? token,
  }) async {
    return _dio.post(
      url,
      data: data,
      options: _tokenOverride(token, contentType: 'multipart/form-data'),
    );
  }

  /// PUT request with multipart/form-data (for file uploads).
  Future<Response> putMultipart({
    required String url,
    required FormData data,
    String? token,
  }) async {
    return _dio.put(
      url,
      data: data,
      options: _tokenOverride(token, contentType: 'multipart/form-data'),
    );
  }

  /// Override token if explicitly provided (for special cases).
  Options? _tokenOverride(String? token, {String? contentType}) {
    if (token == null && contentType == null) return null;
    return Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      contentType: contentType,
    );
  }
}
