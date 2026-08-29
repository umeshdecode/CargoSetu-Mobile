import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/material.dart';

class StepSecurity extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onChanged;

  const StepSecurity(this.data, {super.key, required this.onChanged});

  @override
  State<StepSecurity> createState() => _StepSecurityState();
}

class _StepSecurityState extends State<StepSecurity> {
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  String password = "";
  String confirmPassword = "";

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController(
      text: widget.data['password'] ?? "",
    );
    confirmPasswordController = TextEditingController(
      text: widget.data['password'] ?? "",
    );

    password = passwordController.text;
    confirmPassword = confirmPasswordController.text;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  double get strengthValue {
    if (password.isEmpty) return 0;
    if (password.length >= 10) return 1;
    return password.length / 10;
  }

  Color get strengthColor {
    if (password.length > 8) return Colors.green;
    if (password.length > 4) return Colors.orange;
    return Colors.red;
  }

  bool get isMatch => confirmPassword.isNotEmpty && password == confirmPassword;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 PASSWORD
          CoustomTextField(
            labelText: "Password",
            isRequired: true,
            obscureText: true,
            maxLength: 128,
            textEditingController: passwordController, // ✅ FIX
            onChanged: (v) {
              setState(() {
                password = v;
              });
              widget.data['password'] = v;
              widget.onChanged();
            },
            onTextValidator: (v) {
              if (v == null || v.isEmpty) {
                return "Password is required";
              }
              if (v.length < 6) {
                return "Minimum 6 characters";
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          /// 🔹 PASSWORD STRENGTH BAR
          LinearProgressIndicator(
            value: strengthValue,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: strengthColor,
          ),

          const SizedBox(height: 16),

          /// 🔹 CONFIRM PASSWORD
          CoustomTextField(
            labelText: "Confirm Password",
            isRequired: true,
            obscureText: true,
            maxLength: 128,
            textEditingController: confirmPasswordController, // ✅ FIX
            onChanged: (v) {
              setState(() {
                confirmPassword = v;
              });
              widget.onChanged();
            },
            onTextValidator: (v) {
              if (v == null || v.isEmpty) {
                return "Confirm password is required";
              }
              if (v != password) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          /// 🔹 MATCH INDICATOR
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: confirmPassword.isEmpty
                  ? Colors.grey.shade300
                  : isMatch
                  ? Colors.green
                  : Colors.red,
            ),
          ),

          const SizedBox(height: 6),

          /// 🔹 MATCH TEXT
          if (confirmPassword.isNotEmpty)
            Text(
              isMatch ? "Passwords match" : "Passwords do not match",
              style: TextStyle(
                color: isMatch ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
