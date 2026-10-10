import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle_model.dart';
import 'vehicle_form_screen.dart';

class VehiclesListScreen extends StatelessWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Fleet Vehicles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            tooltip: 'Refresh',
            onPressed: () => controller.loadVehicles(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ─── Search & Status Filters ────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => controller.searchText.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search by registration, model, type...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
                    suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => controller.searchText.value = '',
                          )
                        : const SizedBox.shrink()),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'ALL',
                          'AVAILABLE',
                          'ON_TRIP',
                          'MAINTENANCE',
                          'OUT_OF_SERVICE',
                        ].map((filter) {
                          final isSelected = controller.statusFilter.value == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_formatStatus(filter)),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor: AppColors.bgLight,
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryBlue : AppColors.border,
                              ),
                              onSelected: (_) => controller.statusFilter.value = filter,
                            ),
                          );
                        }).toList(),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ─── Vehicle List ───────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.vehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }

              final list = controller.filteredVehicles;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No vehicles found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try changing filters or add a new vehicle.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () => controller.loadVehicles(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _buildVehicleCard(list[i], controller),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const VehicleFormScreen()),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Vehicle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle, VehicleController controller) {
    final statusColor = _getStatusColor(vehicle.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.to(() => VehicleFormScreen(vehicle: vehicle)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Registration, Status & Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Registration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        vehicle.registrationNumber.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatStatus(vehicle.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),

                        // Action Menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          onSelected: (val) {
                            if (val == 'edit') {
                              Get.to(() => VehicleFormScreen(vehicle: vehicle));
                            } else if (val == 'delete') {
                              _confirmDelete(vehicle, controller);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                                  SizedBox(width: 8),
                                  Text('Edit Vehicle'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                  SizedBox(width: 8),
                                  Text('Delete Vehicle', style: TextStyle(color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Make & Model
                Text(
                  vehicle.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (vehicle.bodyType != null && vehicle.bodyType!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Body: ${vehicle.bodyType}',
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ],
                if (vehicle.loadSpecsSummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      vehicle.loadSpecsSummary,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Specs Grid: Capacity, Fuel, Mileage, Location
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Capacity
                      Expanded(
                        child: _buildSpecCol(
                          icon: Icons.scale_outlined,
                          label: 'Capacity',
                          value: vehicle.formattedCapacity,
                        ),
                      ),
                      // Fuel
                      Expanded(
                        child: _buildSpecCol(
                          icon: Icons.local_gas_station_outlined,
                          label: 'Fuel',
                          value: vehicle.fuelType,
                        ),
                      ),
                      // Mileage
                      Expanded(
                        child: _buildSpecCol(
                          icon: Icons.speed_outlined,
                          label: 'Mileage',
                          value: vehicle.mileage != null ? '${vehicle.mileage} km/l' : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ),

                if (vehicle.currentLocation != null && vehicle.currentLocation!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.currentLocation!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Expiry dates summary (Insurance & Pollution)
                if (vehicle.insuranceExpiryDate != null || vehicle.pollutionExpiryDate != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (vehicle.insuranceExpiryDate != null)
                        Text(
                          'Insurance: ${_formatDate(vehicle.insuranceExpiryDate!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isExpired(vehicle.insuranceExpiryDate!)
                                ? const Color(0xFFDC2626)
                                : AppColors.textSecondary,
                            fontWeight: _isExpired(vehicle.insuranceExpiryDate!)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      if (vehicle.pollutionExpiryDate != null)
                        Text(
                          'PUC: ${_formatDate(vehicle.pollutionExpiryDate!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isExpired(vehicle.pollutionExpiryDate!)
                                ? const Color(0xFFDC2626)
                                : AppColors.textSecondary,
                            fontWeight: _isExpired(vehicle.pollutionExpiryDate!)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecCol({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return const Color(0xFF16A34A);
      case 'ON_TRIP':
        return const Color(0xFF2563EB);
      case 'MAINTENANCE':
        return const Color(0xFFD97706);
      case 'OUT_OF_SERVICE':
        return const Color(0xFF64748B);
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ');
  }

  bool _isExpired(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  void _confirmDelete(VehicleModel vehicle, VehicleController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete vehicle "${vehicle.registrationNumber}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (vehicle.id != null) {
                controller.deleteVehicle(vehicle.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
