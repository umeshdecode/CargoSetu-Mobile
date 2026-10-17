import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/load_post_model.dart';
import '../models/marketplace_offer_model.dart';
import '../widgets/offer_bottom_sheet.dart';
import '../services/marketplace_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'marketplace_chat_screen.dart';

/// Comprehensive specification and bidding screen for a freight load.
/// Displays route, commodity characteristics, truck requirements, and commercial terms
/// without ever exposing internal database IDs.
class LoadDetailScreen extends StatelessWidget {
  final LoadPostModel load;
  final MarketplaceService? service;

  const LoadDetailScreen({super.key, required this.load, this.service});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

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
          load.listingNumber ?? 'Load Details',
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
            // ─── Route Card ───
            _buildCard(
              title: 'Route Details',
              icon: Icons.navigation_outlined,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, size: 12, color: Color(0xFF10B981)),
                          Container(
                            width: 2,
                            height: 38,
                            color: const Color(0xFFCBD5E1),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                          ),
                          const Icon(Icons.location_on, size: 14, color: Color(0xFFEF4444)),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              load.originCity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (load.originAddress != null && load.originAddress!.isNotEmpty)
                              Text(
                                '${load.originAddress!}${load.originState != null ? ", ${load.originState!}" : ""}',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                              ),
                            const SizedBox(height: 18),
                            Text(
                              load.destinationCity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (load.destinationAddress != null && load.destinationAddress!.isNotEmpty)
                              Text(
                                '${load.destinationAddress!}${load.destinationState != null ? ", ${load.destinationState!}" : ""}',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoPair(
                        'Pickup Schedule',
                        load.pickupFrom != null ? _formatDate(load.pickupFrom!) : 'Immediate',
                      ),
                      _infoPair(
                        'Expected Delivery',
                        load.deliveryTo != null ? _formatDate(load.deliveryTo!) : 'Flexible',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Commercials & Pricing Card ───
            _buildCard(
              title: 'Freight & Payment Terms',
              icon: Icons.payments_outlined,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asking Freight',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            load.askingPrice != null && load.askingPrice! > 0
                                ? currencyFormatter.format(load.askingPrice)
                                : 'Negotiable Rate',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          load.priceType == 'PER_TON' ? 'Per Ton Rate' : 'Fixed Rate',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoPair('Settlement Mode', load.paymentTerms.displayName),
                      _infoPair(
                        'Advance Required',
                        load.advancePercentage != null ? '${load.advancePercentage}%' : 'Negotiable',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Commodity Specifications ───
            _buildCard(
              title: 'Commodity & Cargo Specs',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _infoPair(
                          'Cargo Category',
                          load.cargoType.displayName,
                        ),
                      ),
                      Expanded(
                        child: _infoPair(
                          'Weight',
                          load.weight != null ? '${load.weight} ${load.weightUnit.name}' : 'Not specified',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoPair(
                          'Volume',
                          load.volume != null ? '${load.volume} CFT' : 'Not specified',
                        ),
                      ),
                      Expanded(
                        child: _infoPair(
                          'Packages Count',
                          load.packageCount != null ? '${load.packageCount} units' : 'Loose / Bulk',
                        ),
                      ),
                    ],
                  ),
                  if (load.cargoDescription != null && load.cargoDescription!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Material Description',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            load.cargoDescription!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Truck Requirements ───
            _buildCard(
              title: 'Required Vehicle Spec',
              icon: Icons.local_shipping_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: _infoPair(
                      'Truck Type',
                      load.requiredTruckType ?? 'Any Suitable',
                    ),
                  ),
                  Expanded(
                    child: _infoPair(
                      'Body Type',
                      load.requiredBodyType ?? 'Open / Container',
                    ),
                  ),
                  if (load.requiredTruckLength != null)
                    Expanded(
                      child: _infoPair(
                        'Min Length',
                        '${load.requiredTruckLength} Ft',
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Shipper Card ───
            _buildCard(
              title: 'Posted By',
              icon: Icons.business_outlined,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business, color: AppColors.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          load.companyName ?? 'Verified Enterprise Shipper',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          load.verificationStatus ?? 'Identity & GST Verified',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _startChat(context),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    tooltip: 'Chat with Shipper',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _makePhoneCall(null),
                    icon: const Icon(Icons.call, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF10B981),
                    ),
                    tooltip: 'Call Shipper',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Bottom Action CTA ───
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
                      onPressed: () {
                        OfferBottomSheet.show(
                          context: context,
                          title: 'Submit Offer for Load',
                          routeSubtitle: '${load.originCity} → ${load.destinationCity}',
                          targetPrice: load.askingPrice,
                          onSubmit: (amount, advancePct, terms, remarks) async {
                            if (load.listingId == null) return;
                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );
                            final service = MarketplaceService();
                            final offer = MarketplaceOfferModel(
                              listingId: load.listingId,
                              offeredAmount: amount,
                              advancePercentage: advancePct,
                              paymentTerms: terms,
                              remarks: remarks,
                            );
                            final success = await service.submitOffer(offer);
                            Get.back(); // close loader
                            if (success) {
                              Get.snackbar(
                                'Bid Placed!',
                                'Your offer of ₹${amount.toStringAsFixed(0)} was sent to ${load.companyName ?? "the shipper"}.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color(0xFFECFDF5),
                                colorText: const Color(0xFF065F46),
                              );
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.gavel, size: 18),
                      label: const Text(
                        'Submit Bid / Book Load',
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  void _showChatErrorWithRetry(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF991B1B),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _startChat(context),
          ),
        ),
      );
  }

  Future<void> _startChat(BuildContext context) async {
    if (load.companyId == null || load.postedByStaffId == null) {
      _showChatErrorWithRetry(
        context,
        'Unable to start chat: shipper participant details are unavailable.',
      );
      return;
    }

    try {
      final chatService = service ?? MarketplaceService();
      final conversation = await chatService.startConversation(
        listingId: load.listingId,
        participantCompanyId: load.companyId!,
        participantStaffId: load.postedByStaffId!,
        initialMessage: 'Hi, I am interested in your load ${load.listingNumber ?? ""}: ${load.originCity} to ${load.destinationCity}.',
      );

      if (!context.mounted) return;

      if (conversation != null && conversation.id != null && conversation.id! > 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MarketplaceChatScreen(
              conversationId: conversation.id,
              title: load.companyName ?? 'Shipper Chat',
            ),
          ),
        );
      } else {
        _showChatErrorWithRetry(
          context,
          'Unable to start chat conversation. Please try again.',
        );
      }
    } catch (e) {
      _showChatErrorWithRetry(
        context,
        'Unable to initiate chat: $e',
      );
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
