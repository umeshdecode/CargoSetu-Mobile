import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle_model.dart';
import '../models/truck_option_model.dart';
import '../models/vehicle_catalogue_models.dart';
import '../widgets/vehicle_catalogue_picker.dart';

class VehicleFormScreen extends StatefulWidget {
  final VehicleModel? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _regNoController;
  late TextEditingController _modelController;
  late TextEditingController _manufacturerController;
  late TextEditingController _chassisController;
  late TextEditingController _engineController;
  late TextEditingController _capacityController;
  late TextEditingController _mileageController;
  late TextEditingController _locationController;

  String _vehicleType = 'TRUCK';
  String _fuelType = 'DIESEL';
  String _status = 'AVAILABLE';
  String _weightUnit = 'Kg'; // 'Kg' or 'Ton'

  // Load Posting Dynamic Options
  String _truckType = 'OPEN_TRUCK';
  String? _bodyType;
  String? _lengthOption;
  String? _wheelerOption;
  String? _passingCapacityOption;

  DateTime? _regDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _pollutionExpiryDate;

  bool get isEditMode => widget.vehicle != null;

  final List<String> _vehicleTypes = [
    'TRUCK',
    'TEMPO',
    'TRAILER',
    'CONTAINER',
    'TANKER',
    'LCV',
    'VAN',
  ];

  final List<String> _fuelTypes = [
    'DIESEL',
    'PETROL',
    'CNG',
    'ELECTRIC',
  ];

