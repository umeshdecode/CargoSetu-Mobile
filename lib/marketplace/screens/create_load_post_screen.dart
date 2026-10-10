import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/load_post_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';

/// Clean multi-step form to post freight load demand.
/// Designed for easy data entry by shippers with clear visual sections,
/// validation, and zero internal database ID exposure.
class CreateLoadPostScreen extends StatefulWidget {
  const CreateLoadPostScreen({super.key});

  @override
  State<CreateLoadPostScreen> createState() => _CreateLoadPostScreenState();
}

class _CreateLoadPostScreenState extends State<CreateLoadPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MarketplaceService();

  // Route Controllers
  final _originCityCtrl = TextEditingController();
  final _originAddressCtrl = TextEditingController();
  final _destCityCtrl = TextEditingController();
  final _destAddressCtrl = TextEditingController();

  // Dates
  DateTime? _pickupDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _deliveryDate = DateTime.now().add(const Duration(days: 3));

  // Cargo Specs
  CargoType _cargoType = CargoType.GENERAL;
  final _weightCtrl = TextEditingController();
  CapacityUnit _weightUnit = CapacityUnit.TONNE;
  final _volumeCtrl = TextEditingController();
  final _packageCountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Truck Requirement
  String _truckType = 'Any Standard Truck';
  String _bodyType = 'Open Body';
  final _lengthCtrl = TextEditingController();

  // Commercials
  final _priceCtrl = TextEditingController();
  String _priceType = 'FIXED';
  PaymentTermType _paymentTerms = PaymentTermType.ADVANCE_PERCENT;
  int _advancePct = 50;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _originCityCtrl.dispose();
    _originAddressCtrl.dispose();
    _destCityCtrl.dispose();
    _destAddressCtrl.dispose();
    _weightCtrl.dispose();
    _volumeCtrl.dispose();
    _packageCountCtrl.dispose();
    _descriptionCtrl.dispose();
    _lengthCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Post Freight Load',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Section 1: Route ───
              _sectionCard(
                title: '1. Route & Schedule',
                icon: Icons.navigation_outlined,
                children: [
                  _textInput(
                    controller: _originCityCtrl,
                    label: 'Origin City (Pickup) *',
                    hint: 'e.g. Mumbai, Pune',
                    prefixIcon: const Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                    validator: (v) => v?.trim().isEmpty == true ? 'Origin city is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _textInput(
                    controller: _originAddressCtrl,
                    label: 'Pickup Address / Area (Optional)',
                    hint: 'e.g. MIDC Industrial Area Phase 2',
                  ),
                  const SizedBox(height: 14),
                  _textInput(
                    controller: _destCityCtrl,
                    label: 'Destination City (Delivery) *',
                    hint: 'e.g. Delhi, Ahmedabad',
                    prefixIcon: const Icon(Icons.location_on, size: 12, color: Color(0xFFEF4444)),
                    validator: (v) => v?.trim().isEmpty == true ? 'Destination city is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _textInput(
                    controller: _destAddressCtrl,
                    label: 'Delivery Address / Area (Optional)',
                    hint: 'e.g. Transport Nagar, Warehouse #4',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _datePickerTile(
                          label: 'Pickup Date',
                          selectedDate: _pickupDate,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _datePickerTile(
                          label: 'Delivery By',
                          selectedDate: _deliveryDate,
                          onTap: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Section 2: Commodity & Cargo ───
              _sectionCard(
                title: '2. Cargo Specifications',
                icon: Icons.inventory_2_outlined,
                children: [
                  _dropdownInput<CargoType>(
                    label: 'Cargo Category *',
                    value: _cargoType,
                    items: CargoType.values.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.displayName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _cargoType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _textInput(
                          controller: _weightCtrl,
                          label: 'Weight *',
                          hint: 'e.g. 15.5',
                          keyboardType: TextInputType.number,
                          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _dropdownInput<CapacityUnit>(
                          label: 'Unit',
                          value: _weightUnit,
                          items: CapacityUnit.values.map((u) {
                            return DropdownMenuItem(value: u, child: Text(u.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _weightUnit = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _textInput(
                          controller: _packageCountCtrl,
                          label: 'Package Count',
                          hint: 'e.g. 120 boxes',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textInput(
                          controller: _volumeCtrl,
                          label: 'Volume (CFT)',
                          hint: 'e.g. 800',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _textInput(
                    controller: _descriptionCtrl,
                    label: 'Material Description',
                    hint: 'e.g. Industrial pipes, palletized carton goods',
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Section 3: Vehicle Requirements ───
              _sectionCard(
                title: '3. Truck Requirements',
                icon: Icons.local_shipping_outlined,
                children: [
                  _dropdownInput<String>(
                    label: 'Body Type',
                    value: _bodyType,
                    items: ['Open Body', 'Container / Closed', 'Flatbed', 'Trailer', 'Refrigerated']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _bodyType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownInput<String>(
                          label: 'Truck Category',
                          value: _truckType,
                          items: ['Any Standard Truck', '32 Ft Multi-Axle', '24 Ft Open', '19 Ft Container', 'Tata 407 / Pickup']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _truckType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textInput(
                          controller: _lengthCtrl,
                          label: 'Min Length (Ft)',
                          hint: 'e.g. 32',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Section 4: Commercials ───
              _sectionCard(
                title: '4. Expected Freight & Terms',
                icon: Icons.payments_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _textInput(
                          controller: _priceCtrl,
                          label: 'Asking Freight (₹)',
                          hint: 'e.g. 45000',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _dropdownInput<String>(
                          label: 'Rate Type',
                          value: _priceType,
                          items: const [
                            DropdownMenuItem(value: 'FIXED', child: Text('Fixed Rate')),
                            DropdownMenuItem(value: 'PER_TON', child: Text('Per Ton')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _priceType = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _dropdownInput<PaymentTermType>(
                    label: 'Payment Terms',
                    value: _paymentTerms,
                    items: PaymentTermType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentTerms = val);
                    },
                  ),
                  if (_paymentTerms == PaymentTermType.ADVANCE_PERCENT) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Advance Percentage',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [20, 30, 50, 70, 80].map((pct) {
                        final isSel = _advancePct == pct;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('$pct%'),
                            selected: isSel,
                            onSelected: (_) => setState(() => _advancePct = pct),
                            selectedColor: AppColors.primaryBlueLight,
                            labelStyle: TextStyle(
                              color: isSel ? AppColors.primaryBlue : const Color(0xFF475569),
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // ─── Submit CTA ───
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Publish Load on Marketplace',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupDate == null) {
      Get.snackbar(
        'Pickup Date Required',
        'Please select a scheduled pickup date.',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final pickupStr = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_pickupDate!);
    final deliveryStr = _deliveryDate != null
        ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_deliveryDate!)
        : null;

    final model = LoadPostModel(
      originCity: _originCityCtrl.text.trim(),
      originAddress: _originAddressCtrl.text.trim().isEmpty ? null : _originAddressCtrl.text.trim(),
      destinationCity: _destCityCtrl.text.trim(),
      destinationAddress: _destAddressCtrl.text.trim().isEmpty ? null : _destAddressCtrl.text.trim(),
      pickupFrom: pickupStr,
      deliveryTo: deliveryStr,
      cargoType: _cargoType,
      cargoDescription: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      weight: double.tryParse(_weightCtrl.text.trim()) ?? 1.0,
      weightUnit: _weightUnit,
      volume: double.tryParse(_volumeCtrl.text.trim()),
      packageCount: int.tryParse(_packageCountCtrl.text.trim()),
      requiredTruckType: _truckType,
      requiredBodyType: _bodyType,
      requiredTruckLength: double.tryParse(_lengthCtrl.text.trim()),
      askingPrice: double.tryParse(_priceCtrl.text.trim()),
      priceType: _priceType,
      paymentTerms: _paymentTerms,
      advancePercentage: _advancePct,
    );

    final success = await _service.createLoadPost(model);
    setState(() => _isSubmitting = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Load Published!',
        'Your freight load has been published. Fleet operators and truckers can now discover and bid on it.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFECFDF5),
        colorText: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Submission Failed',
        'Could not publish load. Please check details and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFDC2626),
      );
    }
  }

  void _pickDate(bool isPickup) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
        } else {
          _deliveryDate = picked;
        }
      });
    }
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _dropdownInput<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePickerTile({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  selectedDate != null ? DateFormat('dd MMM yyyy').format(selectedDate) : 'Select date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selectedDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
