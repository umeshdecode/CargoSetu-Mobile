import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dispute_rating_model.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';
import 'live_trip_screen.dart';

/// Detailed view of a marketplace booking.
/// Financial breakdown, assigned truck & driver contact, live trip link,
/// dispute resolution, and zero database primary key exposure.
class BookingDetailScreen extends StatefulWidget {
  final MarketplaceBookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _service = MarketplaceService();
  late MarketplaceBookingModel _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _refreshBooking();
  }

  Future<void> _refreshBooking() async {
    if (_booking.id == null) return;
    final updated = await _service.getBookingDetails(_booking.id!);
    if (updated != null && mounted) {
      setState(() => _booking = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final bookingRef = _booking.bookingNumber ?? 'Booking';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookingRef,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (_booking.listingNumber != null)
              Text(
                'Listing Ref: ${_booking.listingNumber}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 16),
            _buildCommercialsCard(currencyFormatter),
            const SizedBox(height: 16),
            _buildTruckDriverCard(),
            const SizedBox(height: 16),
            _buildPartiesCard(),
            const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Status',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                _booking.status.name.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          if (_booking.bookedAt != null)
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(_booking.bookedAt!) ?? DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  Widget _buildCommercialsCard(NumberFormat currencyFormatter) {
    final advancePct = _booking.advancePercentage ?? 0;
    final advanceAmount = (_booking.agreedFreight * advancePct) / 100;
    final balanceAmount = _booking.agreedFreight - advanceAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Financial Agreement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Agreed Freight', currencyFormatter.format(_booking.agreedFreight), isBold: true),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildRow('Payment Terms', _booking.paymentTerms.name.replaceAll('_', ' ')),
          if (advancePct > 0) ...[
            const SizedBox(height: 8),
            _buildRow('Advance ($advancePct%)', currencyFormatter.format(advanceAmount), valueColor: const Color(0xFF2563EB)),
            const SizedBox(height: 8),
            _buildRow('Balance on Delivery', currencyFormatter.format(balanceAmount)),
          ],
        ],
      ),
    );
  }

  Widget _buildTruckDriverCard() {
    final hasVehicle = _booking.vehicleNumber != null && _booking.vehicleNumber!.isNotEmpty;
    final hasDriver = _booking.driverName != null && _booking.driverName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Assigned Vehicle & Crew',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasVehicle)
            _buildRow('Vehicle Number', _booking.vehicleNumber!, isBold: true)
          else
            const Text(
              'Vehicle not yet assigned by transporter',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
            ),
          if (hasDriver) ...[
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Driver', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(
                      _booking.driverName!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                if (_booking.driverPhone != null && _booking.driverPhone!.isNotEmpty)
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('tel:${_booking.driverPhone}')),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text(
                            'Call Driver',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Trading Parties',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow('Shipper', _booking.shipperCompanyName ?? 'Verified Shipper'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildRow('Transporter', _booking.transporterCompanyName ?? 'Verified Transporter'),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Track Live Trip
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (_booking.id != null) {
                Get.to(() => LiveTripScreen(bookingId: _booking.id!));
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.navigation_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Track Trip Execution & Milestones',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons Row: Cancel & Dispute / Rate
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showCancelDialog,
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showDisputeDialog,
                child: const Text(
                  'Raise Dispute',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rate & Review (If Completed)
        if (_booking.status == BookingStatus.COMPLETED)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _showRatingDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Leave Partner Review',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    final reasonCtrl = TextEditingController();
    String reasonCode = 'SHIPPER_CANCELLED';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancel Booking',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cancellation after confirmation may impact performance score.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for cancellation...',
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                onPressed: () async {
                  if (_booking.id == null) return;
                  Get.back();
                  final success = await _service.cancelBooking(
                    _booking.id!,
                    reasonCode,
                    reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Requested by user',
                  );
                  if (success) {
                    Get.snackbar('Cancelled', 'Booking has been cancelled.',
                        backgroundColor: Colors.red.shade700, colorText: Colors.white);
                    _refreshBooking();
                  }
                },
                child: const Text('Confirm Cancellation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputeDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DisputeCategory category = DisputeCategory.DETENTION;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Raise Marketplace Dispute',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    children: [
                      DropdownButtonFormField<DisputeCategory>(
                        value: category,
                        items: DisputeCategory.values.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c.name.replaceAll('_', ' ')));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => category = val);
                        },
                        decoration: InputDecoration(
                          labelText: 'Dispute Category',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Claimed Amount (₹)',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description & Evidence Details',
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (_booking.id == null) return;
                    Get.back();
                    final dispute = DisputeModel(
                      bookingId: _booking.id!,
                      category: category,
                      description: descCtrl.text.trim(),
                      claimAmount: double.tryParse(amountCtrl.text.trim()),
                    );
                    final success = await _service.raiseDispute(dispute);
                    if (success) {
                      Get.snackbar('Dispute Raised', 'Our operations team has received your dispute.',
                          backgroundColor: Colors.amber.shade700, colorText: Colors.white);
                      _refreshBooking();
                    }
                  },
                  child: const Text('Submit Dispute', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    int rating = 5;
    final feedbackCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rate Counterpart Experience',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setModalState(() => rating = star),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feedbackCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Share feedback regarding timeliness, condition, and communication...',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      if (_booking.id == null) return;
                      Get.back();
                      final review = RatingReviewModel(
                        bookingId: _booking.id!,
                        overallRating: rating,
                        comment: feedbackCtrl.text.trim(),
                      );
                      final success = await _service.submitRating(review);
                      if (success) {
                        Get.snackbar('Thank You', 'Your rating has been submitted.',
                            backgroundColor: const Color(0xFF059669), colorText: Colors.white);
                      }
                    },
                    child: const Text('Submit Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
