import 'package:cargo_setu/customer/controllers/edit_customer_controller.dart';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditCustomerScreen extends StatelessWidget {
  final CustomerModel customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final EditCustomerController ctrl = Get.put(
      EditCustomerController(customer),
      tag: customer.uuid ?? customer.customerId?.toString() ?? 'edit',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Update Customer',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
            onPressed: () => ctrl.loadFullCustomerDetails(),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110, left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(ctrl),
                  const SizedBox(height: 14),
                  _buildPersonalDetailsCard(ctrl),
                  const SizedBox(height: 16),
                  _buildShiftingTabBar(ctrl),
                  const SizedBox(height: 12),
                  _buildShiftStatusBanner(ctrl),
                  const SizedBox(height: 16),
                  _buildShiftingDetailsCard(context, ctrl),
                  const SizedBox(height: 16),
                  _buildChargesCard(ctrl),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(ctrl),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(EditCustomerController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge, color: AppColors.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.initialCustomer.fullName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (ctrl.initialCustomer.uuid != null && ctrl.initialCustomer.uuid!.isNotEmpty)
                    Text(
                      'UUID: ${ctrl.initialCustomer.uuid!.length > 14 ? "${ctrl.initialCustomer.uuid!.substring(0, 14)}..." : ctrl.initialCustomer.uuid}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ],
          ),
          Obx(() {
            final isCompleted = ctrl.isShiftCompleted.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFE6F4EA) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.schedule,
                    size: 13,
                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCompleted ? 'Completed' : 'In Progress',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShiftingTabBar(EditCustomerController ctrl) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Shiftings (${ctrl.shiftings.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => ctrl.addShifting(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 15, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Add Shifting',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(ctrl.shiftings.length, (index) {
                  final isSelected = ctrl.activeShiftIndex.value == index;
                  final shift = ctrl.shiftings[index];
                  final fromCity = shift.shiftFromCityCtrl.text.trim();
                  final toCity = shift.shiftToCityCtrl.text.trim();
                  final label = (fromCity.isNotEmpty && toCity.isNotEmpty)
                      ? '$fromCity → $toCity'
                      : 'Shifting ${index + 1}';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ctrl.setActiveShift(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              shift.isShiftCompleted.value ? Icons.check_circle : Icons.local_shipping,
                              size: 15,
                              color: isSelected
                                  ? (shift.isShiftCompleted.value ? const Color(0xFF86EFAC) : Colors.white)
                                  : (shift.isShiftCompleted.value ? const Color(0xFF16A34A) : AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                            if (ctrl.shiftings.length > 1) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => ctrl.removeShifting(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.surfaceContainerHigh,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildShiftStatusBanner(EditCustomerController ctrl) {
    return Obx(() {
      final isCompleted = ctrl.isShiftCompleted.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.isShiftCompleted.value = !isCompleted,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted ? const Color(0xFF4ADE80) : const Color(0xFFF59E0B),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? Colors.green : Colors.amber).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Shift Marked as Completed' : 'Mark as Completed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? const Color(0xFF15803D) : const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isCompleted
                            ? 'All delivery tasks completed. Tap to mark as in progress.'
                            : 'Currently in progress. Tap here or toggle switch once finished.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted ? const Color(0xFF166534) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isCompleted,
                  activeThumbColor: const Color(0xFF16A34A),
                  activeTrackColor: const Color(0xFFBBF7D0),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD1D5DB),
                  onChanged: (val) => ctrl.isShiftCompleted.value = val,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPersonalDetailsCard(EditCustomerController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, color: AppColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Customer Personal Details',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (ctrl.initialCustomer.uuid != null)
                Text(
                  'UUID: ${ctrl.initialCustomer.uuid!.length > 8 ? ctrl.initialCustomer.uuid!.substring(0, 8) : ctrl.initialCustomer.uuid}',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            children: [
              Expanded(child: _buildInputField('First Name', ctrl.firstNameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField('Last Name', ctrl.lastNameCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField('Primary Mobile Number', ctrl.mobileCtrl, icon: Icons.phone, isNumeric: true, maxLength: 10),
          const SizedBox(height: 12),
          _buildInputField('Alternate Mobile No', ctrl.altMobileCtrl, isNumeric: true, maxLength: 10, prefixText: '+91 '),
          const SizedBox(height: 12),
          _buildInputField('Email Address', ctrl.emailCtrl, icon: Icons.mail, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildInputField('Work Email', ctrl.workEmailCtrl, icon: Icons.domain, keyboardType: TextInputType.emailAddress),
        ],
      ),
    );
  }

  Widget _buildShiftingDetailsCard(BuildContext context, EditCustomerController ctrl) {
    return Container(
      key: ValueKey('edit_shifting_details_${ctrl.activeShiftIndex.value}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping, color: AppColors.onSecondaryContainer, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shifting #${ctrl.activeShiftIndex.value + 1} Details',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Primary', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const Divider(height: 24, thickness: 1),
          const Text('Shifting Category & Type', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.medical_services, color: AppColors.onPrimary, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    final normalizedVal = ShiftingTypeHelper.normalize(ctrl.shiftingType.value);
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: normalizedVal,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.onSurface),
                        onChanged: (v) {
                          if (v != null) ctrl.shiftingType.value = v;
                        },
                        items: ShiftingTypeHelper.typeMap.entries.map((e) {
                          return DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInputField('Pickup Origin City', ctrl.shiftFromCityCtrl),
                const SizedBox(height: 8),
                _buildInputField('Street / Landmark address', ctrl.fromAddressCtrl),
                const SizedBox(height: 12),
                _buildInputField('Destination City', ctrl.shiftToCityCtrl),
                const SizedBox(height: 8),
                _buildInputField('Delivery street address', ctrl.toAddressCtrl),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Shifting Start Date', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: ctrl.shiftingStartDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) ctrl.shiftingStartDate.value = picked;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() => Text(
                              ctrl.shiftingStartDate.value != null ? ctrl.shiftingStartDate.value!.toString().substring(0, 10) : 'Select Date',
                              style: const TextStyle(fontSize: 14),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expected Delivery Date', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: ctrl.expectedDeliveryDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) ctrl.expectedDeliveryDate.value = picked;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() => Text(
                              ctrl.expectedDeliveryDate.value != null ? ctrl.expectedDeliveryDate.value!.toString().substring(0, 10) : 'Select Date',
                              style: const TextStyle(fontSize: 14),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified, color: AppColors.onPrimary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Token / Advance Paid', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: ctrl.advancePaidCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                            style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              prefixText: '₹',
                              prefixStyle: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesCard(EditCustomerController ctrl) {
    return Container(
      key: ValueKey('edit_shifting_charges_${ctrl.activeShiftIndex.value}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments, color: AppColors.onPrimary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Itemized Shifting Charges (Shift #${ctrl.activeShiftIndex.value + 1})',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          _buildChargeRow('Transport Charge', ctrl.transportChargeCtrl),
          _buildChargeRow('Packing Charge', ctrl.packingChargeCtrl),
          _buildChargeRow('Loading Charge', ctrl.loadingChargeCtrl),
          _buildChargeRow('Unloading Charge', ctrl.unloadingChargeCtrl),
          _buildChargeRow('Unpacking Charge', ctrl.unpackingChargeCtrl),
          _buildChargeRow('Car Transport Charge', ctrl.carTransportChargeCtrl),
          _buildChargeRow('Risk / Insurance Charge', ctrl.riskInsureChargeCtrl),
          _buildChargeRow('Storage Charge', ctrl.storageChargeCtrl),
          _buildChargeRow('Statistical Charge', ctrl.statisticalChargeCtrl),
          _buildChargeRow('Service Charge', ctrl.serviceChargeCtrl),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Matrix Amount', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                        Text('₹${ctrl.subtotal.value.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('GST Applicable', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${ctrl.gstApplicable.value}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            )
                          ],
                        ),
                        Text('₹${ctrl.gstAmount.value.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Less: Token Paid (Advance)', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                        Text('-₹${(double.tryParse(ctrl.advancePaidCtrl.text) ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Net Payable', style: TextStyle(color: AppColors.primary, fontSize: 19, fontWeight: FontWeight.bold)),
                            Text('Balance due after advance', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                        Text('₹${ctrl.netPayable.value.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 23, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt, size: 16, color: AppColors.secondary),
                              SizedBox(width: 6),
                              Text(
                                'Total Shifting Amount (with GST)',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${ctrl.totalAmount.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _buildChargeRow(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              const Text('₹', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    fillColor: AppColors.surfaceContainerLowest,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType, bool isNumeric = false, int? maxLength, String? prefixText}) {
    List<TextInputFormatter> formatters = [];
    if (isNumeric) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? (isNumeric ? TextInputType.number : TextInputType.text),
          inputFormatters: formatters,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.secondary, size: 18) : null,
            prefixText: prefixText,
            prefixStyle: prefixText != null ? const TextStyle(color: AppColors.onSurface, fontSize: 14) : null,
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(EditCustomerController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainer,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : () => ctrl.updateCustomer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: ctrl.isSaving.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
