import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';
import 'booking_detail_screen.dart';
import 'marketplace_chat_screen.dart';

/// Screen listing user's freight marketplace bookings and booking requests
/// (separated into Outgoing Requests, Incoming Requests on owned listings, Active, and History).
/// Zero database primary key exposure: displays human-readable booking numbers.
class MyBookingsScreen extends StatefulWidget {
  final int initialTab;
  final MarketplaceService? service;

  const MyBookingsScreen({super.key, this.initialTab = 0, this.service});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final MarketplaceService _service;
  late TabController _tabController;

  bool _isLoading = false;
  List<MarketplaceBookingModel> _outgoingBookings = [];
  List<MarketplaceBookingModel> _incomingBookings = [];
  List<MarketplaceBookingModel> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MarketplaceService();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getMyBookings(role: 'OUTGOING'),
        _service.getMyBookings(role: 'INCOMING'),
        _service.getMyBookings(),
      ]);
      if (mounted) {
        setState(() {
          _outgoingBookings = results[0];
          _incomingBookings = results[1];
          _allBookings = results[2];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MarketplaceBookingModel> get _activeBookings {
    return _allBookings.where((b) {
      return b.status == BookingStatus.PENDING_PAYMENT ||
          b.status == BookingStatus.CONFIRMED ||
          b.status == BookingStatus.IN_PROGRESS;
    }).toList();
  }

  List<MarketplaceBookingModel> get _historyBookings {
    return _allBookings.where((b) {
      return b.status == BookingStatus.COMPLETED ||
          b.status == BookingStatus.REJECTED ||
          b.status == BookingStatus.CANCELLED ||
          b.status == BookingStatus.DISPUTED;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendingIncoming = _incomingBookings
        .where(
          (b) =>
              b.status == BookingStatus.PENDING_APPROVAL ||
              b.status == BookingStatus.REQUESTED,
        )
        .length;

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
        title: const Text(
          'Booking Requests & Trips',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            const Tab(text: 'My Requests'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Incoming'),
                  if (pendingIncoming > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingIncoming',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Confirmed'),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(
                  _outgoingBookings,
                  isIncoming: false,
                  emptyTitle: 'No Outgoing Booking Requests',
                  emptySubtitle:
                      'Requests you send on truck or load listings will appear here.',
                ),
                _buildBookingList(
                  _incomingBookings,
                  isIncoming: true,
                  emptyTitle: 'No Incoming Booking Requests',
                  emptySubtitle:
                      'Booking requests sent by shippers or transporters on your listings will appear here.',
                ),
                _buildBookingList(
                  _activeBookings,
                  isIncoming: false,
                  emptyTitle: 'No Active Confirmed Bookings',
                  emptySubtitle:
                      'Bookings confirmed by listing owners will appear here for live execution.',
                ),
                _buildBookingList(
                  _historyBookings,
                  isIncoming: false,
                  emptyTitle: 'No Past Bookings',
                  emptySubtitle:
                      'Completed, rejected, and cancelled bookings will appear here.',
                ),
              ],
            ),
    );
  }

  Widget _buildBookingList(
    List<MarketplaceBookingModel> bookings, {
    required bool isIncoming,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, isIncoming: isIncoming);
        },
      ),
    );
  }

  Widget _buildBookingCard(
    MarketplaceBookingModel booking, {
    required bool isIncoming,
  }) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final bookingRef = booking.bookingNumber ?? 'Booking Request';
    final hasRoute =
        (booking.originCity != null && booking.originCity!.isNotEmpty) ||
        (booking.destinationCity != null &&
            booking.destinationCity!.isNotEmpty);
    final canOwnerAct =
        isIncoming &&
        (booking.status == BookingStatus.PENDING_APPROVAL ||
            booking.status == BookingStatus.REQUESTED);
    final canRequesterActOnCounter =
        !isIncoming && booking.status == BookingStatus.COUNTERED;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final changed = await Get.to(
              () => BookingDetailScreen(
                booking: booking,
                isIncomingRequest: isIncoming,
                service: _service,
              ),
            );
            if (changed == true) _loadBookings();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Booking # & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.receipt_outlined,
                            size: 16,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bookingRef,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    _buildStatusPill(booking.status),
                  ],
                ),

                if (hasRoute) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 15,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${booking.originCity ?? "Origin"} → ${booking.destinationCity ?? "Destination"}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (booking.requestedCapacity != null &&
                          booking.requestedCapacity! > 0)
                        Text(
                          '${booking.requestedCapacity} ${booking.capacityUnit ?? "TONNE"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // Parties info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isIncoming
                              ? 'From: ${booking.requestedByCompanyName ?? booking.shipperCompanyName ?? "Verified Partner"}'
                              : 'Owner: ${booking.listingOwnerCompanyName ?? booking.transporterCompanyName ?? "Verified Partner"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (booking.vehicleNumber != null) ...[
                        Container(
                          height: 12,
                          width: 1,
                          color: const Color(0xFFCBD5E1),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Text(
                          booking.vehicleNumber!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (booking.counterFreight != null &&
                    booking.status == BookingStatus.COUNTERED) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          size: 15,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Counter-Offer: ${currencyFormatter.format(booking.counterFreight)}'
                            '${booking.remarks != null && booking.remarks!.isNotEmpty ? " · ${booking.remarks}" : ""}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (booking.rejectionReason != null &&
                    booking.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reason: ${booking.rejectionReason}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF991B1B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Footer: Price & Payment Terms
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.status == BookingStatus.PENDING_APPROVAL ||
                                  booking.status == BookingStatus.REQUESTED
                              ? 'Proposed Freight'
                              : 'Agreed Freight',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(
                            booking.proposedFreight ?? booking.agreedFreight,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (booking.advancePercentage != null &&
                            booking.advancePercentage! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${booking.advancePercentage}% Adv',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),

                // Inline Quick Actions for Incoming Requests or Countered Outgoing Requests
                if (canOwnerAct || canRequesterActOnCounter) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleAccept(booking),
                        icon: const Icon(Icons.check, size: 15),
                        label: Text(
                          canRequesterActOnCounter
                              ? 'Accept Counter'
                              : 'Accept',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      if (canOwnerAct)
                        OutlinedButton.icon(
                          onPressed: () => _showCounterDialog(booking),
                          icon: const Icon(Icons.swap_horiz, size: 15),
                          label: const Text('Counter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(booking),
                        icon: const Icon(Icons.close, size: 15),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _openChat(booking, isIncoming: isIncoming),
                        icon: const Icon(Icons.chat_bubble_outline, size: 15),
                        label: const Text('Chat'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          visualDensity: VisualDensity.compact,
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

  Future<void> _handleAccept(MarketplaceBookingModel booking) async {
    if (booking.id == null) return;
    final res = await _service.acceptBooking(booking.id!);
    if (res != null) {
      Get.snackbar(
        'Booking Confirmed',
        'Booking ${res.bookingNumber ?? ""} is now CONFIRMED.',
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
      );
      _loadBookings();
    }
  }

  void _showCounterDialog(MarketplaceBookingModel booking) {
    final freightCtrl = TextEditingController(
      text: (booking.proposedFreight ?? booking.agreedFreight).toStringAsFixed(
        0,
      ),
    );
    final remarksCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Propose Counter Freight',
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: freightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Counter Freight Amount (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: remarksCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Remarks (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: 'Send Counter-Offer',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryBlue,
      onConfirm: () async {
        final counterVal = double.tryParse(freightCtrl.text.trim()) ?? 0;
        if (counterVal <= 0 || booking.id == null) return;
        Get.back();
        final res = await _service.counterBooking(
          booking.id!,
          counterFreight: counterVal,
          remarks: remarksCtrl.text.trim().isNotEmpty
              ? remarksCtrl.text.trim()
              : null,
        );
        if (res != null) {
          Get.snackbar(
            'Counter-Offer Sent',
            'Counter freight of ₹${counterVal.toStringAsFixed(0)} has been sent.',
            backgroundColor: AppColors.primaryBlue,
            colorText: Colors.white,
          );
          _loadBookings();
        }
      },
    );
  }

  void _showRejectDialog(MarketplaceBookingModel booking) {
    final reasonCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Reject Booking Request',
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      contentPadding: const EdgeInsets.all(16),
      content: TextField(
        controller: reasonCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Reason for rejection',
          hintText: 'e.g. Rate too low or truck already committed',
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: 'Reject Request',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      onConfirm: () async {
        if (booking.id == null) return;
        Get.back();
        final res = await _service.rejectBooking(
          booking.id!,
          reason: reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : 'Declined by counterpart',
        );
        if (res != null) {
          Get.snackbar(
            'Booking Rejected',
            'The booking request has been rejected and reserved capacity restored.',
            backgroundColor: const Color(0xFF991B1B),
            colorText: Colors.white,
          );
          _loadBookings();
        }
      },
    );
  }

  Future<void> _openChat(
    MarketplaceBookingModel booking, {
    required bool isIncoming,
  }) async {
    final targetCompanyId = isIncoming
        ? (booking.requestedByCompanyId ?? booking.shipperCompanyId)
        : (booking.listingOwnerCompanyId ?? booking.transporterCompanyId);
    if (targetCompanyId == null) {
      Get.to(() => const MarketplaceChatScreen());
      return;
    }
    final convo = await _service.startConversation(
      bookingId: booking.id,
      listingId: booking.listingId,
      participantCompanyId: targetCompanyId,
      initialMessage: 'Regarding booking ${booking.bookingNumber ?? ""}',
    );
    if (convo != null && convo.id != null) {
      Get.to(
        () => MarketplaceChatScreen(
          conversationId: convo.id,
          title:
              (isIncoming
                  ? booking.requestedByCompanyName
                  : booking.listingOwnerCompanyName) ??
              'Booking Chat',
        ),
      );
    }
  }

  Widget _buildStatusPill(BookingStatus status) {
    Color bg;
    Color fg;
    String label = status.displayName.toUpperCase();

    switch (status) {
      case BookingStatus.CONFIRMED:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case BookingStatus.PENDING_APPROVAL:
      case BookingStatus.REQUESTED:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case BookingStatus.COUNTERED:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      case BookingStatus.IN_PROGRESS:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      case BookingStatus.COMPLETED:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6B21A8);
        break;
      case BookingStatus.REJECTED:
      case BookingStatus.CANCELLED:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case BookingStatus.DISPUTED:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
