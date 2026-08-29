import 'package:cargo_setu/auth/model/sign_up_req.dart' show SignUpRequest;
import 'package:dio/dio.dart';
import 'package:cargo_setu/util/url_const.dart';
import '../../network/api_request.dart';

class SignUpProvider {
  final ApiRequest _api = ApiRequest();

  Future<Response> register(SignUpRequest request) {
    return _api.post(url: Urls.register, data: request.toJson());
  }
}
