import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marketplace_enums.dart';

/// Modal bottom sheet for submitting a bid or counter-offer on a freight listing.
/// Formatted cleanly for truckers and shippers with large numeric keys,
/// quick percentage chips, and zero database ID exposure.
class OfferBottomSheet extends StatefulWidget {
  final String title;
  final String routeSubtitle;
  final double? targetPrice;
  final Function(
    double amount,
    int advancePct,
    PaymentTermType terms,
    String? remarks,
  )
  onSubmit;

  const OfferBottomSheet({
    super.key,
    required this.title,
    required this.routeSubtitle,
    this.targetPrice,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String routeSubtitle,
    double? targetPrice,
    required Function(
      double amount,
      int advancePct,
      PaymentTermType terms,
      String? remarks,
    )
    onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfferBottomSheet(
        title: title,
        routeSubtitle: routeSubtitle,
        targetPrice: targetPrice,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<OfferBottomSheet> createState() => _OfferBottomSheetState();
}

class _OfferBottomSheetState extends State<OfferBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  int _selectedAdvance = 50;
  PaymentTermType _selectedTerms = PaymentTermType.ADVANCE_PERCENT;

  @override
  void initState() {
    super.initState();
    if (widget.targetPrice != null && widget.targetPrice! > 0) {
      _amountController.text = widget.targetPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.routeSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Offer Amount Input
            const Text(
              'Your Offer Amount (₹)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                hintText: '0',
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Advance Percentage Selection
            const Text(
              'Advance Payment Required',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [0, 20, 50, 80, 100].map((pct) {
                final isSelected = _selectedAdvance == pct;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text('$pct%'),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _selectedAdvance = pct);
                      },
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Payment Terms
            const Text(
              'Payment Settlement Term',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PaymentTermType>(
                  value: _selectedTerms,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                  ),
                  items: PaymentTermType.values.map((term) {
                    return DropdownMenuItem(
                      value: term,
                      child: Text(
                        term.displayName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTerms = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Remarks / Notes
            const Text(
              'Notes / Conditions (Optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., Toll included, loading by shipper',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
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

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final amount =
                      double.tryParse(_amountController.text.trim()) ?? 0.0;
                  if (amount <= 0) {
                    Get.snackbar(
                      'Invalid Amount',
                      'Please enter a valid offer amount.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFFFEF2F2),
                      colorText: const Color(0xFFDC2626),
                    );
                    return;
                  }
                  Get.back();
                  widget.onSubmit(
                    amount,
                    _selectedAdvance,
                    _selectedTerms,
                    _remarksController.text.trim().isEmpty
                        ? null
                        : _remarksController.text.trim(),
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
                  'Confirm & Submit Bid',
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
