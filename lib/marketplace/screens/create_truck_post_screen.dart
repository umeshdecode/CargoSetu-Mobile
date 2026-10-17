import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_enums.dart';
import '../models/truck_post_model.dart';
import '../services/marketplace_service.dart';
import '../widgets/city_autocomplete_field.dart';
import '../../vehicle_management/services/vehicle_service.dart';
import '../../vehicle_management/models/vehicle_model.dart';
import '../../vehicle_management/models/driver_model.dart';

/// Professional multi-step form to post available truck capacity.
/// Tailored for transporters, fleet operators, and single-truck owners.
/// Zero internal database primary key exposure.
class CreateTruckPostScreen extends StatefulWidget {
  final MarketplaceService? service;
  final VehicleService? vehicleService;

  const CreateTruckPostScreen({super.key, this.service, this.vehicleService});

  @override
  State<CreateTruckPostScreen> createState() => _CreateTruckPostScreenState();
}

class _CreateTruckPostScreenState extends State<CreateTruckPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MarketplaceService _service;
  late final VehicleService _vehicleService;

  List<VehicleModel> _myVehicles = [];
  List<DriverModel> _myDrivers = [];
  int? _selectedVehicleId;
  int? _selectedDriverId;
  bool _isLoadingFleet = true;
  String? _fleetLoadError;

  // Location & Routes
  final _currentCityCtrl = TextEditingController();
  final _currentStateCtrl = TextEditingController();
  double? _currentLat;
  double? _currentLng;
  final _routeToCtrl = TextEditingController();
  final _routeToStateCtrl = TextEditingController();
  double? _routeToLat;
  double? _routeToLng;
  final _returnRouteCtrl = TextEditingController();

  double? get _estimatedDistanceKm => LocationService.estimateCityDistanceKm(
    originLat: _currentLat,
    originLng: _currentLng,
    originCity: _currentCityCtrl.text,
    destLat: _routeToLat,
    destLng: _routeToLng,
    destCity: _routeToCtrl.text,
  );

  // Availability Dates
  DateTime? _availableFrom = DateTime.now();
  DateTime? _availableTo = DateTime.now().add(const Duration(days: 7));

  // Capacity & Vehicle Specs
  final _capacityCtrl = TextEditingController();
  CapacityUnit _capacityUnit = CapacityUnit.TONNE;
  final _vehicleNumberCtrl = TextEditingController();
  String _truckType = 'Closed Container';
  String _bodyType = 'Open Body';
  final _passingCapacityCtrl = TextEditingController();
  final _lengthFeetCtrl = TextEditingController();

  // Driver Contact
  final _driverNameCtrl = TextEditingController();
  final _driverPhoneCtrl = TextEditingController();

  // Pricing
  final _ratePerKmCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _truckTypeOptions = [
    'Closed Container',
    'Open Body',
    'Flatbed Trailer',
    'Refrigerated (Reefer)',
    'High-Side Body',
    'Tanker',
    'Tipper / Dumper',
    'Multi-Axle Trailer',
    'LCV',
    'OPEN_TRUCK',
    'CONTAINER',
    'TIPPER',
    'TANKER',
    'TRAILER',
    'REEFER',
  ];

  final List<String> _bodyTypeOptions = [
    'Open Body',
    'Closed Container',
    'Flatbed',
    'High Side',
    'LCV_OPEN',
    'LCV_CONTAINER',
    'OPEN_FULL_BODY',
    'OPEN_HALF_BODY',
    'OPEN_HIGH_BED',
    'FLATBED',
    'CLOSED_CONTAINER',
    'HIGH_CUBE_CONTAINER',
    'INSULATED_CONTAINER',
    'TIPPER_BOX_BODY',
    'TIPPER_ROCK_BODY',
    'STAINLESS_STEEL_TANKER',
    'ALUMINUM_TANKER',
    'CHEMICAL_TANKER',
    'PETROLEUM_TANKER',
    'MILK_TANKER',
    'WATER_TANKER',
    'FLATBED_TRAILER',
    'LOWBED_TRAILER',
    'HIGHBED_TRAILER',
    'SKELETAL_TRAILER',
    'REFRIGERATED_CONTAINER',
    'COLD_VAN',
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MarketplaceService();
    _vehicleService = widget.vehicleService ?? VehicleService();
    _loadFleetData();
  }

  Future<void> _loadFleetData() async {
    if (mounted) {
      setState(() {
        _isLoadingFleet = true;
        _fleetLoadError = null;
      });
    }
    try {
      final results = await Future.wait([
        _vehicleService.getVehicles(),
        _vehicleService.getDrivers(),
      ]);
      if (mounted) {
        setState(() {
          _myVehicles = results[0] as List<VehicleModel>;
          _myDrivers = results[1] as List<DriverModel>;
          _isLoadingFleet = false;
          _fleetLoadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFleet = false;
          _fleetLoadError = 'Unable to load your fleet vehicles. Please retry.';
        });
      }
    }
  }

  void _onVehicleSelected(int? id) {
    setState(() {
      _selectedVehicleId = id;
      if (id != null) {
        final matches = _myVehicles.where((x) => x.id == id);
        if (matches.isNotEmpty) {
          final v = matches.first;
          _vehicleNumberCtrl.text = v.registrationNumber;
          if (v.truckType != null && v.truckType!.trim().isNotEmpty) {
            final truckType = v.truckType!.trim();
            if (!_truckTypeOptions.contains(truckType)) {
              _truckTypeOptions.add(truckType);
            }
            _truckType = truckType;
          }
          if (v.bodyType != null && v.bodyType!.trim().isNotEmpty) {
            final bodyType = v.bodyType!.trim();
            if (!_bodyTypeOptions.contains(bodyType)) {
              _bodyTypeOptions.add(bodyType);
            }
            _bodyType = bodyType;
          }
          if (v.truckLengthFeet != null) {
            _lengthFeetCtrl.text = v.truckLengthFeet.toString();
          }
          if (v.passingCapacityTons != null) {
            _passingCapacityCtrl.text = v.passingCapacityTons.toString();
            _capacityCtrl.text = v.passingCapacityTons.toString();
          } else if (v.capacityKg > 0) {
            final tons = (v.capacityKg / 1000.0).toStringAsFixed(1);
            _passingCapacityCtrl.text = tons;
            _capacityCtrl.text = tons;
          }
          if (v.currentLocation != null &&
              v.currentLocation!.isNotEmpty &&
              _currentCityCtrl.text.isEmpty) {
            _currentCityCtrl.text = v.currentLocation!;
          }
        }
      }
    });
  }

  void _onDriverSelected(int? id) {
    setState(() {
      _selectedDriverId = id;
      if (id != null) {
        final matches = _myDrivers.where((x) => x.id == id);
        if (matches.isNotEmpty) {
          final d = matches.first;
          _driverNameCtrl.text = d.name;
          _driverPhoneCtrl.text = d.phoneNumber;
        }
      }
    });
  }

  @override
  void dispose() {
    _currentCityCtrl.dispose();
    _currentStateCtrl.dispose();
    _routeToCtrl.dispose();
    _routeToStateCtrl.dispose();
    _returnRouteCtrl.dispose();
    _capacityCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _passingCapacityCtrl.dispose();
    _lengthFeetCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _ratePerKmCtrl.dispose();
    _minPriceCtrl.dispose();
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
          'Post Available Truck',
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
              _buildInfoBanner(),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildVehicleSpecsSection(),
              const SizedBox(height: 16),
              _buildDriverSection(),
              const SizedBox(height: 16),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Publish your truck availability to get instant load matches, verified shipper offers, and guaranteed return trip loads.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final distanceKm = _estimatedDistanceKm;
    return _buildCard(
      title: 'Current Location & Preferred Route',
      icon: Icons.location_on_outlined,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CityAutocompleteField(
                label: 'Current City *',
                hint: 'e.g. Pune',
                controller: _currentCityCtrl,
                prefixIcon: const Icon(
                  Icons.my_location,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                onChanged: (_) => setState(() {
                  _currentLat = null;
                  _currentLng = null;
                }),
                onLocationSelected: (loc) {
                  setState(() {
                    if (loc.state.isNotEmpty) {
                      _currentStateCtrl.text = loc.state;
                    }
                    _currentLat = loc.latitude;
                    _currentLng = loc.longitude;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'State',
                hint: 'e.g. Maharashtra',
                controller: _currentStateCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CityAutocompleteField(
                label: 'Preferred Destination / Route To *',
                hint: 'e.g. Ahmedabad, Delhi',
                controller: _routeToCtrl,
                prefixIcon: const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                onChanged: (_) => setState(() {
                  _routeToLat = null;
                  _routeToLng = null;
                }),
                onLocationSelected: (loc) {
                  setState(() {
                    if (loc.state.isNotEmpty) {
                      _routeToStateCtrl.text = loc.state;
                    }
                    _routeToLat = loc.latitude;
                    _routeToLng = loc.longitude;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'Dest. State',
                hint: 'e.g. Gujarat',
                controller: _routeToStateCtrl,
              ),
            ),
          ],
        ),
        if (distanceKm != null && distanceKm > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.route_outlined,
                  size: 18,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_currentCityCtrl.text.trim()} → ${_routeToCtrl.text.trim()}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    LocationService.formatDistanceKm(distanceKm),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Return / Intermediate Route (Optional)',
          hint: 'e.g. via Surat, Vadodara',
          controller: _returnRouteCtrl,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Available From *',
                date: _availableFrom,
                onTap: () => _pickDate(isFrom: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Available Till',
                date: _availableTo,
                onTap: () => _pickDate(isFrom: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleSpecsSection() {
    return _buildCard(
      title: 'Vehicle & Capacity Details',
      icon: Icons.local_shipping_outlined,
      children: [
        if (_isLoadingFleet) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ] else if (_fleetLoadError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fleetLoadError!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF991B1B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadFleetData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ] else if (_myVehicles.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No vehicles found in your fleet. Please add a vehicle to your fleet before posting availability.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadFleetData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          _buildDropdown<int?>(
            label: 'Select Vehicle from Your Fleet *',
            value: _selectedVehicleId,
            validator: (val) =>
                val == null ? 'Please select a vehicle from your fleet' : null,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Select a vehicle...'),
              ),
              ..._myVehicles.map((v) {
                final display = v.registrationNumber.isNotEmpty
                    ? '${v.registrationNumber} (${v.model.isNotEmpty ? v.model : v.manufacturer})'
                    : 'Vehicle #${v.id}';
                return DropdownMenuItem<int?>(
                  value: v.id,
                  child: Text(display),
                );
              }),
            ],
            onChanged: _onVehicleSelected,
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                label: 'Available Capacity *',
                hint: 'e.g. 18.5',
                controller: _capacityCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Invalid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildDropdown<CapacityUnit>(
                label: 'Unit',
                value: _capacityUnit,
                items: CapacityUnit.values.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _capacityUnit = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                label: 'Vehicle Number',
                hint: 'e.g. MH 12 AB 1234',
                controller: _vehicleNumberCtrl,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'Length (Ft)',
                hint: 'e.g. 32',
                controller: _lengthFeetCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdown<String>(
          label: 'Truck Type',
          value: _truckType,
          items: _truckTypeOptions.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Text(t.replaceAll('_', ' ')),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _truckType = val);
          },
        ),
        const SizedBox(height: 12),
        _buildDropdown<String>(
          label: 'Body Type',
          value: _bodyType,
          items: _bodyTypeOptions.map((b) {
            return DropdownMenuItem(
              value: b,
              child: Text(b.replaceAll('_', ' ')),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _bodyType = val);
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Total Passing Capacity (Tons)',
          hint: 'e.g. 25.0',
          controller: _passingCapacityCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildDriverSection() {
    return _buildCard(
      title: 'Driver Contact (Optional)',
      icon: Icons.person_outline,
      children: [
        if (_myDrivers.isNotEmpty) ...[
          _buildDropdown<int?>(
            label: 'Select from Your Drivers (Autofill)',
            value: _selectedDriverId,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Manual Entry / Unassigned'),
              ),
              ..._myDrivers.map((d) {
                return DropdownMenuItem<int?>(
                  value: d.id,
                  child: Text('${d.name} (${d.phoneNumber})'),
                );
              }),
            ],
            onChanged: _onDriverSelected,
          ),
          const SizedBox(height: 12),
        ],
        _buildTextField(
          label: 'Driver Name',
          hint: 'e.g. Rajesh Patil',
          controller: _driverNameCtrl,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Driver Mobile Number',
          hint: 'e.g. 9876543210',
          controller: _driverPhoneCtrl,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildCard(
      title: 'Expected Freight & Rates',
      icon: Icons.currency_rupee,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Rate / KM (₹)',
                hint: 'e.g. 45',
                controller: _ratePerKmCtrl,
                keyboardType: TextInputType.number,
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'Minimum Freight (₹)',
                hint: 'e.g. 15000',
                controller: _minPriceCtrl,
                keyboardType: TextInputType.number,
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isSubmitting ? null : _submitPost,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Publish Truck Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    final seenValues = <T?>{};
    final uniqueItems = <DropdownMenuItem<T>>[];
    for (final item in items) {
      if (seenValues.add(item.value)) {
        uniqueItems.add(item);
      }
    }
    final hasMatchingValue = uniqueItems.any((item) => item.value == value);
    final T? effectiveValue = hasMatchingValue
        ? value
        : (uniqueItems.isNotEmpty ? uniqueItems.first.value : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          key: ValueKey('$label:$effectiveValue'),
          initialValue: effectiveValue,
          items: uniqueItems,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final text = date != null
        ? DateFormat('dd MMM yyyy').format(date)
        : 'Select date';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: date != null
                      ? AppColors.primary
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                      fontWeight: date != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_availableFrom ?? now)
          : (_availableTo ?? _availableFrom ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _availableFrom = picked;
          if (_availableTo != null && _availableTo!.isBefore(picked)) {
            _availableTo = picked;
          }
        } else {
          _availableTo = picked;
        }
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a vehicle from your fleet before publishing.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_availableFrom == null) {
      Get.snackbar(
        'Required Field',
        'Please select an Available From date',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final availFromStr = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
      ).format(_availableFrom!);
      final availToStr = _availableTo != null
          ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_availableTo!)
          : null;

      final truck = TruckPostModel(
        vehicleId: _selectedVehicleId,
        driverId: _selectedDriverId,
        currentCity: _currentCityCtrl.text.trim(),
        currentState: _currentStateCtrl.text.trim().isNotEmpty
            ? _currentStateCtrl.text.trim()
            : null,
        currentLat: _currentLat,
        currentLng: _currentLng,
        routeTo: _routeToCtrl.text.trim(),
        routeToState: _routeToStateCtrl.text.trim().isNotEmpty
            ? _routeToStateCtrl.text.trim()
            : null,
        routeToLat: _routeToLat,
        routeToLng: _routeToLng,
        routeDistanceKm: _estimatedDistanceKm,
        returnRoute: _returnRouteCtrl.text.trim().isNotEmpty
            ? _returnRouteCtrl.text.trim()
            : null,
        availableFrom: availFromStr,
        availableTo: availToStr,
        availableCapacity: double.tryParse(_capacityCtrl.text.trim()),
        capacityUnit: _capacityUnit,
        truckStatus: 'EMPTY_STANDING',
        vehicleNumber: _vehicleNumberCtrl.text.trim().isNotEmpty
            ? _vehicleNumberCtrl.text.trim()
            : null,
        truckType: _truckType,
        bodyType: _bodyType,
        truckLengthFeet: double.tryParse(_lengthFeetCtrl.text.trim()),
        passingCapacityTons: double.tryParse(_passingCapacityCtrl.text.trim()),
        driverName: _driverNameCtrl.text.trim().isNotEmpty
            ? _driverNameCtrl.text.trim()
            : null,
        driverPhone: _driverPhoneCtrl.text.trim().isNotEmpty
            ? _driverPhoneCtrl.text.trim()
            : null,
        pricePerKm: double.tryParse(_ratePerKmCtrl.text.trim()),
        minimumPrice: double.tryParse(_minPriceCtrl.text.trim()),
      );

      final success = await _service.createTruckPost(truck);

      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Your truck has been posted to the marketplace!',
          backgroundColor: const Color(0xFF059669),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not post truck. Please check details and try again.',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
