import 'package:cargo_setu/theme/app_theme.dart';
import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class StepContact extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onChanged;

  const StepContact(
      this.data, {
        super.key,
        required this.onChanged,
      });

  @override
  State<StepContact> createState() => _StepContactState();
}

class _StepContactState extends State<StepContact> {
  late final TextEditingController mobileController;

  /// DEFAULT COUNTRY CODE
  String countryCode = "+91";

  @override
  void initState() {
    super.initState();

    /// Restore mobile if user comes back
    final storedMobile = widget.data['mobile'] ?? "";

    if (storedMobile.startsWith("+")) {
      final match = RegExp(r'^(\+\d{1,3})(\d+)$').firstMatch(storedMobile);
      if (match != null) {
        countryCode = match.group(1)!;
        mobileController = TextEditingController(text: match.group(2));
      } else {
        mobileController = TextEditingController();
      }
    } else {
      mobileController = TextEditingController(text: storedMobile);
    }
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() {
          countryCode = "+${country.phoneCode}";
        });
        _updateMobile();
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        inputDecoration: InputDecoration(
          hintText: "Search country",
          prefixIcon: Icon(Icons.search, color: AppTheme.colorIconGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _updateMobile() {
    widget.data['mobile'] = "$countryCode${mobileController.text}";
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          CoustomTextField(
            labelText: "Mobile Number",
            isRequired: true,
            keyboardType: TextInputType.phone,
            maxLength: 12,
            textEditingController: mobileController,

            /// COUNTRY CODE PREFIX
            prefixIcon: InkWell(
              onTap: _showCountryPicker,
              child: Container(
                width: 65,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.colorIconGrey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  countryCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            onChanged: (_) => _updateMobile(),

            onTextValidator: (v) {
              if (v == null || v.isEmpty) {
                return "Mobile number is required";
              }
              if (v.length < 8) {
                return "Enter valid mobile number";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
