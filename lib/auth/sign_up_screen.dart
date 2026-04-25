import 'package:cargo_setu/auth/signup/auth_service.dart';
import 'package:cargo_setu/auth/signup/sign_up_controller.dart';
import 'package:cargo_setu/auth/signup/step_account.dart';
import 'package:cargo_setu/auth/signup/step_address.dart';
import 'package:cargo_setu/auth/signup/step_contact.dart';
import 'package:cargo_setu/auth/signup/step_indicator.dart';
import 'package:cargo_setu/auth/signup/step_security.dart';
import 'package:cargo_setu/theme/app_theme.dart';
import 'package:cargo_setu/util/coustom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../util/alert_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController signUpController = Get.put(SignUpController());

  int step = 0;
  final PageController controller = PageController();

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
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final success = await signUpController.register(signupData);

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialogHelper(
            title: "Congratulations 🎉",
            message: "Your account has been created successfully.",
            positiveBtnText: "Login",
            positiveBtnClick: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        );
      }
    }
  }



  void back() {
    if (step > 0) {
      setState(() => step--);
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = isStepValid(step, signupData);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 1100,
            height: 750,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Row(
              children: [
                /// LEFT PANEL
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Image.asset('assets/logo/logo.png', height: 120)),
                        const SizedBox(height: 20),
        
                        Center(
                          child: const Text(
                            "Create your account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
        
                        const SizedBox(height: 40),
        
                        StepIndicator(currentStep: step),
        
                        const SizedBox(height: 30),
        
                        Expanded(
                          child: PageView(
                            controller: controller,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              StepAccount(
                                signupData,
                                onChanged: _onFormChanged,
                              ),
                              StepContact(
                                signupData,
                                onChanged: _onFormChanged,
                              ),
                              StepAddress(
                                signupData,
                                onChanged: _onFormChanged,
                              ),
                              StepSecurity(
                                signupData,
                                onChanged: _onFormChanged,
                              ),
                            ],
                          ),
                        ),
        
                        Row(
                          children: [
                            if (step > 0)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: back,
                                  child:  CustomText(title: "Back",colors: AppTheme.colorBlack,),
                                ),
                              ),
        
                            if (step > 0) const SizedBox(width: 12),
        
                            Expanded(
                              child: ElevatedButton(
                                onPressed: canProceed ? next : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xff2563eb),
                                  disabledBackgroundColor:
                                  Colors.grey.shade400,
                                ),
                                child: CustomText(
                                title: step == 3
                                      ? "Create Account"
                                      : "Next",colors: AppTheme.colorBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ STEP VALIDATION (unchanged, correct)
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
