import 'package:cargo_setu/customer/controllers/create_customer_controller.dart';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreateCustomerScreen extends StatelessWidget {
  const CreateCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateCustomerController ctrl = Get.put(CreateCustomerController());

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
        title: const Text(
          'Create Customer',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
            onPressed: () => ctrl.calculateTotals(),
            tooltip: 'Recalculate',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: AppColors.onPrimary, size: 18),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110, left: 16, right: 16, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRegistrationBanner(ctrl),
                const SizedBox(height: 14),
                _buildPersonalDetailsCard(ctrl),
                const SizedBox(height: 16),
                _buildShiftingTabBar(ctrl),
                const SizedBox(height: 12),
                _buildShiftStatusBanner(ctrl),
                const SizedBox(height: 16),
                Obx(() => _buildShiftingDetailsCard(context, ctrl)),
                const SizedBox(height: 16),
                Obx(() => _buildChargesCard(ctrl)),
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
      ),
    );
  }

  Widget _buildRegistrationBanner(CreateCustomerController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Customer Registration',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enter customer information and shifting details below',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftingTabBar(CreateCustomerController ctrl) {
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

  Widget _buildShiftStatusBanner(CreateCustomerController ctrl) {
    return Obx(() {
      final isCompleted = ctrl.currentShifting.isShiftCompleted.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.currentShifting.isShiftCompleted.value = !isCompleted,
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
                  onChanged: (val) => ctrl.currentShifting.isShiftCompleted.value = val,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPersonalDetailsCard(CreateCustomerController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('New Profile', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              )
            ],
          ),
          const Divider(height: 22, thickness: 1),

          // First Name & Last Name (2 columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() => _buildValidatedInput(
                      label: 'First Name *',
                      controller: ctrl.firstNameCtrl,
                      errorText: ctrl.firstNameError.value,
                      hintText: 'Enter first name',
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildValidatedInput(
                      label: 'Last Name *',
                      controller: ctrl.lastNameCtrl,
                      errorText: ctrl.lastNameError.value,
                      hintText: 'Enter last name',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Mobile with Call button
          Obx(() => _buildValidatedInput(
                label: 'Primary Mobile Number *',
                controller: ctrl.mobileCtrl,
                errorText: ctrl.mobileError.value,
                icon: Icons.phone_outlined,
                isNumeric: true,
                maxLength: 10,
                hintText: '10-digit mobile number',
                prefixText: '+91 ',
              )),
          const SizedBox(height: 12),

          // Alternate Mobile
          _buildValidatedInput(
            label: 'Alternate Mobile No',
            controller: ctrl.altMobileCtrl,
            isNumeric: true,
            maxLength: 10,
            hintText: 'Optional contact number',
            prefixText: '+91 ',
          ),
          const SizedBox(height: 12),

          // Email
          _buildValidatedInput(
            label: 'Email Address',
            controller: ctrl.emailCtrl,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            hintText: 'name@example.com',
          ),
          const SizedBox(height: 12),

          // Work Email
          _buildValidatedInput(
            label: 'Work Email',
            controller: ctrl.workEmailCtrl,
            icon: Icons.domain,
            keyboardType: TextInputType.emailAddress,
            hintText: 'office@company.com',
          ),
        ],
      ),
    );
  }

  Widget _buildShiftingDetailsCard(BuildContext context, CreateCustomerController ctrl) {
    return Container(
      key: ValueKey('shifting_details_${ctrl.activeShiftIndex.value}'),
      padding: const EdgeInsets.all(16),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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
                child: const Text('Priority', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const Divider(height: 22, thickness: 1),

          // Category & Type selector (using ShiftingTypeHelper)
          const Text(
            'Shifting Category & Type',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
          ),
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
                  child: const Icon(Icons.medical_services, color: AppColors.onPrimary, size: 15),
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
          const SizedBox(height: 14),

          // Connected Route Box (Pickup Origin -> Destination)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Pickup Origin City & Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            ),
                          ),
                          Container(width: 2, height: 48, color: AppColors.surfaceContainerHigh),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _buildValidatedInput(
                                label: 'PICKUP ORIGIN (FROM CITY) *',
                                controller: ctrl.shiftFromCityCtrl,
                                errorText: ctrl.fromCityError.value,
                                hintText: 'e.g. Jaipur',
                              )),
                          const SizedBox(height: 6),
                          _buildValidatedInput(
                            label: 'Pickup Street / Landmark Address',
                            controller: ctrl.fromAddressCtrl,
                            hintText: 'Sector / Colony / Street address',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Destination City & Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.navigation, color: Colors.white, size: 8),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _buildValidatedInput(
                                label: 'DESTINATION (TO CITY) *',
                                controller: ctrl.shiftToCityCtrl,
                                errorText: ctrl.toCityError.value,
                                hintText: 'e.g. Pune',
                              )),
                          const SizedBox(height: 6),
                          _buildValidatedInput(
                            label: 'Delivery Street / Colony Address',
                            controller: ctrl.toAddressCtrl,
                            hintText: 'House / Plot / Landmark',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Date pickers row
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
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                                  ctrl.shiftingStartDate.value != null ? ctrl.shiftingStartDate.value!.toString().substring(0, 10) : 'Select Date',
                                  style: const TextStyle(fontSize: 13),
                                )),
                          ],
                        ),
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
                        child: Row(
                          children: [
                            const Icon(Icons.event_available, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                                  ctrl.expectedDeliveryDate.value != null ? ctrl.expectedDeliveryDate.value!.toString().substring(0, 10) : 'Select Date',
                                  style: const TextStyle(fontSize: 13),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Token / Advance Paid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
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
                          width: 130,
                          child: TextField(
                            controller: ctrl.advancePaidCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              prefixText: '₹ ',
                              prefixStyle: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Advance Deduction', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesCard(CreateCustomerController ctrl) {
    return Container(
      key: ValueKey('shifting_charges_${ctrl.activeShiftIndex.value}'),
      padding: const EdgeInsets.all(16),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Text('10 Items', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const Divider(height: 22, thickness: 1),

          _buildChargeRow('Transport Charge', ctrl.transportChargeCtrl),
          _buildChargeRow('Packing Charge', ctrl.packingChargeCtrl),
          _buildChargeRow('Loading Charge', ctrl.loadingChargeCtrl),
          _buildChargeRow('Unloading Charge', ctrl.unloadingChargeCtrl),
          _buildChargeRow('Unpacking Charge', ctrl.unpackingChargeCtrl),
          _buildChargeRow('Car Transport Charge', ctrl.carTransportChargeCtrl),
          _buildChargeRow('Risk / Insurance Charge', ctrl.riskInsureChargeCtrl),
          _buildChargeRow('Storage Charge', ctrl.storageChargeCtrl),
          _buildChargeRow('Statistical Charge', ctrl.statisticalChargeCtrl),
          _buildChargeRow('Service Charge (1.0%)', ctrl.serviceChargeCtrl),

          const SizedBox(height: 16),

          // Calculations Box: Subtotal, GST, Advance, Net Payable, and TOTAL!
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(() => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Matrix Amount', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        Text('₹${ctrl.subtotal.value.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('GST Applicable', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${ctrl.gstApplicable.value}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        Text('₹${ctrl.gstAmount.value.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Less: Token Paid (Advance)', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                        Text('-₹${(double.tryParse(ctrl.advancePaidCtrl.text) ?? 0.0).toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),

                    const Divider(height: 22, thickness: 1),

                    // Net Payable Row (Highlight)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Payable',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Balance due after advance',
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          '₹${ctrl.netPayable.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Total Row (Gross Total shown directly below Net Payable as requested!)
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5)),
          Row(
            children: [
              const Text('₹', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              SizedBox(
                width: 85,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13.5),
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

  Widget _buildValidatedInput({
    required String label,
    required TextEditingController controller,
    String? errorText,
    String? hintText,
    IconData? icon,
    TextInputType? keyboardType,
    bool isNumeric = false,
    int? maxLength,
    String? prefixText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasError ? const Color(0xFFBA1A1A) : AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: hasError ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (hasError)
              Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFBA1A1A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? (isNumeric ? TextInputType.phone : TextInputType.text),
          inputFormatters: formatters,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
            prefixIcon: icon != null ? Icon(icon, color: hasError ? const Color(0xFFBA1A1A) : AppColors.secondary, size: 18) : null,
            prefixText: prefixText,
            prefixStyle: prefixText != null ? const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold) : null,
            filled: true,
            fillColor: hasError ? const Color(0xFFFFF0F0) : AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFBA1A1A) : Colors.transparent,
                width: hasError ? 1.5 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFBA1A1A) : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(CreateCustomerController ctrl) {
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                    onPressed: ctrl.isLoading.value ? null : () => ctrl.createCustomer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: ctrl.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text('Create Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
