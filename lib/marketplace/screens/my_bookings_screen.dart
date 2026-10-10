import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';
import 'booking_detail_screen.dart';

/// Screen listing user's freight marketplace bookings (as Shipper or Transporter).
/// Zero database primary key exposure: displays human-readable booking numbers.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  final _service = MarketplaceService();
  late TabController _tabController;

  bool _isLoading = false;
  List<MarketplaceBookingModel> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final bookings = await _service.getMyBookings();
    if (mounted) {
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    }
  }

  List<MarketplaceBookingModel> _filterBookings(int tabIndex) {
    switch (tabIndex) {
      case 1: // Active / In-Progress
        return _allBookings.where((b) {
          return b.status == BookingStatus.PENDING_PAYMENT ||
              b.status == BookingStatus.CONFIRMED ||
              b.status == BookingStatus.IN_PROGRESS;
        }).toList();
      case 2: // Completed
        return _allBookings.where((b) => b.status == BookingStatus.COMPLETED).toList();
      case 3: // Cancelled / Disputed
        return _allBookings.where((b) {
          return b.status == BookingStatus.CANCELLED ||
              b.status == BookingStatus.DISPUTED;
        }).toList();
      default: // All
        return _allBookings;
    }
  }

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
        title: const Text(
          'My Marketplace Bookings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_filterBookings(0)),
                _buildBookingList(_filterBookings(1)),
                _buildBookingList(_filterBookings(2)),
                _buildBookingList(_filterBookings(3)),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<MarketplaceBookingModel> bookings) {
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
              const Text(
                'No Bookings Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Accepted bids and load agreements will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(MarketplaceBookingModel booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final bookingRef = booking.bookingNumber ?? 'Booking';

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
            final changed = await Get.to(() => BookingDetailScreen(booking: booking));
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
                const SizedBox(height: 12),

                // Parties info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.transporterCompanyName ?? booking.shipperCompanyName ?? 'Verified Partner',
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
                const SizedBox(height: 12),

                // Footer: Price & Payment Terms
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agreed Freight',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(booking.agreedFreight),
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
                        if (booking.advancePercentage != null && booking.advancePercentage! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(BookingStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case BookingStatus.CONFIRMED:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'CONFIRMED';
        break;
      case BookingStatus.IN_PROGRESS:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'IN TRANSIT';
        break;
      case BookingStatus.COMPLETED:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6B21A8);
        label = 'COMPLETED';
        break;
      case BookingStatus.CANCELLED:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'CANCELLED';
        break;
      case BookingStatus.DISPUTED:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        label = 'DISPUTED';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = status.name.replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
