import 'package:cargo_setu/auth/signup/sign_up_controller.dart';
import 'package:cargo_setu/auth/signup/step_account.dart';
import 'package:cargo_setu/auth/signup/step_address.dart';
import 'package:cargo_setu/auth/signup/step_contact.dart';
import 'package:cargo_setu/auth/signup/step_indicator.dart';
import 'package:cargo_setu/auth/signup/step_security.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/theme/app_theme.dart';
import 'package:cargo_setu/util/coustom_text.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController signUpController = Get.put(SignUpController());

  int step = 0;

  final Map<String, String> signupData = {
    "firstName": "",
    "lastName": "",
    "email": "",
    "mobile": "",
    "city": "",
    "state": "",
    "pincode": "",
    "password": "",
  };

  void _onFormChanged() {
    setState(() {});
  }

  void next() async {
    if (!isStepValid(step, signupData)) return;

    if (step < 3) {
      setState(() => step++);
    } else {
      final success = await signUpController.register(signupData);

      if (success && mounted) {
        final session = Get.find<SessionService>();
        if (session.isLoggedIn.value) {
          // Futuristic Success Dialog
          await AppDialog.showSuccess(
            context,
            title: "Account Created! 🎉",
            message:
                "Welcome to CargoSetu, ${signupData['firstName']}! Your account has been registered and logged in successfully. Let's create your company workspace.",
            positiveBtnText: "Continue to Setup",
            onPositive: () {
              Navigator.of(context).pop();
              Get.offAllNamed(AppRoutes.dashboard);
            },
          );
        } else {
          await AppDialog.showSuccess(
            context,
            title: "Account Created! 🎉",
            message:
                "Your account has been registered successfully. Please log in with your email and password.",
            positiveBtnText: "Go to Login",
            onPositive: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          );
        }
      }
    }
  }

  void back() {
    if (step > 0) {
      setState(() => step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final bool canProceed = isStepValid(step, signupData);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.colorBG,
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(
              height: height * 0.8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                        const SizedBox(height: 40),
                        Center(
                          child: Image.asset(
                            'assets/logo/transparent_logo.png',
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "Create your account",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        StepIndicator(currentStep: step),
                        const SizedBox(height: 16),

                        // Dynamic height for steps
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: step == 0
                              ? StepAccount(
                                  signupData,
                                  onChanged: _onFormChanged,
                                )
                              : step == 1
                              ? StepContact(
                                  signupData,
                                  onChanged: _onFormChanged,
                                )
                              : step == 2
                              ? StepAddress(
                                  signupData,
                                  onChanged: _onFormChanged,
                                )
                              : StepSecurity(
                                  signupData,
                                  onChanged: _onFormChanged,
                                ),
                        ),

                        const SizedBox(height: 16),
                        Obx(() => Row(
                          children: [
                            if (step > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: signUpController.isLoading.value
                                      ? null
                                      : back,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: CustomText(
                                    title: "Back",
                                    colors: Colors.blue,
                                  ),
                                ),
                              ),
                            if (step > 0) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (canProceed &&
                                        !signUpController.isLoading.value)
                                    ? next
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: signUpController.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : CustomText(
                                        title: step == 3
                                            ? "Create Account"
                                            : "Next",
                                        colors: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        )),

                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ STEP VALIDATION
  bool isStepValid(int step, Map<String, String> data) {
    switch (step) {
      case 0: // Account
        return data['firstName']!.isNotEmpty &&
            data['lastName']!.isNotEmpty &&
            data['email']!.contains('@');

      case 1: // Contact
        return data['mobile']!.length >= 8;

      case 2: // Address
        return data['city']!.isNotEmpty &&
            data['state']!.isNotEmpty &&
            data['pincode']!.length == 6;

      case 3: // Security
        return data['password']!.length >= 6;

      default:
        return false;
    }
  }
}
