import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marketplace_enums.dart';

/// Clean multi-attribute filter sheet for finding freight loads and trucks.
class MarketplaceFilterSheet extends StatefulWidget {
  final String? initialOrigin;
  final String? initialDestination;
  final CargoType? initialCargoType;
  final Function(String? origin, String? destination, CargoType? cargoType) onApply;

  const MarketplaceFilterSheet({
    super.key,
    this.initialOrigin,
    this.initialDestination,
    this.initialCargoType,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    String? origin,
    String? destination,
    CargoType? cargoType,
    required Function(String? origin, String? destination, CargoType? cargoType) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MarketplaceFilterSheet(
        initialOrigin: origin,
        initialDestination: destination,
        initialCargoType: cargoType,
        onApply: onApply,
      ),
    );
  }

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  late final TextEditingController _originCtrl;
  late final TextEditingController _destCtrl;
  CargoType? _selectedCargoType;

  @override
  void initState() {
    super.initState();
    _originCtrl = TextEditingController(text: widget.initialOrigin ?? '');
    _destCtrl = TextEditingController(text: widget.initialDestination ?? '');
    _selectedCargoType = widget.initialCargoType;
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Listings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _originCtrl.clear();
                      _destCtrl.clear();
                      _selectedCargoType = null;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Origin City
            const Text(
              'From (Origin City)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _originCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                hintText: 'e.g. Mumbai, Delhi, Ahmedabad',
                hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Destination City
            const Text(
              'To (Destination City)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _destCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on, size: 12, color: Color(0xFFEF4444)),
                hintText: 'e.g. Pune, Bangalore, Kolkata',
                hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cargo Type Selection
            const Text(
              'Commodity / Cargo Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CargoType.values.take(8).map((type) {
                final isSelected = _selectedCargoType == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCargoType = val ? type : null;
                    });
                  },
                  selectedColor: AppColors.primaryBlueLight,
                  backgroundColor: const Color(0xFFF8FAFC),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryBlue : const Color(0xFF475569),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  widget.onApply(
                    _originCtrl.text.trim().isEmpty ? null : _originCtrl.text.trim(),
                    _destCtrl.text.trim().isEmpty ? null : _destCtrl.text.trim(),
                    _selectedCargoType,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
