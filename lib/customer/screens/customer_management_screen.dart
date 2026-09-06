import 'package:cargo_setu/customer/controllers/customer_management_controller.dart';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/customer/screens/create_customer_screen.dart';
import 'package:cargo_setu/customer/screens/edit_customer_screen.dart';
import 'package:cargo_setu/customer/widgets/quotation_generation_dialog.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerManagementController ctrl = Get.put(CustomerManagementController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Management',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Obx(() => Text(
                  '${ctrl.totalCount} registered customers',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => ctrl.fetchCustomers(refresh: true),
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.people, color: AppColors.onPrimary, size: 18),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Create Customer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await Get.to(() => CreateCustomerScreen());
          ctrl.fetchCustomers(refresh: true);
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ctrl.fetchCustomers(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // KPI Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildKpiRow(ctrl),
              ),
            ),

            // Search and Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildSearchBar(ctrl),
                    const SizedBox(height: 10),
                    _buildFilterChips(ctrl),
                  ],
                ),
              ),
            ),

            // Customer List
            Obx(() {
              if (ctrl.isLoading.value && ctrl.allCustomers.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (ctrl.loadError.isNotEmpty && ctrl.allCustomers.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          ctrl.loadError.value,
                          style: const TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ctrl.fetchCustomers(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }

              final customers = ctrl.filteredCustomers;

              if (customers.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_search_outlined,
                              size: 48,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Customers Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ctrl.searchQuery.isNotEmpty
                                ? 'No results match "${ctrl.searchQuery.value}"'
                                : 'Get started by creating your first customer.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Get.to(() => CreateCustomerScreen());
                              ctrl.fetchCustomers(refresh: true);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Customer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final customer = customers[index];
                      return _buildCustomerCard(context, customer, ctrl);
                    },
                    childCount: customers.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(CustomerManagementController ctrl) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Total',
                count: '${ctrl.totalCount}',
                color: AppColors.primary,
                bgColor: AppColors.surfaceContainerLowest,
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildKpiCard(
                title: 'In Progress',
                count: '${ctrl.activeShiftCount}',
                color: const Color(0xFFC67C3E),
                bgColor: const Color(0xFFFFF7ED),
                icon: Icons.local_shipping_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildKpiCard(
                title: 'Completed',
                count: '${ctrl.completedShiftCount}',
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFF0FDF4),
                icon: Icons.task_alt_outlined,
              ),
            ),
          ],
        ));
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(CustomerManagementController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => ctrl.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, city or ID...',
          hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondary, size: 20),
          suffixIcon: Obx(() => ctrl.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ctrl.searchQuery.value = '',
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips(CustomerManagementController ctrl) {
    final filters = ['All', 'In Progress', 'Completed'];
    return Obx(() => Row(
          children: filters.map((f) {
            final isSelected = ctrl.selectedFilter.value == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(f),
                selected: isSelected,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerLow,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (selected) {
                  if (selected) ctrl.selectedFilter.value = f;
                },
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildCustomerCard(BuildContext context,
      CustomerModel customer,
      CustomerManagementController ctrl,) {
    final isCompleted = !customer.shiftActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Open edit screen directly on tap
          final updated = await Get.to(() => EditCustomerScreen(customer: customer));
          if (updated == true) {
            ctrl.fetchCustomers(refresh: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name + Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      customer.firstName.isNotEmpty
                          ? customer.firstName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (customer.uuid != null && customer.uuid!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  customer.uuid!.length > 12
                                      ? '${customer.uuid!.substring(0, 12)}...'
                                      : customer.uuid!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFE6F4EA) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'Completed' : 'In Progress',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 12),

              // Route & Shifting details container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer.routeSummary,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (customer.shiftingType != null ||
                        (customer.shiftings.isNotEmpty && customer.shiftings.first.shiftingType.isNotEmpty))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.surfaceContainerHigh),
                        ),
                        child: Text(
                          customer.shiftings.isNotEmpty
                              ? customer.shiftings.first.shiftingType.toUpperCase()
                              : (customer.shiftingType ?? '').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Contact Info (Phone & Email)
              Row(
                children: [
                  if (customer.mobileNo.isNotEmpty) ...[
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      customer.mobileNo,
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (customer.email.isNotEmpty) ...[
                    const Icon(Icons.email_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customer.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Financial Breakdown Strip (from HTML design)
              Builder(builder: (context) {
                final charges = customer.shiftings.isNotEmpty ? customer.shiftings.first.charges : null;
                if (charges != null) {
                  double sub = charges.transportCharge +
                      charges.packingCharge +
                      charges.loadingCharge +
                      charges.unloadingCharge +
                      charges.unpackingCharge +
                      charges.carTransportCharge +
                      charges.riskInsureCharge +
                      charges.storageCharge +
                      charges.statisticalCharge +
                      charges.serviceCharge;
                  double gst = (sub * charges.gstRate) / 100;
                  double total = sub + gst;
                  double adv = charges.advancePaid;
                  double due = total - adv;

                  if (total > 0 || adv > 0) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Quote', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              Text('₹${total > 0 ? total.toStringAsFixed(0) : "—"}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Paid (Adv)', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              Text('₹${adv > 0 ? adv.toStringAsFixed(0) : "0"}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Balance Due', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626))),
                              Text('₹${due > 0 ? due.toStringAsFixed(0) : "0"}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              }),

              // Action Buttons Row
              Row(
                children: [
                  // Update / Manage Customer Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final updated = await Get.to(() => EditCustomerScreen(customer: customer));
                        if (updated == true) {
                          ctrl.fetchCustomers(refresh: true);
                        }
                      },
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text(
                        'Manage / Update',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quick Copy Phone / Call button
                  if (customer.mobileNo.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone, color: Color(0xFF16A34A), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF0FDF4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      tooltip: 'Copy Phone',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: customer.mobileNo));
                        Get.snackbar(
                          'Copied',
                          'Phone number ${customer.mobileNo} copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                    ),

                  // More Options menu (Delete, Documents, etc.)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (action) {
                      if (action == 'delete') {
                        ctrl.confirmDeleteCustomer(context, customer);
                      } else if (action == 'quotation') {
                        QuotationGenerationDialog.show(context, customer: customer);
                      } else if (action == 'invoice') {
                        Get.snackbar('Invoice', 'Generating invoice for ${customer.fullName}...');
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'quotation',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, size: 18, color: AppColors.secondary),
                            SizedBox(width: 8),
                            Text('Generate Quotation'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'invoice',
                        child: Row(
                          children: [
                            Icon(Icons.request_quote, size: 18, color: AppColors.secondary),
                            SizedBox(width: 8),
                            Text('Generate Invoice'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                            SizedBox(width: 8),
                            Text('Delete Customer', style: TextStyle(color: Color(0xFFDC2626))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
