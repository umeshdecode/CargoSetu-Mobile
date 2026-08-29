import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/cupertino.dart';

class StepAccount extends StatefulWidget {
  final Map data;
  final VoidCallback onChanged;

  const StepAccount(this.data, {super.key, required this.onChanged});

  @override
  State<StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends State<StepAccount> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
      text: widget.data['firstName'] ?? "",
    );
    lastNameController = TextEditingController(
      text: widget.data['lastName'] ?? "",
    );
    emailController = TextEditingController(text: widget.data['email'] ?? "");
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CoustomTextField(
            labelText: "First Name",
            isRequired: true,
            textEditingController: firstNameController, // ✅ FIX
            onChanged: (v) {
              widget.data['firstName'] = v;
              widget.onChanged();
            },
            onTextValidator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),

          const SizedBox(height: 16),

          CoustomTextField(
            labelText: "Last Name",
            isRequired: true,
            textEditingController: lastNameController, // ✅ FIX
            onChanged: (v) {
              widget.data['lastName'] = v;
              widget.onChanged();
            },
            onTextValidator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),

          const SizedBox(height: 16),

          CoustomTextField(
            labelText: "Email",
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            textEditingController: emailController, // ✅ FIX
            onChanged: (v) {
              widget.data['email'] = v;
              widget.onChanged();
            },
            onTextValidator: (v) {
              if (v == null || v.isEmpty) return "Required";
              if (!v.contains('@')) return "Invalid email";
              return null;
            },
          ),
        ],
      ),
    );
  }
}
