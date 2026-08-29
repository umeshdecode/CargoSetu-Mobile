import 'dart:convert';
import 'dart:io';

import 'package:cargo_setu/company/model/company_model.dart';
import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/section_header.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable, futuristic company form widget used by both create and edit screens.
///
/// Features:
/// - Direct logo upload & update via Gallery / Camera
/// - Integrated City, State, Country autocomplete API
/// - Strict field length validations matching database columns
/// - Number-only input constraints on phone fields
/// - Auto-uppercase formatting on PAN & GST
/// - "Same as WhatsApp" instant copy
class CompanyFormWidget extends StatefulWidget {
  final CompanyModel? company;
  final bool isSubmitting;
  final Future<void> Function(CompanyModel company, File? logoFile) onSubmit;

  const CompanyFormWidget({
    super.key,
    this.company,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<CompanyFormWidget> createState() => _CompanyFormWidgetState();
}

class _CompanyFormWidgetState extends State<CompanyFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // ─── Selected Logo File ─────────────────────────────────
  File? _logoFile;

  // ─── Location Autocomplete ──────────────────────────────
  List<LocationSuggestion> _locationSuggestions = [];
  bool _isSearchingLocation = false;

  // ─── Country Codes ──────────────────────────────────────
  String _whatsappCode = "+91";
  String _contact1Code = "+91";
  String _contact2Code = "+91";

  // ─── Controllers ────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _contact1Ctrl;
  late final TextEditingController _contact2Ctrl;
  late final TextEditingController _landlineCtrl;
  late final TextEditingController _tollFreeCtrl;
  late final TextEditingController _panCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _branchCtrl;
  late final TextEditingController _mainBranchCtrl;
  late final TextEditingController _websiteCtrl;

  bool _sameAsWhatsappContact1 = false;
  bool _sameAsWhatsappContact2 = false;

  bool get _isEditMode => widget.company != null;

  @override
  void initState() {
    super.initState();
    final c = widget.company;

    _nameCtrl = TextEditingController(text: c?.companyName ?? '');
    _emailCtrl = TextEditingController(text: c?.companyEmail ?? '');

    _whatsappCtrl = TextEditingController(
        text: _stripLeadingCode(c?.whatsappNumber));
    _contact1Ctrl =
        TextEditingController(text: _stripLeadingCode(c?.contactNo1));
    _contact2Ctrl =
        TextEditingController(text: _stripLeadingCode(c?.contactNo2));

    _landlineCtrl = TextEditingController(text: c?.landlineNo ?? '');
    _tollFreeCtrl = TextEditingController(text: c?.tollFreeNumber ?? '');
    _panCtrl = TextEditingController(text: c?.panNumber ?? '');
    _gstCtrl = TextEditingController(text: c?.gstNumber ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
    _stateCtrl = TextEditingController(text: c?.state ?? '');
    _countryCtrl = TextEditingController(text: c?.country ?? 'India');
    _branchCtrl = TextEditingController(text: c?.branch ?? '');
    _mainBranchCtrl = TextEditingController(text: c?.mainBranch ?? '');
    _websiteCtrl = TextEditingController(text: c?.website ?? '');
  }

  String _stripLeadingCode(String? fullNumber) {
    if (fullNumber == null || fullNumber.isEmpty) return '';
    if (fullNumber.startsWith('+91') && fullNumber.length > 3) {
      return fullNumber.substring(3);
    }
    if (fullNumber.startsWith('91') && fullNumber.length == 12) {
      return fullNumber.substring(2);
    }
    return fullNumber;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _contact1Ctrl.dispose();
    _contact2Ctrl.dispose();
    _landlineCtrl.dispose();
    _tollFreeCtrl.dispose();
    _panCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _branchCtrl.dispose();
    _mainBranchCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // ─── Pick Logo from Gallery / Camera ────────────────────
  Future<void> _pickLogo(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _logoFile = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showLogoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Company Logo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _logoPickerOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Take Photo',
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickLogo(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _logoPickerOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Choose Gallery',
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickLogo(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                if (_logoFile != null || widget.company?.logoUrlOrBase64 != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _logoFile = null;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 18),
                      label: const Text(
                        'Remove Logo',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _logoPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Country Code Picker Helper ─────────────────────────
  void _openCountryPicker(Function(String) onSelected) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          onSelected("+${country.phoneCode}");
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ─── Location Search (City, State, Country) ──────────────
  Future<void> _searchLocation(String query) async {
    if (query.trim().length < 2) {
      setState(() => _locationSuggestions.clear());
      return;
    }

    setState(() => _isSearchingLocation = true);

    try {
      final results = await LocationService.searchLocations(query);
      if (mounted) {
        setState(() {
          _locationSuggestions = results;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationSuggestions.clear());
    } finally {
      if (mounted) setState(() => _isSearchingLocation = false);
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final fullWhatsapp = _combineCodeAndNumber(_whatsappCode, _whatsappCtrl.text);
    final fullContact1 = _combineCodeAndNumber(_contact1Code, _contact1Ctrl.text);
    final fullContact2 = _combineCodeAndNumber(_contact2Code, _contact2Ctrl.text);

    final company = CompanyModel(
      companyId: widget.company?.companyId,
      companyUUID: widget.company?.companyUUID,
      companyName: _nameCtrl.text.trim(),
      companyEmail: _emailCtrl.text.trim(),
      whatsappNumber: fullWhatsapp.isNotEmpty ? fullWhatsapp : null,
      contactNo1: fullContact1.isNotEmpty ? fullContact1 : null,
      contactNo2: fullContact2.isNotEmpty ? fullContact2 : null,
      landlineNo: _landlineCtrl.text.trim().isNotEmpty
          ? _landlineCtrl.text.trim()
          : null,
      tollFreeNumber: _tollFreeCtrl.text.trim().isNotEmpty
          ? _tollFreeCtrl.text.trim()
          : null,
      panNumber: _panCtrl.text.trim().toUpperCase(),
      gstNumber: _gstCtrl.text.trim().toUpperCase(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim().isNotEmpty
          ? _countryCtrl.text.trim()
          : 'India',
      branch: _branchCtrl.text.trim().isNotEmpty
          ? _branchCtrl.text.trim()
          : null,
      mainBranch: _mainBranchCtrl.text.trim().isNotEmpty
          ? _mainBranchCtrl.text.trim()
          : null,
      website: _websiteCtrl.text.trim().isNotEmpty
          ? _websiteCtrl.text.trim()
          : null,
    );

    widget.onSubmit(company, _logoFile);
  }

  String _combineCodeAndNumber(String code, String number) {
    final cleanNum = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNum.isEmpty) return '';
    final cleanCode = code.replaceAll('+', '');
    return '$cleanCode$cleanNum';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── LOGO UPLOAD SECTION ──────────────────────────
          _buildLogoUploadCard(),
          const SizedBox(height: 20),

          // ─── SECTION 1: BASIC INFO ────────────────────────
          _buildCardContainer(
            icon: Icons.business,
            title: 'Basic Information',
            children: [
              _buildField(
                controller: _nameCtrl,
                label: 'Company Name',
                hint: 'e.g. Setu Logistics Pvt Ltd',
                icon: Icons.business_center_outlined,
                isRequired: true,
                maxLength: 150,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Company name is required';
                  }
                  if (v.trim().length < 3) {
                    return 'Must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailCtrl,
                label: 'Company Email',
                hint: 'official@company.com',
                icon: Icons.email_outlined,
                isRequired: true,
                maxLength: 150,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Company email is required';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── SECTION 2: CONTACT DETAILS ───────────────────
          _buildCardContainer(
            icon: Icons.phone_in_talk,
            title: 'Contact Details',
            children: [
              _buildPhoneField(
                controller: _whatsappCtrl,
                label: 'WhatsApp Number',
                hint: '9876543210',
                countryCode: _whatsappCode,
                isRequired: true,
                onCodeTap: () => _openCountryPicker((c) => _whatsappCode = c),
                onChanged: (val) {
                  if (_sameAsWhatsappContact1) {
                    _contact1Ctrl.text = val;
                    _contact1Code = _whatsappCode;
                  }
                  if (_sameAsWhatsappContact2) {
                    _contact2Ctrl.text = val;
                    _contact2Code = _whatsappCode;
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'WhatsApp number is required';
                  }
                  if (v.trim().length < 7 || v.trim().length > 15) {
                    return 'Enter 7-15 digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Same as WhatsApp Checkbox 1
              _buildSameAsCheckbox(
                label: 'Primary contact same as WhatsApp',
                value: _sameAsWhatsappContact1,
                onChanged: (val) {
                  setState(() {
                    _sameAsWhatsappContact1 = val ?? false;
                    if (_sameAsWhatsappContact1) {
                      _contact1Ctrl.text = _whatsappCtrl.text;
                      _contact1Code = _whatsappCode;
                    }
                  });
                },
              ),

              const SizedBox(height: 8),

              _buildPhoneField(
                controller: _contact1Ctrl,
                label: 'Primary Contact (Contact No. 1)',
                hint: '9876543210',
                countryCode: _contact1Code,
                isRequired: true,
                readOnly: _sameAsWhatsappContact1,
                onCodeTap: () => _openCountryPicker((c) => _contact1Code = c),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Primary contact number is required';
                  }
                  if (v.trim().length < 7 || v.trim().length > 15) {
                    return 'Enter 7-15 digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Same as WhatsApp Checkbox 2
              _buildSameAsCheckbox(
                label: 'Alternate contact same as WhatsApp',
                value: _sameAsWhatsappContact2,
                onChanged: (val) {
                  setState(() {
                    _sameAsWhatsappContact2 = val ?? false;
                    if (_sameAsWhatsappContact2) {
                      _contact2Ctrl.text = _whatsappCtrl.text;
                      _contact2Code = _whatsappCode;
                    }
                  });
                },
              ),

              const SizedBox(height: 8),

              _buildPhoneField(
                controller: _contact2Ctrl,
                label: 'Alternate Contact (Contact No. 2)',
                hint: 'Optional',
                countryCode: _contact2Code,
                readOnly: _sameAsWhatsappContact2,
                onCodeTap: () => _openCountryPicker((c) => _contact2Code = c),
              ),

              const SizedBox(height: 16),

              _buildField(
                controller: _landlineCtrl,
                label: 'Landline Number',
                hint: 'e.g. 079-12345678',
                icon: Icons.phone_callback_outlined,
                maxLength: 20,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                ],
              ),

              const SizedBox(height: 16),

              _buildField(
                controller: _tollFreeCtrl,
                label: 'Toll-Free Number',
                hint: 'e.g. 1800-123-4567',
                icon: Icons.support_agent_outlined,
                maxLength: 20,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── SECTION 3: TAX & LEGAL ───────────────────────
          _buildCardContainer(
            icon: Icons.receipt_long,
            title: 'Tax & Legal Identifiers',
            children: [
              _buildField(
                controller: _panCtrl,
                label: 'PAN Number',
                hint: 'e.g. ABCDE1234F',
                icon: Icons.badge_outlined,
                isRequired: true,
                maxLength: 10,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (v) {
                  _panCtrl.value = _panCtrl.value.copyWith(
                    text: v.toUpperCase(),
                    selection:
                        TextSelection.collapsed(offset: v.toUpperCase().length),
                  );
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'PAN number is required';
                  }
                  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                      .hasMatch(v.trim().toUpperCase())) {
                    return 'Invalid PAN format (e.g. ABCDE1234F)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildField(
                controller: _gstCtrl,
                label: 'GST Number',
                hint: 'e.g. 24ABCDE1234F1Z5',
                icon: Icons.account_balance_outlined,
                isRequired: true,
                maxLength: 15,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (v) {
                  _gstCtrl.value = _gstCtrl.value.copyWith(
                    text: v.toUpperCase(),
                    selection:
                        TextSelection.collapsed(offset: v.toUpperCase().length),
                  );
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'GST number is required';
                  }
                  if (!RegExp(
                          r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$')
                      .hasMatch(v.trim().toUpperCase())) {
                    return 'Invalid GST format (15 characters)';
                  }
                  return null;
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── SECTION 4: ADDRESS (WITH CITY AUTOCOMPLETE) ──
          _buildCardContainer(
            icon: Icons.location_on,
            title: 'Registered Address',
            children: [
              _buildField(
                controller: _addressCtrl,
                label: 'Street Address',
                hint: 'Full physical address (Shop / Office / Plot / Area)',
                icon: Icons.location_on_outlined,
                isRequired: true,
                maxLength: 300,
                maxLines: 2,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Address is required'
                    : null,
              ),

              const SizedBox(height: 16),

              // City field with Autocomplete trigger
              _buildField(
                controller: _cityCtrl,
                label: 'City (Search or Type)',
                hint: 'e.g. Ahmedabad, Mumbai, Delhi',
                icon: Icons.location_city_outlined,
                isRequired: true,
                maxLength: 100,
                onChanged: (v) {
                  _searchLocation(v);
                },
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'City is required'
                    : null,
              ),

              // Location Search Indicator
              if (_isSearchingLocation)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Searching places...',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

              // Suggestions Dropdown
              if (_locationSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  constraints: const BoxConstraints(maxHeight: 210),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _locationSuggestions.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, index) {
                      final s = _locationSuggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        title: Text(
                          s.city.isNotEmpty ? s.city : s.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (s.state.isNotEmpty) s.state,
                            if (s.country.isNotEmpty) s.country,
                          ].join(', '),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: () {
                          final selectedCity =
                              s.city.isNotEmpty ? s.city : s.name;
                          _cityCtrl.text = selectedCity;
                          _stateCtrl.text = s.state;
                          if (s.country.isNotEmpty) {
                            _countryCtrl.text = s.country;
                          }
                          setState(() {
                            _locationSuggestions.clear();
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _stateCtrl,
                      label: 'State',
                      hint: 'State',
                      icon: Icons.map_outlined,
                      isRequired: true,
                      maxLength: 100,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'State is required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _countryCtrl,
                      label: 'Country',
                      hint: 'India',
                      icon: Icons.public_outlined,
                      isRequired: true,
                      maxLength: 100,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Country is required'
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _branchCtrl,
                      label: 'Branch Name',
                      hint: 'e.g. Head Office',
                      icon: Icons.store_outlined,
                      maxLength: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _mainBranchCtrl,
                      label: 'Main Branch',
                      hint: 'e.g. Main Hub',
                      icon: Icons.hub_outlined,
                      maxLength: 100,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── SECTION 5: ONLINE PRESENCE ───────────────────
          _buildCardContainer(
            icon: Icons.language,
            title: 'Online Presence',
            children: [
              _buildField(
                controller: _websiteCtrl,
                label: 'Website URL',
                hint: 'https://www.cargosetu.com',
                icon: Icons.link_outlined,
                maxLength: 255,
                keyboardType: TextInputType.url,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ─── FUTURISTIC SUBMIT BUTTON ─────────────────────
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditMode
                              ? Icons.check_circle_outline
                              : Icons.add_business_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditMode ? 'Update Company' : 'Create Company',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ─── Futuristic Logo Upload Card ──────────────────────────
  Widget _buildLogoUploadCard() {
    final existingLogo = widget.company?.logoUrlOrBase64;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo Display / Picker Box
          GestureDetector(
            onTap: _showLogoPickerSheet,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: _logoFile != null
                        ? Image.file(_logoFile!, fit: BoxFit.cover)
                        : (existingLogo != null && existingLogo.isNotEmpty)
                            ? _buildImageFromUrlOrBase64(existingLogo)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined,
                                      size: 28, color: AppColors.primaryBlue),
                                  SizedBox(height: 4),
                                  Text(
                                    'Logo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company Brand Logo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upload logo in JPG, PNG or SVG (Max 1MB). It will appear on your LR, Invoices & Quotations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showLogoPickerSheet,
                  child: Text(
                    _logoFile != null || existingLogo != null
                        ? 'Change Brand Logo'
                        : 'Upload Logo',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFromUrlOrBase64(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 32),
      );
    }
    try {
      final cleanBase64 =
          source.contains(',') ? source.split(',').last : source;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.business, size: 32);
    }
  }

  // ─── Section Card Wrapper ─────────────────────────────────
  Widget _buildCardContainer({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: icon,
            title: title,
            padding: const EdgeInsets.only(bottom: 14),
          ),
          ...children,
        ],
      ),
    );
  }

  // ─── Same as WhatsApp Checkbox ────────────────────────────
  Widget _buildSameAsCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Phone Field with Country Picker ──────────────────────
  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String countryCode,
    required VoidCallback onCodeTap,
    bool isRequired = false,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: isRequired
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: readOnly ? null : onCodeTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      countryCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 15,
                readOnly: readOnly,
                validator: validator,
                onChanged: onChanged,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor:
                      readOnly ? const Color(0xFFF1F5F9) : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.borderFocused, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  errorStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Standard Text Field ──────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: isRequired
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.borderFocused, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            errorStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
