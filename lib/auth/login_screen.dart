import 'package:cargo_setu/auth/sign_up_screen.dart';
import 'package:cargo_setu/theme/app_theme.dart';
import 'package:cargo_setu/util/coustom_text.dart';
import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    Get.put(LoginController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: height * 0.8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFEFF6FF),
                ],
              ),
            ),
          ),

          /// CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.98,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),

                      /// LOGO
                      Image.asset(
                        height: 150,width: 150,
                        'assets/logo/transparent_logo.png',
                        fit: BoxFit.contain,
                      ),

                      const Text(
                        "Smart Logistics, Seamless Delivery",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const LoginTabsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================================
/// ========================== LOGIN TABS =================================
/// =======================================================================

class LoginTabsCard extends StatelessWidget {
  const LoginTabsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// TAB BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            padding: const EdgeInsets.all(4),
            child: const TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.blue,
              tabs: [
                Tab(text: "Mobile"),
                Tab(text: "Email"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 380,
            child: TabBarView(
              children: [
                _MobileOtpTab(),
                _EmailLoginTab(),
              ],
            ),
          ),

          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: "Don’t have an account? ",
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "Create one",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================================
/// ======================= MOBILE OTP TAB ================================
/// =======================================================================

class _MobileOtpTab extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: CustomText(
              title: "Mobile Number *",
              colors: AppTheme.colorBlack,
              fontSize: AppTheme.small,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// MOBILE FIELD WITH COUNTRY PICKER
        CoustomTextField(
          labelText: "  98765 43210",
          keyboardType: TextInputType.phone,
          maxLength: 10,
          textEditingController: controller.mobileNumberController,
          onChanged: (_) {},
          prefixIcon: InkWell(
            onTap: () => controller.showCountryCodeDialog(context),
            child: Container(
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade300, // 👈 divider color
                    width: 2,                    // 👈 divider thickness
                  ),
                ),
              ),
              child: Obx(
                    () => Text(
                  controller.countryCode.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          onTextValidator: (v) {
            if (v == null || v.isEmpty) return "Mobile number required";
            if (v.length < 8) return "Invalid mobile number";
            return null;
          },
        ),

        const SizedBox(height: 20),

        /// SEND OTP BUTTON (NOT LOGIN)
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // TODO: controller.sendOtp();
              debugPrint(
                "SEND OTP => ${controller.fullMobileNumber}",
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "SEND OTP",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


/// =======================================================================
/// ========================= EMAIL TAB ===================================
/// =======================================================================

class _EmailLoginTab extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// EMAIL LABEL
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: CustomText(
                title: "Email Address *",
                colors: AppTheme.colorBlack,
                fontSize: AppTheme.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          CoustomTextField(
            labelText: "example@email.com",
            keyboardType: TextInputType.emailAddress,
            textEditingController: controller.userNameController,
            onChanged: (_) {},
            onTextValidator: (v) =>
            v == null || !v.contains('@') ? "Invalid email" : null,
          ),

          const SizedBox(height: 16),

          /// PASSWORD LABEL
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: CustomText(
                title: "Password *",
                colors: AppTheme.colorBlack,
                fontSize: AppTheme.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          CoustomTextField(
            labelText: "Enter password",
            obscureText: true,
            textEditingController: controller.passwordController,
            onChanged: (_) {},
            onTextValidator: (v) =>
            v == null || v.isEmpty ? "Password required" : null,
          ),

          const SizedBox(height: 20),

          const _LoginButton(title: "LOGIN"),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("OR"),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text("Sign in with Google"),
          ),

          const SizedBox(height: 20), // 👈 important
        ],
      ),
    );
  }
}


/// =======================================================================
/// ========================= LOGIN BUTTON ================================
/// =======================================================================

class _LoginButton extends StatelessWidget {
  final String title;
  const _LoginButton({required this.title});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return SizedBox(
      height: 48,
      child: Obx(
            () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
            controller.login();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
