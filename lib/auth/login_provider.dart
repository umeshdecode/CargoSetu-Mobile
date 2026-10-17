import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';
import '../network/api_request.dart';
import 'model/login_request.dart';

class LoginProvider {
  final ApiRequest _api = ApiRequest();

  Future<Response> login(LoginRequest request) {
    return _api.post(
      url: Urls.login,
      data: request.toJson(),
      responseType: ResponseType.plain,
    );
  }

  Future<Response> sendOtp(String mobileNumber) {
    return _api.post(url: Urls.sendOtp, data: {"mobileNumber": mobileNumber});
  }

  Future<Response> verifyOtp(String mobileNumber, String otpCode) {
    return _api.post(
      url: Urls.verifyOtp,
      data: {"mobileNumber": mobileNumber, "otpCode": otpCode},
      responseType: ResponseType.plain,
    );
  }
}
