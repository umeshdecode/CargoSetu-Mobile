import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marketplace_enums.dart';
import 'city_autocomplete_field.dart';

/// Clean multi-attribute filter sheet for finding freight loads and trucks.
/// Supports route autocomplete, distance calculation, and 200 km route-corridor truck search.
class MarketplaceFilterSheet extends StatefulWidget {
  final String? initialOrigin;
  final String? initialDestination;
  final double? initialOriginLat;
  final double? initialOriginLng;
  final double? initialDestLat;
  final double? initialDestLng;
  final CargoType? initialCargoType;
  final bool isTruckSearch;
  final Function(
    String? origin,
    String? destination,
    CargoType? cargoType, {
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    double? radiusKm,
  })
  onApply;

  const MarketplaceFilterSheet({
    super.key,
    this.initialOrigin,
    this.initialDestination,
    this.initialOriginLat,
    this.initialOriginLng,
    this.initialDestLat,
    this.initialDestLng,
    this.initialCargoType,
    this.isTruckSearch = false,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    String? origin,
    String? destination,
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    CargoType? cargoType,
    bool isTruckSearch = false,
    required Function(
      String? origin,
      String? destination,
      CargoType? cargoType, {
      double? originLat,
      double? originLng,
      double? destLat,
      double? destLng,
      double? radiusKm,
    })
    onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MarketplaceFilterSheet(
        initialOrigin: origin,
        initialDestination: destination,
        initialOriginLat: originLat,
        initialOriginLng: originLng,
        initialDestLat: destLat,
        initialDestLng: destLng,
        initialCargoType: cargoType,
        isTruckSearch: isTruckSearch,
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
  double? _originLat;
  double? _originLng;
  double? _destLat;
  double? _destLng;
  CargoType? _selectedCargoType;

  double? get _estimatedDistanceKm => LocationService.estimateCityDistanceKm(
    originLat: _originLat,
    originLng: _originLng,
    originCity: _originCtrl.text,
    destLat: _destLat,
    destLng: _destLng,
    destCity: _destCtrl.text,
  );

  @override
  void initState() {
    super.initState();
    _originCtrl = TextEditingController(text: widget.initialOrigin ?? '');
    _destCtrl = TextEditingController(text: widget.initialDestination ?? '');
    _originLat = widget.initialOriginLat;
    _originLng = widget.initialOriginLng;
    _destLat = widget.initialDestLat;
    _destLng = widget.initialDestLng;
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
    final distanceKm = _estimatedDistanceKm;

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
                Text(
                  widget.isTruckSearch
                      ? 'Search Trucks on Route'
                      : 'Filter Listings',
                  style: const TextStyle(
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
                      _originLat = null;
                      _originLng = null;
                      _destLat = null;
                      _destLng = null;
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

            // Origin City Autocomplete
            CityAutocompleteField(
              label: 'From (Origin City)',
              hint: 'e.g. Mumbai, Delhi, Ahmedabad',
              controller: _originCtrl,
              prefixIcon: const Icon(
                Icons.circle,
                size: 10,
                color: Color(0xFF10B981),
              ),
              onChanged: (_) => setState(() {
                _originLat = null;
                _originLng = null;
              }),
              onLocationSelected: (loc) {
                setState(() {
                  _originLat = loc.latitude;
                  _originLng = loc.longitude;
                });
              },
            ),

            const SizedBox(height: 14),

            // Destination City Autocomplete
            CityAutocompleteField(
              label: 'To (Destination City)',
              hint: 'e.g. Pune, Bangalore, Kolkata',
              controller: _destCtrl,
              prefixIcon: const Icon(
                Icons.location_on,
                size: 12,
                color: Color(0xFFEF4444),
              ),
              onChanged: (_) => setState(() {
                _destLat = null;
                _destLng = null;
              }),
              onLocationSelected: (loc) {
                setState(() {
                  _destLat = loc.latitude;
                  _destLng = loc.longitude;
                });
              },
            ),

            if (distanceKm != null && distanceKm > 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_originCtrl.text.trim()} → ${_destCtrl.text.trim()}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
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
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.radar,
                          size: 14,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Searching trucks within 200 km of route corridor',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (_originCtrl.text.trim().isNotEmpty ||
                _destCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.radar, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    'Matches trucks within 200 km radius',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ],

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
                    color: isSelected
                        ? AppColors.primaryBlue
                        : const Color(0xFF475569),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : const Color(0xFFE2E8F0),
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
                  final orig = _originCtrl.text.trim();
                  final dest = _destCtrl.text.trim();
                  final (double, double)? oCoords =
                      (_originLat != null && _originLng != null)
                      ? (_originLat!, _originLng!)
                      : LocationService.lookupCityCoordinates(orig);
                  final (double, double)? dCoords =
                      (_destLat != null && _destLng != null)
                      ? (_destLat!, _destLng!)
                      : LocationService.lookupCityCoordinates(dest);
                  Get.back();
                  widget.onApply(
                    orig.isEmpty ? null : orig,
                    dest.isEmpty ? null : dest,
                    _selectedCargoType,
                    originLat: oCoords?.$1,
                    originLng: oCoords?.$2,
                    destLat: dCoords?.$1,
                    destLng: dCoords?.$2,
                    radiusKm: 200.0,
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
