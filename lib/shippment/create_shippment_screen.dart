import 'package:cargo_setu/shippment/shipment_price_estimation_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  int _currentStep = 0;

  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _weightController = TextEditingController();
  final _materialController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("Create Shipment"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),

      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        controlsBuilder: _controlsBuilder,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          _pickupDropStep(),
          _loadDetailsStep(),
          _vehicleScheduleStep(),
          _reviewStep(),
        ],
      ),
    );
  }

  // ===================== STEP 1 =====================
  Step _pickupDropStep() {
    return Step(
      title: const Text("Pickup & Drop"),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          _inputField(
            controller: _pickupController,
            label: "Pickup Location",
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _dropController,
            label: "Drop Location",
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }

  // ===================== STEP 2 =====================
  Step _loadDetailsStep() {
    return Step(
      title: const Text("Load Details"),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          _inputField(
            controller: _materialController,
            label: "Material Type",
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _weightController,
            label: "Weight (kg)",
            icon: Icons.scale_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ===================== STEP 3 =====================
  Step _vehicleScheduleStep() {
    return Step(
      title: const Text("Vehicle & Schedule"),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          _inputField(
            label: "Vehicle Type",
            icon: Icons.local_shipping_outlined,
            hint: "Truck / Tempo / Trailer",
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _dateController,
            label: "Pickup Date",
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  // ===================== STEP 4 =====================
  Step _reviewStep() {
    return Step(
      title: const Text("Review & Confirm"),
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reviewTile("Pickup", _pickupController.text),
          _reviewTile("Drop", _dropController.text),
          _reviewTile("Material", _materialController.text),
          _reviewTile("Weight", _weightController.text),
          _reviewTile("Date", _dateController.text),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colorPrimaryTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // 🔥 API call later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Shipment Created (UI only)")),
                );
              },
              child: const Text(
                "CONFIRM SHIPMENT",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== INPUT FIELD =====================
  Widget _inputField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.colorWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ===================== REVIEW TILE =====================
  Widget _reviewTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.colorGrey,
                fontSize: AppTheme.small,
              ),
            ),
          ),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ===================== CONTROLS =====================
  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Row(
      children: [
        if (_currentStep != 0)
          TextButton(
            onPressed: details.onStepCancel,
            child: const Text("Back"),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: details.onStepContinue,
          child: Text(_currentStep == 3 ? "Finish" : "Next"),
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      // 👉 Navigate to Price Estimation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PriceEstimationScreen(
          ),
        ),
      );
    }
  }


  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // ===================== DATE PICKER =====================
  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      _dateController.text =
      "${date.day}/${date.month}/${date.year}";
    }
  }
}
