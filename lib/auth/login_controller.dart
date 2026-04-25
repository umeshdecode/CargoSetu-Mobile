import 'dart:convert';

import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'login_provider.dart';
import 'model/login_request.dart';
import 'model/login_response.dart';

class LoginController extends GetxController {
  final LoginProvider _provider = LoginProvider();
  final GetStorage storage = GetStorage();

  /// EMAIL / PASSWORD
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

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
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              Constant.BTN_ROUNDED_CORNER,
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////
  /// LOGIN (EMAIL)
  ////////////////////////
  Future<void> login() async {
    if (userNameController.text.isEmpty ||
        passwordController.text.isEmpty) {
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

      /// SAVE TOKEN
      storage.write(Constant.token, loginRes.accessToken);

      /// NAVIGATE
      Get.offAllNamed(AppRoutes.dashboard);
    } on DioException catch (e) {
      Get.snackbar(
        "Login Failed",
        e.response?.data?['message'] ??
            e.response?.data.toString() ??
            "Server error",
      );
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
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
