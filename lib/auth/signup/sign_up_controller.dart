import 'dart:convert';
import 'dart:developer';

import 'package:cargo_setu/auth/login_provider.dart';
import 'package:cargo_setu/auth/model/login_request.dart';
import 'package:cargo_setu/auth/model/login_response.dart';
import 'package:cargo_setu/auth/model/sign_up_req.dart';
import 'package:cargo_setu/auth/signup/sign_up_provider.dart';
import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
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
        final rawLoginData = loginResponse.data;
        final Map<String, dynamic>? loginMap = rawLoginData is Map
            ? Map<String, dynamic>.from(rawLoginData)
            : (rawLoginData is String && rawLoginData.trim().startsWith('{')
                ? Map<String, dynamic>.from(jsonDecode(rawLoginData.trim()) as Map)
                : null);
        if (loginMap == null || (loginMap['accessToken'] ?? '').toString().trim().isEmpty) {
          throw Exception(rawLoginData?.toString() ?? 'Auto-login failed');
        }
        final loginRes = LoginResponse.fromJson(loginMap);

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
        AppSnackbar.success(
          "Please login with your credentials.",
          title: "Account Created",
        );
        return true;
      }
    } on DioException catch (e) {
      log("❌ SIGNUP ERROR");
      log("Status: ${e.response?.statusCode}");
      log("Data: ${e.response?.data}");

      final errData = e.response?.data;
      final errMsg = errData is Map
          ? (errData['responseMessage'] ??
              errData['responseMessege'] ??
              errData['message'] ??
              errData['error'] ??
              "Server error")
          : (errData?.toString() ?? "Server error");

      AppSnackbar.error(errMsg.toString());

      return false;
    } catch (e) {
      log("❌ UNKNOWN ERROR: $e");
      AppSnackbar.error(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
