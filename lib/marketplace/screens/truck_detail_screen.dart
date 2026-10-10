import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'marketplace_chat_screen.dart';
import '../models/truck_post_model.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';

/// Detailed view for an available truck post.
/// Displays vehicle capacity, driver contact, route, and booking flow
/// without revealing internal entity IDs.
class TruckDetailScreen extends StatelessWidget {
  final TruckPostModel truck;

  const TruckDetailScreen({super.key, required this.truck});

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          truck.listingNumber ?? 'Truck Availability',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
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
            // ─── Vehicle Header Card ───
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Color(0xFF059669),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck.vehicleNumber ?? (truck.truckType ?? 'Commercial Vehicle'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          truck.companyName ?? 'Verified Fleet Operator',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (truck.overallRating != null && truck.overallRating! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            truck.overallRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Location & Route ───
            _buildCard(
              title: 'Current Location & Route',
              icon: Icons.navigation_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Stationed City',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                            Text(
                              truck.currentCity,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (truck.routeTo != null && truck.routeTo!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Route / Heading To',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                              Text(
                                truck.routeTo!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Capacity Specifications ───
            _buildCard(
              title: 'Payload & Vehicle Specs',
              icon: Icons.tune,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _infoPair(
                          'Available Capacity',
                          truck.availableCapacity != null
                              ? '${truck.availableCapacity} ${truck.capacityUnit.name}'
                              : 'Full Truckload',
                        ),
                      ),
                      Expanded(
                        child: _infoPair(
                          'Total Passing',
                          truck.passingCapacityTons != null
                              ? '${truck.passingCapacityTons} Tons'
                              : 'Standard',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoPair('Body Type', truck.bodyType ?? 'Open Body'),
                      ),
                      Expanded(
                        child: _infoPair(
                          'Length',
                          truck.truckLengthFeet != null ? '${truck.truckLengthFeet} Ft' : 'Standard',
                        ),
                      ),
                    ],
                  ),
                  if (truck.pricePerKm != null && truck.pricePerKm! > 0) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _infoPair(
                            'Estimated Rate',
                            '₹${truck.pricePerKm!.toStringAsFixed(0)} / km',
                          ),
                        ),
                        if (truck.minimumPrice != null)
                          Expanded(
                            child: _infoPair(
                              'Minimum Freight',
                              '₹${truck.minimumPrice!.toStringAsFixed(0)}',
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Driver Contact Card ───
            if (truck.driverName != null && truck.driverName!.isNotEmpty)
              _buildCard(
                title: 'Assigned Driver',
                icon: Icons.person_outline,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck.driverName!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (truck.driverPhone != null)
                          Text(
                            truck.driverPhone!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: () => _startChat(context),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: AppColors.primaryBlue,
                          ),
                          tooltip: 'Chat with Operator / Driver',
                        ),
                        if (truck.driverPhone != null && truck.driverPhone!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () => _makePhoneCall(truck.driverPhone),
                            icon: const Icon(Icons.call, size: 18),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                            tooltip: 'Call Driver',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ─── Book Capacity CTA ───
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _startChat(context),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _showBookingDialog(context),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Book Truck Capacity',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    final freightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Confirm Capacity Booking',
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Column(
        children: [
          TextField(
            controller: freightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Agreed Freight Amount (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weightCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cargo Weight (${truck.capacityUnit.name})',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: 'Confirm Booking',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryBlue,
      onConfirm: () async {
        final amount = double.tryParse(freightCtrl.text.trim()) ?? 0.0;
        final capacity = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
        if (amount <= 0) return;

        Get.back();
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        final service = MarketplaceService();
        final booking = MarketplaceBookingModel(
          listingId: truck.listingId,
          vehicleId: truck.vehicleId,
          driverId: truck.driverId,
          agreedFreight: amount,
          requestedCapacity: capacity,
          paymentTerms: PaymentTermType.ADVANCE_PERCENT,
          advancePercentage: 50,
        );

        final success = await service.createBooking(booking);
        Get.back();

        if (success) {
          Get.snackbar(
            'Truck Capacity Booked!',
            'Your booking request has been confirmed with ${truck.companyName ?? "transporter"}.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFECFDF5),
            colorText: const Color(0xFF065F46),
          );
        }
      },
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoPair(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Future<void> _startChat(BuildContext context) async {
    if (truck.companyId == null || truck.postedByStaffId == null) {
      Get.to(() => MarketplaceChatScreen(
        title: truck.companyName ?? 'Transporter Chat',
      ));
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final service = MarketplaceService();
      final conversation = await service.startConversation(
        listingId: truck.listingId,
        participantCompanyId: truck.companyId!,
        participantStaffId: truck.postedByStaffId!,
        initialMessage: 'Hi, I am inquiring about your truck ${truck.vehicleNumber ?? ""}: stationed at ${truck.currentCity}.',
      );
      Get.back(); // close loader

      if (conversation != null && conversation.id != null) {
        Get.to(() => MarketplaceChatScreen(
          conversationId: conversation.id,
          title: truck.companyName ?? 'Transporter Chat',
        ));
      } else {
        Get.to(() => MarketplaceChatScreen(
          title: truck.companyName ?? 'Transporter Chat',
        ));
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Unable to initiate chat: $e');
    }
  }

  Future<void> _makePhoneCall(String? rawPhone) async {
    if (rawPhone == null || rawPhone.trim().isEmpty) {
      Get.snackbar(
        'Phone Unavailable',
        'No phone number available for this contact.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF991B1B),
      );
      return;
    }
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Call Failed',
        'Could not launch phone dialer for $rawPhone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF991B1B),
      );
    }
  }
}