  final List<String> _statuses = [
    'AVAILABLE',
    'ON_TRIP',
    'MAINTENANCE',
    'OUT_OF_SERVICE',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    _regNoController = TextEditingController(text: v?.registrationNumber ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _manufacturerController = TextEditingController(text: v?.manufacturer ?? '');
    _chassisController = TextEditingController(text: v?.chassisNumber ?? '');
    _engineController = TextEditingController(text: v?.engineNumber ?? '');
    _locationController = TextEditingController(text: v?.currentLocation ?? '');
    _mileageController = TextEditingController(text: v?.mileage != null ? v!.mileage.toString() : '');

    if (v != null) {
      _vehicleType = _vehicleTypes.contains(v.vehicleType) ? v.vehicleType : 'TRUCK';
      _fuelType = _fuelTypes.contains(v.fuelType) ? v.fuelType : 'DIESEL';
      _status = _statuses.contains(v.status) ? v.status : 'AVAILABLE';

      _truckType = v.truckType ?? 'OPEN_TRUCK';
      _bodyType = v.bodyType;
      _lengthOption = v.lengthOption;
      _wheelerOption = v.wheelerOption;
      _passingCapacityOption = v.passingCapacityOption;

      // Weight unit determination
      if (v.capacityKg >= 1000 && v.capacityKg % 1000 == 0) {
        _weightUnit = 'Ton';
        _capacityController = TextEditingController(text: (v.capacityKg ~/ 1000).toString());
      } else {
        _weightUnit = 'Kg';
        _capacityController = TextEditingController(text: v.capacityKg.toString());
      }

      if (v.registrationDate != null) _regDate = DateTime.tryParse(v.registrationDate!);
      if (v.insuranceExpiryDate != null) _insuranceExpiryDate = DateTime.tryParse(v.insuranceExpiryDate!);
      if (v.pollutionExpiryDate != null) _pollutionExpiryDate = DateTime.tryParse(v.pollutionExpiryDate!);
    } else {
      _capacityController = TextEditingController(text: '');
      _regDate = DateTime.now();
      _insuranceExpiryDate = DateTime.now().add(const Duration(days: 365));
      _pollutionExpiryDate = DateTime.now().add(const Duration(days: 180));
    }
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _chassisController.dispose();
    _engineController.dispose();
    _capacityController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onTruckTypeChanged(String newType, List<TruckOptionModel> availableOptions) {
    setState(() {
      _truckType = newType;
      final match = availableOptions.firstWhere(
        (opt) => opt.truckType.toUpperCase() == newType.toUpperCase(),
        orElse: () => TruckOptionModel(truckType: newType, displayName: newType),
      );

      if (match.bodyTypes.isNotEmpty) {
        if (_bodyType == null || !match.bodyTypes.contains(_bodyType)) {
          _bodyType = match.bodyTypes.first;
        }
      } else {
        _bodyType = null;
      }

      if (match.availableLengthsFeet.isNotEmpty) {
        if (_lengthOption == null || !match.availableLengthsFeet.contains(_lengthOption)) {
          _lengthOption = match.availableLengthsFeet.first;
        }
      } else {
        _lengthOption = null;
      }

      if (match.availableWheelers.isNotEmpty) {
        if (_wheelerOption == null || !match.availableWheelers.contains(_wheelerOption)) {
          _wheelerOption = match.availableWheelers.first;
        }
      } else {
        _wheelerOption = null;
      }

      if (match.availablePassingTons.isNotEmpty) {
        if (_passingCapacityOption == null || !match.availablePassingTons.contains(_passingCapacityOption)) {
          _passingCapacityOption = match.availablePassingTons.first;
        }
      } else {
        _passingCapacityOption = null;
      }
    });
  }

  void _applyCatalogueModel(CatalogueDetailModel detail) {
    setState(() {
      if (detail.brand != null && detail.brand!.name.isNotEmpty) {
        _manufacturerController.text = detail.brand!.name;
      }
      _modelController.text = detail.name;

      final specs = detail.specifications;
      if (specs != null) {
        if (specs.fuelType != null && specs.fuelType!.isNotEmpty) {
          final mappedFuel = specs.fuelType!.toUpperCase();
          if (_fuelTypes.contains(mappedFuel)) {
            _fuelType = mappedFuel;
          }
        }

        if (specs.mileageKmpl != null && specs.mileageKmpl! > 0) {
          _mileageController.text = specs.mileageKmpl.toString();
        }

        final pCap = specs.payloadKg ?? specs.gvwKg;
        if (pCap != null && pCap > 0) {
          if (pCap >= 1000 && pCap % 1000 == 0) {
            _weightUnit = 'Ton';
            _capacityController.text = (pCap ~/ 1000).toString();
          } else {
            _weightUnit = 'Kg';
            _capacityController.text = pCap.toString();
          }
        }

        if (specs.numberOfTyres != null && specs.numberOfTyres! > 0) {
          _wheelerOption = '${specs.numberOfTyres} Wheeler';
        }
      }

      if (detail.category != null && detail.category!.isNotEmpty) {
        final catUpper = detail.category!.toUpperCase();
        final controller = Get.find<VehicleController>();
        final match = controller.truckOptions.firstWhereOrNull(
          (o) => o.truckType.toUpperCase() == catUpper || o.displayName.toUpperCase().contains(catUpper),
        );
        if (match != null) {
          _onTruckTypeChanged(match.truckType, controller.truckOptions);
        }
      }
    });

    AppSnackbar.success('Auto-filled from ${detail.brand?.name ?? ''} ${detail.name}');
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initialDate,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error('Please fill in all required fields properly');
      return;
    }

    if (_insuranceExpiryDate == null) {
      AppSnackbar.error('Insurance expiry date is mandatory');
      return;
    }

    if (_pollutionExpiryDate == null) {
      AppSnackbar.error('Pollution expiry date is mandatory');
      return;
    }

    final rawCap = double.tryParse(_capacityController.text.trim()) ?? 0;
    final int computedCapacityKg = _weightUnit == 'Ton' ? (rawCap * 1000).round() : rawCap.round();

    if (computedCapacityKg <= 0) {
      AppSnackbar.error('Vehicle capacity must be greater than 0');
      return;
    }

    // Parse numeric length if present
    double? numLength;
    if (_lengthOption != null) {
      final reg = RegExp(r'\d+(\.\d+)?');
      final m = reg.firstMatch(_lengthOption!);
      if (m != null) numLength = double.tryParse(m.group(0)!);
    }

    // Parse numeric wheelers
    int? numWheeler;
    if (_wheelerOption != null) {
      final reg = RegExp(r'\d+');
      final m = reg.firstMatch(_wheelerOption!);
      if (m != null) numWheeler = int.tryParse(m.group(0)!);
    }

    // Parse numeric passing tons
    double? numTons;
    if (_passingCapacityOption != null) {
      final reg = RegExp(r'\d+(\.\d+)?');
      final m = reg.firstMatch(_passingCapacityOption!);
      if (m != null) numTons = double.tryParse(m.group(0)!);
    }

    final controller = Get.find<VehicleController>();

    final success = await controller.saveVehicle(
      id: widget.vehicle?.id,
      registrationNumber: _regNoController.text,
      vehicleType: _vehicleType,
      model: _modelController.text,
      manufacturer: _manufacturerController.text,
      capacityKg: computedCapacityKg,
      chassisNumber: _chassisController.text,
      engineNumber: _engineController.text,
      mileage: double.tryParse(_mileageController.text.trim()),
      status: _status,
      fuelType: _fuelType,
      registrationDate: _regDate != null ? _formatDate(_regDate!) : null,
      insuranceExpiryDate: _insuranceExpiryDate != null ? _formatDate(_insuranceExpiryDate!) : null,
      pollutionExpiryDate: _pollutionExpiryDate != null ? _formatDate(_pollutionExpiryDate!) : null,
      currentLocation: _locationController.text,

      truckType: _truckType,
      bodyType: _bodyType,
      truckLengthFeet: numLength,
      lengthOption: _lengthOption,
      wheelerCount: numWheeler,
      wheelerOption: _wheelerOption,
      passingCapacityTons: numTons,
      passingCapacityOption: _passingCapacityOption,
    );

    if (success) {
      Get.back(result: true);
      AppSnackbar.success(isEditMode ? 'Vehicle updated successfully' : 'Vehicle added successfully');
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEditMode ? 'Edit Vehicle' : 'Add New Vehicle',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ─── Catalogue Quick-Fill Banner ─────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.manage_search, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Quick Fill from Catalogue',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select Tata, Eicher, Mahindra model specs',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      VehicleCataloguePickerBottomSheet.show(
                        context,
                        onModelSelected: _applyCatalogueModel,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E40AF),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Browse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // ─── Basic Details Section ────────────────────────
            _buildSectionHeader('VEHICLE IDENTIFICATION'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField(
                controller: _regNoController,
                label: 'Registration Number',
                hint: 'e.g. MH12AB1234',
                textCapitalization: TextCapitalization.characters,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Vehicle Type',
                      value: _vehicleType,
                      items: _vehicleTypes,
                      onChanged: (v) => setState(() => _vehicleType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Fuel Type',
                      value: _fuelType,
                      items: _fuelTypes,
                      onChanged: (v) => setState(() => _fuelType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _manufacturerController,
                      label: 'Manufacturer',
                      hint: 'e.g. Tata, Mahindra',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'Model',
                      hint: 'e.g. 407, Ace',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // ─── Dynamic Load Posting Section ─────────────────
            _buildSectionHeader('LOAD POSTING & CLASSIFICATION'),
            const SizedBox(height: 12),
            Obx(() {
              final options = controller.truckOptions;

              // Ensure _truckType has a valid selection
              final availableTypes = options.isNotEmpty
                  ? options.map((e) => e.truckType).toList()
                  : ['OPEN_TRUCK', 'CONTAINER', 'LCV', 'TIPPER', 'TANKER', 'TRAILER', 'REEFER'];

              if (!availableTypes.contains(_truckType)) {
                _truckType = availableTypes.first;
              }

              final activeModel = options.firstWhere(
                (e) => e.truckType.toUpperCase() == _truckType.toUpperCase(),
                orElse: () => TruckOptionModel(truckType: _truckType, displayName: _truckType),
              );

              return _buildCard([
                _buildDropdown(
                  label: 'Truck Category (Load Posting)',
                  value: _truckType,
                  items: availableTypes,
                  onChanged: (val) {
                    if (val != null) {
                      _onTruckTypeChanged(val, options);
                    }
                  },
                ),
                if (activeModel.bodyTypes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Body Sub-Type',
                    value: (_bodyType != null && activeModel.bodyTypes.contains(_bodyType))
                        ? _bodyType!
                        : activeModel.bodyTypes.first,
                    items: activeModel.bodyTypes,
                    onChanged: (v) => setState(() => _bodyType = v),
                  ),
                ],
                if (activeModel.availableLengthsFeet.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Deck Length (Feet)',
                    value: (_lengthOption != null && activeModel.availableLengthsFeet.contains(_lengthOption))
                        ? _lengthOption!
                        : activeModel.availableLengthsFeet.first,
                    items: activeModel.availableLengthsFeet,
                    onChanged: (v) => setState(() => _lengthOption = v),
                  ),
                ],
                if (activeModel.availableWheelers.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Wheelers / Tyres',
                    value: (_wheelerOption != null && activeModel.availableWheelers.contains(_wheelerOption))
                        ? _wheelerOption!
                        : activeModel.availableWheelers.first,
                    items: activeModel.availableWheelers,
                    onChanged: (v) => setState(() => _wheelerOption = v),
                  ),
                ],
                if (activeModel.availablePassingTons.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Passing Capacity (Tons)',
                    value: (_passingCapacityOption != null && activeModel.availablePassingTons.contains(_passingCapacityOption))
                        ? _passingCapacityOption!
                        : activeModel.availablePassingTons.first,
                    items: activeModel.availablePassingTons,
                    onChanged: (v) => setState(() => _passingCapacityOption = v),
                  ),
                ],
              ]);
            }),
            const SizedBox(height: 20),

            // ─── Technical & Capacity Section ─────────────────
            _buildSectionHeader('TECHNICAL & SPECS'),
            const SizedBox(height: 12),
            _buildCard([
              // Capacity with Unit Toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _capacityController,
                      label: 'Payload Capacity',
                      hint: 'e.g. 5',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _weightUnit,
                      items: const ['Kg', 'Ton'],
                      onChanged: (u) => setState(() => _weightUnit = u!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _mileageController,
                      label: 'Mileage (km/l)',
                      hint: 'e.g. 14.5',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Operational Status',
                      value: _status,
                      items: _statuses,
                      onChanged: (s) => setState(() => _status = s!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _locationController,
                label: 'Current Location',
                hint: 'e.g. Mumbai Central Depot',
              ),
            ]),
            const SizedBox(height: 20),

            // ─── Engine & Chassis Numbers ─────────────────────
            _buildSectionHeader('SECURITY & ENGINE DETAILS'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField(
                controller: _chassisController,
                label: 'Chassis Number',
                hint: 'Unique chassis identifier',
                textCapitalization: TextCapitalization.characters,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _engineController,
                label: 'Engine Number',
                hint: 'Unique engine identifier',
                textCapitalization: TextCapitalization.characters,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
            ]),
            const SizedBox(height: 20),

            // ─── Document Expiry Dates ────────────────────────
            _buildSectionHeader('DATES & COMPLIANCE'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDateTile(
                label: 'Registration Date',
                date: _regDate,
                onTap: () => _pickDate(context, _regDate, (d) => setState(() => _regDate = d)),
              ),
              const Divider(height: 20, color: AppColors.border),
              _buildDateTile(
                label: 'Insurance Expiry Date *',
                date: _insuranceExpiryDate,
                onTap: () => _pickDate(
                  context,
                  _insuranceExpiryDate,
                  (d) => setState(() => _insuranceExpiryDate = d),
                ),
              ),
              const Divider(height: 20, color: AppColors.border),
              _buildDateTile(
                label: 'Pollution / PUC Expiry Date *',
                date: _pollutionExpiryDate,
                onTap: () => _pickDate(
                  context,
                  _pollutionExpiryDate,
                  (d) => setState(() => _pollutionExpiryDate = d),
                ),
              ),
            ]),
            const SizedBox(height: 30),

            // ─── Submit Button ────────────────────────────────
            Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditMode ? 'Update Vehicle' : 'Save Vehicle',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
    final validValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

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
          initialValue: validValue,
          onChanged: onChanged,
          items: items.map((i) {
            return DropdownMenuItem(
              value: i,
              child: Text(
                i.replaceAll('_', ' '),
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
                fontSize: 13,
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
