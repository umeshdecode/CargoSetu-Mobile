import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_controller.dart';
import '../models/driver_model.dart';

class DriverFormScreen extends StatefulWidget {
  final DriverModel? driver;

  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _licenseController;
  late TextEditingController _expController;
  late TextEditingController _addressController;

  String _status = 'ACTIVE';
  DateTime? _licenseExpiryDate;
  DateTime? _joiningDate;

  bool get isEditMode => widget.driver != null;

  final List<String> _statuses = ['ACTIVE', 'INACTIVE', 'SUSPENDED'];

  @override
  void initState() {
    super.initState();
    final d = widget.driver;

    _nameController = TextEditingController(text: d?.name ?? '');
    _phoneController = TextEditingController(text: d?.phoneNumber ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _licenseController = TextEditingController(text: d?.licenseNumber ?? '');
    _expController = TextEditingController(text: d?.experienceYears != null ? d!.experienceYears.toString() : '');
    _addressController = TextEditingController(text: d?.address ?? '');

    if (d != null) {
      _status = _statuses.contains(d.status) ? d.status : 'ACTIVE';
      if (d.licenseExpiryDate != null) {
        _licenseExpiryDate = DateTime.tryParse(d.licenseExpiryDate!);
      }
      if (d.joiningDate != null) {
        _joiningDate = DateTime.tryParse(d.joiningDate!);
      }
    } else {
      _licenseExpiryDate = DateTime.now().add(const Duration(days: 365 * 3));
      _joiningDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _expController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => onSelected(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_licenseExpiryDate == null) {
      AppSnackbar.error('License expiry date is required');
      return;
    }

    if (_licenseExpiryDate!.isBefore(DateTime.now())) {
      AppSnackbar.error('License expiry date must be in the future');
      return;
    }

    final controller = Get.find<DriverController>();

    final success = await controller.saveDriver(
      id: widget.driver?.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      licenseNumber: _licenseController.text.trim().toUpperCase(),
      licenseExpiryDate: _formatDate(_licenseExpiryDate),
      experienceYears: int.tryParse(_expController.text.trim()),
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      status: _status,
      joiningDate: _joiningDate != null ? _formatDate(_joiningDate) : null,
    );

    if (success) {
      Get.back(result: true);
      AppSnackbar.success(widget.driver != null ? 'Driver updated successfully' : 'Driver added successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Driver' : 'Add New Driver',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: AppColors.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Update Driver Profile' : 'Driver Registration',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Enter driver personal, contact, and license credentials',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Personal & Contact Details Card
              _buildSectionCard(
                title: 'Personal & Contact Information',
                icon: Icons.person_outline,
                children: [
                  _buildTextField(
                    label: 'Full Name *',
                    controller: _nameController,
                    hint: 'e.g. Ramesh Kumar',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Full name is required';
                      if (v.trim().length < 2) return 'Name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Phone Number *',
                    controller: _phoneController,
                    hint: 'e.g. 9876543210',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone number is required';
                      final cleaned = v.trim().replaceAll(RegExp(r'[\s-]'), '');
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
                        return 'Enter a valid 10-15 digit phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Email Address *',
                    controller: _emailController,
                    hint: 'e.g. driver@cargosetu.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // License & Experience Card
              _buildSectionCard(
                title: 'License & Professional Details',
                icon: Icons.assignment_ind_outlined,
                children: [
                  _buildTextField(
                    label: 'Driving License Number *',
                    controller: _licenseController,
                    hint: 'e.g. DL-1420230001234',
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'License number is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDateTile(
                    label: 'License Expiry Date *',
                    date: _licenseExpiryDate,
                    onTap: () {
                      _pickDate(
                        context: context,
                        initialDate: _licenseExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime(2045),
                        onSelected: (d) => _licenseExpiryDate = d,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Experience (Years)',
                          controller: _expController,
                          hint: 'e.g. 5',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final years = int.tryParse(v.trim());
                              if (years == null || years < 0 || years > 60) {
                                return '0 - 60 yrs';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Status *',
                          value: _status,
                          items: _statuses,
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDateTile(
                    label: 'Joining Date',
                    date: _joiningDate,
                    onTap: () {
                      _pickDate(
                        context: context,
                        initialDate: _joiningDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        onSelected: (d) => _joiningDate = d,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address Card
              _buildSectionCard(
                title: 'Address & Residential',
                icon: Icons.home_outlined,
                children: [
                  _buildTextField(
                    label: 'Full Address',
                    controller: _addressController,
                    hint: 'Street, city, state, pin code',
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(() {
                final saving = controller.isSaving.value;
                return ElevatedButton(
                  onPressed: saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditMode ? 'Update Driver' : 'Add Driver',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((i) {
            return DropdownMenuItem(
              value: i,
              child: Text(
                i,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final formatted = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : 'Select date';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: date != null ? AppColors.primaryBlue : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
