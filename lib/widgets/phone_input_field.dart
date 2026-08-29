import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../util/constant.dart';

/// Reusable phone input field with country code picker.
/// Used in company form, signup, and any phone number fields.
class PhoneInputField extends StatefulWidget {
  final String label;
  final String initialCode;
  final String? initialNumber;
  final bool isRequired;
  final ValueChanged<String>? onCodeChanged;
  final ValueChanged<String>? onNumberChanged;
  final FormFieldValidator<String>? validator;

  const PhoneInputField({
    super.key,
    required this.label,
    this.initialCode = '+91',
    this.initialNumber,
    this.isRequired = false,
    this.onCodeChanged,
    this.onNumberChanged,
    this.validator,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late String _countryCode;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialCode;
    _numberController = TextEditingController(text: widget.initialNumber ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _countryCode = '+${country.phoneCode}';
        });
        widget.onCodeChanged?.call(_countryCode);
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: widget.isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        // Input Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Button
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius:
                      BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _countryCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: widget.onNumberChanged,
                validator: widget.validator,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Phone number',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
                    borderSide: const BorderSide(
                        color: AppColors.borderFocused, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Constant.BTN_ROUNDED_CORNER),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Get the full phone number (code + number)
  String get fullNumber => '$_countryCode${_numberController.text.trim()}';

  /// Get just the number part
  String get number => _numberController.text.trim();

  /// Get just the code part
  String get code => _countryCode;
}
