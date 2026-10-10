import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assignment_controller.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';

class AssignDriverScreen extends StatefulWidget {
  const AssignDriverScreen({super.key});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> with SingleTickerProviderStateMixin {
  late final AssignmentController controller;
  late final TabController _tabController;
  final TextEditingController _driverSearchController = TextEditingController();
  final TextEditingController _vehicleSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AssignmentController>()
        ? Get.find<AssignmentController>()
        : Get.put(AssignmentController());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _driverSearchController.dispose();
    _vehicleSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Driver Assignment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            tooltip: 'Refresh',
            onPressed: () => controller.loadAssignmentData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        return Column(
          children: [
            // Top Selected Assignment Card
            _buildSelectedCard(),

            // Tab bar for Drivers & Vehicles
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 6),
                        Text('Drivers (${controller.filteredDrivers.length})'),
                        if (controller.selectedDriver.value != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_shipping, size: 18),
                        const SizedBox(width: 6),
                        Text('Vehicles (${controller.filteredVehicles.length})'),
                        if (controller.selectedVehicle.value != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDriversTab(),
                  _buildVehiclesTab(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSelectedCard() {
    final driver = controller.selectedDriver.value;
    final vehicle = controller.selectedVehicle.value;
    final canAssign = controller.canAssign;
    final assigning = controller.isAssigning.value;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canAssign ? AppColors.primaryBlue.withOpacity(0.5) : AppColors.border,
          width: canAssign ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: canAssign
                ? AppColors.primaryBlue.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selected Assignment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              if (driver != null || vehicle != null)
                GestureDetector(
                  onTap: () {
                    controller.selectedDriver.value = null;
                    controller.selectedVehicle.value = null;
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver & Vehicle Pairing Row
          Row(
            children: [
              // Driver Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: driver != null
                        ? AppColors.primaryBlue.withOpacity(0.06)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: driver != null
                          ? AppColors.primaryBlue.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: driver != null ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
                        child: Text(
                          driver?.initials ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DRIVER',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              driver?.name ?? 'Select driver',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: driver != null ? AppColors.textPrimary : AppColors.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (driver != null)
                              Text(
                                driver.phoneNumber,
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: canAssign ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),

              // Vehicle Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: vehicle != null
                        ? const Color(0xFF16A34A).withOpacity(0.06)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: vehicle != null
                          ? const Color(0xFF16A34A).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: vehicle != null ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        child: Icon(
                          vehicle?.vehicleIcon ?? Icons.local_shipping,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VEHICLE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              vehicle?.registrationNumber ?? 'Select vehicle',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: vehicle != null ? AppColors.textPrimary : AppColors.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (vehicle != null)
                              Text(
                                '${vehicle.manufacturer} ${vehicle.model}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Assign CTA
          ElevatedButton.icon(
            onPressed: canAssign && !assigning
                ? () async {
                    final success = await controller.assignDriverToVehicle();
                    if (success) {
                      Get.back(result: true);
                      AppSnackbar.success('Driver assigned to vehicle successfully');
                    }
                  }
                : null,
            icon: assigning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.link, size: 18),
            label: Text(
              assigning
                  ? 'Assigning...'
                  : canAssign
                      ? 'Assign Driver to Vehicle'
                      : driver == null
                          ? 'Select a Driver below'
                          : 'Select a Vehicle below',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: canAssign ? 1 : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab() {
    final list = controller.filteredDrivers;

    return Column(
      children: [
        // Driver Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: _driverSearchController,
            onChanged: (v) => controller.driverSearch.value = v,
            decoration: InputDecoration(
              hintText: 'Search driver by name, phone, license...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              suffixIcon: controller.driverSearch.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _driverSearchController.clear();
                        controller.driverSearch.value = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
        ),

        Expanded(
          child: list.isEmpty
              ? _buildEmptyState('No drivers found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final d = list[index];
                    final isSelected = controller.selectedDriver.value?.id == d.id;

                    return _buildDriverSelectCard(d, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDriverSelectCard(DriverModel d, bool isSelected) {
    final statusColor = d.status.toUpperCase() == 'ACTIVE'
        ? const Color(0xFF16A34A)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        controller.selectDriver(d);
        if (controller.selectedDriver.value != null && controller.selectedVehicle.value == null) {
          // Switch tab to vehicles to guide user
          _tabController.animateTo(1);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Driver Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Text(
                d.initials,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        d.phoneNumber,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.badge_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          d.licenseNumber,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesTab() {
    final list = controller.filteredVehicles;

    return Column(
      children: [
        // Vehicle Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: _vehicleSearchController,
            onChanged: (v) => controller.vehicleSearch.value = v,
            decoration: InputDecoration(
              hintText: 'Search vehicle by reg no, model, type...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              suffixIcon: controller.vehicleSearch.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _vehicleSearchController.clear();
                        controller.vehicleSearch.value = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
        ),

        Expanded(
          child: list.isEmpty
              ? _buildEmptyState('No vehicles found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final v = list[index];
                    final isSelected = controller.selectedVehicle.value?.id == v.id;

                    return _buildVehicleSelectCard(v, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelectCard(VehicleModel v, bool isSelected) {
    final statusColor = v.statusColor;

    return InkWell(
      onTap: () => controller.selectVehicle(v),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Vehicle Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                v.vehicleIcon,
                size: 22,
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          v.registrationNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${v.manufacturer} ${v.model}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text(
                        v.formattedCapacity,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text(
                        v.fuelType,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
