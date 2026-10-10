import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_controller.dart';
import '../models/driver_model.dart';
import 'driver_form_screen.dart';

class DriversListScreen extends StatelessWidget {
  const DriversListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverController());

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
          'Fleet Drivers',
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
            onPressed: () => controller.loadDrivers(),
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
                    hintText: 'Search driver by name, phone, license...',
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
                          'ACTIVE',
                          'INACTIVE',
                          'SUSPENDED',
                        ].map((filter) {
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

          // ─── Drivers List ───────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.drivers.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }

              final list = controller.filteredDrivers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No drivers found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try adjusting filters or add a new driver.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () => controller.loadDrivers(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _buildDriverCard(list[i], controller),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const DriverFormScreen()),
        backgroundColor: const Color(0xFFF97316),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          'Add Driver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDriverCard(DriverModel driver, DriverController controller) {
    final statusColor = _getStatusColor(driver.status);

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
          onTap: () => Get.to(() => DriverFormScreen(driver: driver)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, Status & Menu
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFFF7ED),
                      child: Text(
                        driver.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  driver.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (driver.experienceYears != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${driver.experienceYears} yrs exp',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions Menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      onSelected: (val) {
                        if (val == 'edit') {
                          Get.to(() => DriverFormScreen(driver: driver));
                        } else if (val == 'delete') {
                          _confirmDelete(driver, controller);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text('Edit Driver'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                              SizedBox(width: 8),
                              Text('Delete Driver', style: TextStyle(color: Color(0xFFDC2626))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Box: Phone, Email, License
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            driver.phoneNumber,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const Spacer(),
                          const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            driver.licenseNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (driver.email.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                driver.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // License Expiry
                if (driver.licenseExpiryDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 13,
                        color: _isExpired(driver.licenseExpiryDate!)
                            ? const Color(0xFFDC2626)
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'License Expiry: ${_formatDate(driver.licenseExpiryDate!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isExpired(driver.licenseExpiryDate!)
                              ? const Color(0xFFDC2626)
                              : AppColors.textSecondary,
                          fontWeight: _isExpired(driver.licenseExpiryDate!)
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF16A34A);
      case 'INACTIVE':
        return const Color(0xFF64748B);
      case 'SUSPENDED':
        return const Color(0xFFDC2626);
      default:
        return AppColors.textSecondary;
    }
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

  void _confirmDelete(DriverModel driver, DriverController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete driver "${driver.name}"? This action cannot be undone.',
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
              if (driver.id != null) {
                controller.deleteDriver(driver.id!);
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
