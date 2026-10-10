import 'dart:developer';

import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:get_storage/get_storage.dart';

/// Central API client with auto-auth and token refresh.
///
/// All authenticated requests automatically attach the Bearer token
/// from GetStorage. On 401/403, it attempts a token refresh before
/// retrying the original request once. If refresh also fails (e.g.
/// token expired after days of inactivity), forces logout to login screen.
class ApiRequest {
  static final ApiRequest _instance = ApiRequest._internal();
  factory ApiRequest() => _instance;

  late final Dio _dio;
  late final Dio _refreshDio;
  final GetStorage _storage = GetStorage();
  bool _isRefreshing = false;

  /// User-friendly error message formatter specifically for document and PDF generation/download operations.
  /// Prevents any internal technical details or stacktraces from being shown to users.
  static String formatDocumentErrorMessage(dynamic error, {String docTitle = 'Document'}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return '$docTitle is taking longer than usual to generate. Document not generated yet, please try again after some time.';
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          return 'Unable to reach server. Please check your internet connection and try again.';
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map) {
            final msg = data['responseMessege'] ?? data['message'] ?? data['error'];
            if (msg != null && msg.toString().trim().isNotEmpty) {
              return msg.toString();
            }
          }
          final status = error.response?.statusCode;
          return status != null
              ? '$docTitle could not be generated. Please try again after some time.'
              : '$docTitle could not be generated. Please try again after some time.';
        case DioExceptionType.cancel:
          return '$docTitle request was cancelled.';
        default:
          return '$docTitle could not be generated. Please try again after some time.';
      }
    }
    return '$docTitle not generated. Please try again after some time.';
  }

  /// User-friendly error message formatter that prevents raw stacktraces from being shown to users.
  static String formatErrorMessage(dynamic error, {String defaultMessage = 'Something went wrong, please try again later.'}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.sendTimeout:
          return 'Request timed out while sending data. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Server took longer than expected to respond. Please try again after some time.';
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map) {
            final msg = data['responseMessege'] ?? data['message'] ?? data['error'];
            if (msg != null && msg.toString().trim().isNotEmpty) {
              return msg.toString();
            }
          }
          final status = error.response?.statusCode;
          return status != null ? 'Server error ($status). Please try again.' : 'Invalid response from server.';
        case DioExceptionType.connectionError:
          return 'Unable to reach the server. Please check your network connection.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          final msg = error.message;
          if (msg != null &&
              msg.isNotEmpty &&
              !msg.contains('DioException') &&
              !msg.contains('RequestOptions') &&
              !msg.contains('Exception') &&
              !msg.contains('timed out')) {
            return msg;
          }
          return defaultMessage;
      }
    }
    if (error is String && error.isNotEmpty && !error.contains('Exception')) {
      return error;
    }
    return defaultMessage;
  }

  ApiRequest._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Dedicated clean Dio instance for token refresh to avoid interceptor recursion
    _refreshDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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
  /// If refresh also fails with 401/403/connection error → force logout.
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
          _forceLogout();
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

        // Refresh returned non-200 or no valid token → force logout
        log('❌ Token refresh returned invalid data, forcing logout');
        _forceLogout();
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        log('❌ Token refresh failed with status $statusCode: $e');

        // If refresh itself returns 401/403, the session is truly expired
        if (statusCode == 401 || statusCode == 403) {
          _forceLogout();
        }
      } catch (e) {
        log('❌ Token refresh in interceptor failed: $e');
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Direct token refresh method callable from services / controllers.
  /// Returns the new token response map, or null if refresh failed.
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
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      log('❌ Direct refreshToken error (status=$statusCode): $e');
      if (statusCode == 401 || statusCode == 403) {
        _forceLogout();
      }
      return null;
    } catch (e) {
      log('❌ Direct refreshToken error: $e');
      return null;
    }
  }

  /// Force logout: clear all session data and redirect to login screen.
  /// Shows a snackbar so the user knows why they were logged out.
  void _forceLogout() {
    log('🔒 Session expired — forcing logout');

    // Clear all stored data
    _storage.remove(Constant.token);
    _storage.remove(Constant.userSession);
    _storage.remove(Constant.staffInfo);
    _storage.remove(Constant.companyStatus);
    _storage.remove(Constant.companyData);
    _storage.remove(Constant.refreshTokenKey);
    _storage.remove(Constant.userRoles);
    _storage.remove(Constant.userPermissions);
    _storage.remove(Constant.staffId);
    _storage.remove(Constant.userName);
    _storage.remove(Constant.userEmail);

    if (Get.isRegistered<SessionService>()) {
      Get.find<SessionService>().isLoggedIn.value = false;
    }

    // Navigate to login and show message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please login again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.lock_outline, color: Colors.white),
        );
      }
    });
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
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.post(
      url,
      data: data,
      queryParameters: queryParams,
      options: _buildOptions(
        token: token,
        headers: headers,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// GET request.
  Future<Response<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? token,
    ResponseType? responseType,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.get<T>(
      url,
      queryParameters: queryParams,
      options: _buildOptions(
        token: token,
        headers: headers,
        responseType: responseType,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// PUT request with JSON body.
  Future<Response> put({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.put(
      url,
      data: data,
      queryParameters: queryParams,
      options: _buildOptions(
        token: token,
        headers: headers,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// DELETE request.
  Future<Response> delete({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.delete(
      url,
      data: data,
      queryParameters: queryParams,
      options: _buildOptions(
        token: token,
        headers: headers,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// POST request with multipart/form-data (for file uploads).
  Future<Response> postMultipart({
    required String url,
    required FormData data,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.post(
      url,
      data: data,
      options: _buildOptions(
        token: token,
        contentType: 'multipart/form-data',
        headers: headers,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// PUT request with multipart/form-data (for file uploads).
  Future<Response> putMultipart({
    required String url,
    required FormData data,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    return _dio.put(
      url,
      data: data,
      options: _buildOptions(
        token: token,
        contentType: 'multipart/form-data',
        headers: headers,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );
  }

  /// Build Options merging token, custom headers, content type, and response type.
  Options? _buildOptions({
    String? token,
    String? contentType,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    final mergedHeaders = <String, dynamic>{
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    if (mergedHeaders.isEmpty &&
        contentType == null &&
        responseType == null &&
        receiveTimeout == null &&
        sendTimeout == null) {
      return null;
    }

    return Options(
      headers: mergedHeaders.isNotEmpty ? mergedHeaders : null,
      contentType: contentType,
      responseType: responseType,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }
}
