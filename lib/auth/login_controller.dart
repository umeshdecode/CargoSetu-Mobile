import 'dart:convert';
import 'dart:developer';

import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:cargo_setu/network/api_request.dart';
import 'login_provider.dart';
import 'model/login_request.dart';
import 'model/login_response.dart';

class LoginController extends GetxController {
  final LoginProvider _provider = LoginProvider();
  final GetStorage storage = GetStorage();

  /// EMAIL / PASSWORD
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isEmailLoginEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    userNameController.addListener(_validateEmailLogin);
    passwordController.addListener(_validateEmailLogin);
  }

  void _validateEmailLogin() {
    isEmailLoginEnabled.value = userNameController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  /// MOBILE / OTP
  final mobileNumberController = TextEditingController();
  final otpController = TextEditingController();

  /// COUNTRY CODE
  RxString countryCode = "+91".obs;

  /// UI STATES
  final isLoading = false.obs;
  final otpSent = false.obs;
  final isCLicked = false.obs;

  ////////////////////////
  /// COUNTRY PICKER
  ////////////////////////
  void showCountryCodeDialog(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        countryCode.value = "+${country.phoneCode}";
        update(); // needed if GetBuilder is used
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        inputDecoration: InputDecoration(
          hintText: "Search country",
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
          ),
        ),
      ),
    );
  }

  ////////////////////////
  /// LOGIN (EMAIL)
  ////////////////////////
  Future<void> login() async {
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Username & Password required");
      return;
    }

    isLoading.value = true;

    final request = LoginRequest(
      email: userNameController.text.trim(),
      password: passwordController.text.trim(),
    );

    try {
      debugPrint("LOGIN REQUEST => ${jsonEncode(request.toJson())}");

      final response = await _provider.login(request);
      final loginRes = LoginResponse.fromJson(response.data);

      /// SAVE FULL SESSION (token + roles + permissions)
      await _saveSessionAndCheckCompany(loginRes);
    } on DioException catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: "Login Failed, Try after Some time");
      Get.snackbar("Login Failed", msg);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////
  /// OTP (MOBILE)
  ////////////////////////
  Future<void> sendOtp() async {
    if (mobileNumberController.text.isEmpty) {
      Get.snackbar("Error", "Mobile number required");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _provider.sendOtp(fullMobileNumber);
      if (response.statusCode == 200) {
        otpSent.value = true;
        // The backend might return mockOtp in response for testing
        final mockOtp = response.data['mockOtp'];
        if (mockOtp != null) {
          Get.snackbar("OTP Sent", "Your mock OTP is: $mockOtp");
        } else {
          Get.snackbar("Success", "OTP sent successfully");
        }
      }
    } on DioException catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: "Failed to send OTP");
      Get.snackbar("Error", msg);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      Get.snackbar("Error", "Invalid OTP");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _provider.verifyOtp(
        fullMobileNumber,
        otpController.text,
      );
      final loginRes = LoginResponse.fromJson(response.data);

      /// SAVE FULL SESSION (token + roles + permissions)
      await _saveSessionAndCheckCompany(loginRes);
    } on DioException catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: "Invalid or expired OTP");
      Get.snackbar("Error", msg);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////
  /// SESSION + COMPANY CHECK
  ////////////////////////

  /// Save session data and check company status, then navigate.
  Future<void> _saveSessionAndCheckCompany(LoginResponse loginRes) async {
    // Save full session via SessionService
    final session = Get.find<SessionService>();
    session.saveSession(loginRes.toJson());

    // Initialize CompanyController and check company status
    final companyCtrl = Get.put(CompanyController());
    await companyCtrl.fetchCurrentCompany();

    log('✅ Login complete. hasCompany=${companyCtrl.hasCompany.value}');

    // Navigate to dashboard (it will handle company check gate)
    Get.offAllNamed(AppRoutes.dashboard);
  }

  ////////////////////////
  /// HELPERS
  ////////////////////////
  String get fullMobileNumber =>
      "${countryCode.value}${mobileNumberController.text.trim()}";

  ////////////////////////
  /// CLEANUP
  ////////////////////////
  @override
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    mobileNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
