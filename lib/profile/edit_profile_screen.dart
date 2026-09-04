import 'dart:convert';
import 'dart:io';

import 'package:cargo_setu/profile/model/staff_model.dart';
import 'package:cargo_setu/profile/profile_controller.dart';
import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Edit Profile screen — self-service update for the logged-in user.
///
/// Covers personal info, contact, address (with location autocomplete),
/// license details, and profile image upload.
class EditProfileScreen extends StatefulWidget {
  final StaffModel? staff;

  const EditProfileScreen({super.key, this.staff});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _ctrl = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  late StaffModel _staff;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _altMobileCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _licenseCtrl;

  DateTime? _licenseExpiry;
  File? _selectedImageFile;

  // Location autocomplete
  List<LocationSuggestion> _citySuggestions = [];
  bool _showCitySuggestions = false;
  int _searchVersion = 0;

  @override
  void initState() {
    super.initState();
    _staff = widget.staff ?? _ctrl.profile.value ?? const StaffModel();
    final s = _staff;
    _firstNameCtrl = TextEditingController(text: s.firstName);
    _lastNameCtrl = TextEditingController(text: s.lastName);
    _emailCtrl = TextEditingController(text: s.email ?? '');
    _mobileCtrl = TextEditingController(text: s.mobileNumber ?? '');
    _altMobileCtrl = TextEditingController(text: s.alternateMobile ?? '');
    _addressCtrl = TextEditingController(text: s.address ?? '');
    _cityCtrl = TextEditingController(text: s.city ?? '');
    _stateCtrl = TextEditingController(text: s.state ?? '');
    _pincodeCtrl = TextEditingController(text: s.pincode ?? '');
    _licenseCtrl = TextEditingController(text: s.licenseNumber ?? '');
    _licenseExpiry = s.licenseExpiryDate;

    _cityCtrl.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    _cityCtrl.removeListener(_onCityChanged);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _altMobileCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  void _onCityChanged() async {
    final query = _cityCtrl.text.trim();
    if (query.length < 3) {
      setState(() {
        _citySuggestions = [];
        _showCitySuggestions = false;
      });
      return;
    }
    final currentVersion = ++_searchVersion;
    final results = await LocationService.searchLocations(query);
    if (mounted && currentVersion == _searchVersion) {
      setState(() {
        _citySuggestions = results;
        _showCitySuggestions = results.isNotEmpty;
      });
    }
  }

  void _selectCity(LocationSuggestion suggestion) {
    _searchVersion++;
    _cityCtrl.removeListener(_onCityChanged);
    _cityCtrl.text = suggestion.city.isNotEmpty ? suggestion.city : suggestion.name;
    _stateCtrl.text = suggestion.state;
    setState(() {
      _citySuggestions = [];
      _showCitySuggestions = false;
    });
    _cityCtrl.addListener(_onCityChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 0.5),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PROFILE IMAGE ──────────────────────
              Center(child: _buildImagePicker()),
              const SizedBox(height: 24),

              // ── PERSONAL INFO ──────────────────────
              _sectionHeader('Personal Information'),
              const SizedBox(height: 12),
              _buildField('First Name', _firstNameCtrl,
                  validator: _requiredValidator, maxLength: 50),
              _buildField('Last Name', _lastNameCtrl,
                  validator: _requiredValidator, maxLength: 50),
              _buildField('Email', _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  maxLength: 100),
              const SizedBox(height: 8),

              // ── CONTACT ────────────────────────────
              _sectionHeader('Contact Details'),
              const SizedBox(height: 12),
              _buildField('Mobile Number', _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 12,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              _buildField('Alternate Mobile', _altMobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 12,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 8),

              // ── ADDRESS ────────────────────────────
              _sectionHeader('Address'),
              const SizedBox(height: 12),
              _buildField('Address', _addressCtrl,
                  maxLines: 2, maxLength: 200),
              _buildCityField(),
              _buildField('State', _stateCtrl, maxLength: 50),
              _buildField('Pincode', _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 8),

              // ── LICENSE ────────────────────────────
              _sectionHeader('License Information'),
              const SizedBox(height: 12),
              _buildField('License Number', _licenseCtrl,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.characters),
              _buildDateField(),
              const SizedBox(height: 24),

              // ── SAVE BUTTON ────────────────────────
              Obx(() {
                final isSaving = _ctrl.isSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  IMAGE PICKER
  // ══════════════════════════════════════════════════════
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                width: 3,
              ),
            ),
            child: ClipOval(child: _avatarContent()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Obx(() {
                if (_ctrl.isUploadingImage.value) {
                  return const Padding(
                    padding: EdgeInsets.all(7),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Icon(Icons.camera_alt, size: 15, color: Colors.white);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarContent() {
    if (_selectedImageFile != null) {
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    }
    final url = _staff.profileImageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return Image.network(url, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _initialsFallback());
      }
      try {
        final clean = url.contains(',') ? url.split(',').last : url;
        return Image.memory(base64Decode(clean), fit: BoxFit.cover);
      } catch (_) {
        return _initialsFallback();
      }
    }
    return _initialsFallback();
  }

  Widget _initialsFallback() {
    return Container(
      color: AppColors.primaryBlue.withValues(alpha: 0.08),
      child: Center(
        child: Text(
          _staff.initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryBlue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_staff.hasProfileImage)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      setState(() => _selectedImageFile = file);

      // Upload immediately
      final success = await _ctrl.uploadProfileImage(file);
      if (success && mounted) {
        Get.snackbar('Success', 'Profile photo updated',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF28A745),
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick image',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _removeImage() async {
    final success = await _ctrl.removeProfileImage();
    if (success && mounted) {
      setState(() => _selectedImageFile = null);
      Get.snackbar('Success', 'Profile photo removed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF28A745),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    }
  }

  // ══════════════════════════════════════════════════════
  //  FORM FIELDS
  // ══════════════════════════════════════════════════════
  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF475569),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primaryBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('City', _cityCtrl, maxLength: 50),
        if (_showCitySuggestions && _citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _citySuggestions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = _citySuggestions[i];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.primaryBlue),
                  title: Text(
                    s.displayName,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => _selectCity(s),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: _pickExpiryDate,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'License Expiry Date',
            labelStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                size: 18, color: Color(0xFF94A3B8)),
          ),
          child: Text(
            _licenseExpiry != null ? _formatDate(_licenseExpiry!) : 'Select date',
            style: TextStyle(
              fontSize: 14.5,
              color: _licenseExpiry != null
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) {
      setState(() => _licenseExpiry = date);
    }
  }

  // ══════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = _staff.copyWith(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      alternateMobile: _altMobileCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      licenseExpiryDate: _licenseExpiry,
    );

    final success = await _ctrl.updateMyProfile(updated);

    if (success && mounted) {
      await AppDialog.showSuccess(
        context,
        title: 'Profile Updated',
        message: 'Your profile has been updated successfully.',
        positiveBtnText: 'OK',
        onPositive: () {
          Navigator.of(context).pop(); // Close dialog
        },
      );
      if (mounted) Navigator.of(context).pop(true); // Return to profile
    }
  }

  // ══════════════════════════════════════════════════════
  //  VALIDATORS
  // ══════════════════════════════════════════════════════
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email';
    return null;
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
