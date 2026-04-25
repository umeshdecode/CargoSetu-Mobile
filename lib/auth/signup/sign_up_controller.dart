import 'dart:convert';
import 'dart:developer';

import 'package:cargo_setu/auth/model/sign_up_req.dart';
import 'package:cargo_setu/auth/signup/sign_up_provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final SignUpProvider _provider = SignUpProvider();

  var isLoading = false.obs;

  Future<bool> register(Map<String, String> data) async {
    isLoading.value = true;

    try {
      final request = SignUpRequest(
        userName: data['userName'] ?? data['email']!,
        firstName: data['firstName']!,
        lastName: data['lastName']!,
        email: data['email']!,

        dob: DateTime.now().toUtc().toIso8601String(),

        /// 📱 MOBILE DETAILS (DYNAMIC)
        mobileNumber: data['mobile']!,
        mobileCode: data['mobileCode'] ?? "+91",

        /// 🏢 USER DETAILS
        staffType: "STAFF",
        departmentId: 1,
        isActive: true,

        /// 📍 ADDRESS
        city: data['city']!,
        state: data['state']!,
        pincode: data['pincode']!,
        country: data['country'] ?? "India",
        address: data['address'] ?? "Default Address",

        /// 🔐 SECURITY
        password: data['password']!,
      );

      log("SIGNUP REQUEST => ${jsonEncode(request.toJson())}");

      await _provider.register(request);

      return true;
    } on DioException catch (e) {
      log("❌ SIGNUP ERROR");
      log("Status: ${e.response?.statusCode}");
      log("Data: ${e.response?.data}");

      Get.snackbar(
        "Signup Failed",
        e.response?.data?['message'] ??
            e.response?.data.toString() ??
            "Server error",
      );

      return false;
    } catch (e) {
      log("❌ UNKNOWN ERROR: $e");
      Get.snackbar("Signup Failed", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
