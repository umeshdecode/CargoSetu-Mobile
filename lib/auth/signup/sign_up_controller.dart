import 'dart:convert';
import 'dart:developer';

import 'package:cargo_setu/auth/login_provider.dart';
import 'package:cargo_setu/auth/model/login_request.dart';
import 'package:cargo_setu/auth/model/login_response.dart';
import 'package:cargo_setu/auth/model/sign_up_req.dart';
import 'package:cargo_setu/auth/signup/sign_up_provider.dart';
import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Handles user registration with automatic login after success.
///
/// Flow: Register → Auto-Login → Check Company → Navigate to Dashboard
class SignUpController extends GetxController {
  final SignUpProvider _signUpProvider = SignUpProvider();
  final LoginProvider _loginProvider = LoginProvider();

  var isLoading = false.obs;

  /// Register the user, then auto-login with same credentials.
  ///
  /// Returns `true` if both registration AND auto-login succeed.
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

      // Step 1: Register
      await _signUpProvider.register(request);
      log("✅ Registration successful");

      // Step 2: Auto-login with same credentials
      try {
        final loginRequest = LoginRequest(
          email: data['email']!,
          password: data['password']!,
        );

        log("AUTO-LOGIN REQUEST => ${jsonEncode(loginRequest.toJson())}");

        final loginResponse = await _loginProvider.login(loginRequest);
        final loginRes = LoginResponse.fromJson(loginResponse.data);

        // Save session
        final session = Get.find<SessionService>();
        session.saveSession(loginRes.toJson());

        // Check company status
        final companyCtrl = Get.put(CompanyController());
        await companyCtrl.fetchCurrentCompany();

        log("✅ Auto-login successful. hasCompany=${companyCtrl.hasCompany.value}");
        return true;
      } catch (loginError) {
        // Registration succeeded but auto-login failed.
        // Still return true — the signup screen will handle navigation.
        log("⚠️ Auto-login failed (registration was successful): $loginError");
        Get.snackbar(
          "Account Created",
          "Please login with your credentials.",
        );
        return true;
      }
    } on DioException catch (e) {
      log("❌ SIGNUP ERROR");
      log("Status: ${e.response?.statusCode}");
      log("Data: ${e.response?.data}");

      Get.snackbar(
        "Signup Failed",
        e.response?.data?['message'] ??
            e.response?.data?.toString() ??
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
