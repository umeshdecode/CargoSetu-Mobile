import 'dart:io';

import 'package:dio/dio.dart';

class ApiRequest {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },

    ),
  );

  Future<Response> post({
    required String url,
    dynamic data,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: token != null
              ? {"Authorization": "Bearer $token"}
              : null,
        ),
      );
      return response;
    } on DioException catch (e) {
      throw e;

    }
  }

  // Exception _handleError(DioException e) {
  //   // Timeout cases
  //   if (e.type == DioExceptionType.connectionTimeout ||
  //       e.type == DioExceptionType.sendTimeout ||
  //       e.type == DioExceptionType.receiveTimeout) {
  //     return Exception("Request timeout. Please try again.");
  //   }
  //
  //   // Network / socket issues
  //   if (e.error is SocketException) {
  //     return Exception(
  //         "Unable to reach server. Please check your network.");
  //   }
  //
  //   // Server responded with error
  //   if (e.response != null) {
  //     return Exception(
  //       e.response?.data?['message'] ??
  //           "Server error (${e.response?.statusCode})",
  //     );
  //   }
  //
  //   // Unknown
  //   return Exception("Something went wrong");
  // }

}
