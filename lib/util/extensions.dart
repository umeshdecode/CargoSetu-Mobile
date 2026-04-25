// lib/util/extensions.dart

// ✅ KEEP YOUR SINGLE LINE — but make it safe
extension Extension on Object? {
  bool isNullOrEmpty() => this == null || this == '';
}

// ✅ KEEP LOGIC — make it nullable-safe
extension IsNullOrEmpty on List? {
  bool get isListNullOrEmpty {
    return this == null || this!.isEmpty;
  }
}

// ✅ STRING EXTENSIONS (unchanged behavior)
extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      toLowerCase().contains(secondString.toLowerCase());

  bool equalsIgnoreCase(String string2) {
    return toLowerCase() == string2.toLowerCase();
  }

  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
      r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|'
      r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  bool isValidPanNo() {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$')
        .hasMatch(this);
  }

  bool get onDigitValidate {
    return length >= 8 && length <= 12;
  }
}