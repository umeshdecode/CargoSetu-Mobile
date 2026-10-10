import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_management_controller.dart';
import '../models/vehicle_assignment_model.dart';

class VehicleManagementHubScreen extends StatelessWidget {
  const VehicleManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleManagementController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logistics Control',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Vehicle & Driver Management',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            tooltip: 'Refresh',
            onPressed: () => controller.loadDashboardData(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () => controller.loadDashboardData(),
        child: Obx(() {
          if (controller.isLoading.value && controller.allAssignments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ─── MODULE CARDS (Vehicles, Drivers, Assignments) ───
              _buildModulesSection(controller),
              const SizedBox(height: 24),

              // ─── VEHICLE ASSIGNMENTS SECTION ───
              _buildAssignmentsHeader(context),
              const SizedBox(height: 12),

              // Search & Filter
              _buildSearchAndFilters(controller),
              const SizedBox(height: 14),

              // Assignments List
              _buildAssignmentsList(controller),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.assignments);
          if (result == true) {
            controller.loadDashboardData();
          }
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_link, color: Colors.white),
        label: const Text(
          'Assign Driver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildModulesSection(VehicleManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.apps_rounded, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              'FLEET MODULES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Vehicles Module Card
            Expanded(
              child: _buildModuleCard(
                title: 'Vehicles',
                subtitle: 'Manage fleet',
                count: controller.vehicleCount.value,
                icon: Icons.local_shipping_outlined,
                accentColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () async {
                  await Get.toNamed(AppRoutes.vehicles);
                  controller.loadDashboardData();
                },
              ),
            ),
            const SizedBox(width: 10),

            // Drivers Module Card
            Expanded(
              child: _buildModuleCard(
                title: 'Drivers',
                subtitle: 'Manage staff',
                count: controller.driverCount.value,
                icon: Icons.person_outline,
                accentColor: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFF7ED),
                onTap: () async {
                  await Get.toNamed(AppRoutes.drivers);
                  controller.loadDashboardData();
                },
              ),
            ),
            const SizedBox(width: 10),

            // Assignments Module Card
            Expanded(
              child: _buildModuleCard(
                title: 'Assign',
                subtitle: 'Pair vehicle',
                count: controller.activeAssignmentCount.value,
                icon: Icons.link_rounded,
                accentColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFF0FDF4),
                onTap: () async {
                  final res = await Get.toNamed(AppRoutes.assignments);
                  if (res == true) controller.loadDashboardData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsHeader(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, size: 20, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text(
              'Vehicle Assignments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(VehicleManagementController controller) {
    return Column(
      children: [
        // Search Input
        TextField(
          onChanged: (val) => controller.searchText.value = val,
          decoration: InputDecoration(
            hintText: 'Search driver, reg number, or ID...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
            suffixIcon: controller.searchText.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => controller.searchText.value = '',
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Active', 'Inactive'].map((filter) {
              final isSelected = controller.statusFilter.value == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                  ),
                  onSelected: (_) => controller.statusFilter.value = filter,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsList(VehicleManagementController controller) {
    final list = controller.filteredAssignments;

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.link_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No vehicle assignments found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Assign drivers to vehicles to track your logistics operations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((item) => _buildAssignmentCard(item, controller)).toList(),
    );
  }

  Widget _buildAssignmentCard(
    VehicleAssignmentModel item,
    VehicleManagementController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.active
              ? AppColors.primaryBlue.withValues(alpha: 0.25)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Status Badge & Assigned date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.active
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3.5,
                      backgroundColor: item.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.active
                            ? const Color(0xFF15803D)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.assignedAt != null)
                Text(
                  _formatDate(item.assignedAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver & Vehicle Pairing Row
          Row(
            children: [
              // Driver Info Block
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFFFF7ED),
                      child: const Icon(Icons.person, color: Color(0xFFF97316), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.driverName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Driver ID: ${item.driverId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: item.active ? AppColors.primaryBlue : Colors.grey.shade400,
                ),
              ),

              // Vehicle Info Block
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: const Icon(Icons.local_shipping, color: Color(0xFF2563EB), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.registrationNumber.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Vehicle ID: ${item.vehicleId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Action: Unassign button if active
          if (item.active && item.id != null) ...[
            const Divider(height: 20, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmUnassign(item, controller),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: const Icon(Icons.link_off_rounded, size: 16),
                  label: const Text(
                    'Unassign',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmUnassign(
    VehicleAssignmentModel item,
    VehicleManagementController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link_off_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Unassign Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to unassign ${item.driverName} from vehicle ${item.registrationNumber}?',
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
              if (item.id != null) {
                controller.unassign(item.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoString;
    }
  }
}
