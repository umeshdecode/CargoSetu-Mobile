import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/marketplace_hub_controller.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../models/marketplace_offer_model.dart';
import '../widgets/load_card_widget.dart';
import '../widgets/truck_card_widget.dart';
import '../widgets/marketplace_filter_sheet.dart';
import '../widgets/offer_bottom_sheet.dart';
import 'booking_detail_screen.dart';
import 'create_load_post_screen.dart';
import 'create_truck_post_screen.dart';
import 'load_detail_screen.dart';
import 'truck_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'marketplace_wallet_screen.dart';
import 'marketplace_chat_screen.dart';

/// Central discovery and transaction hub for the CargoSetu Two-Sided Marketplace.
/// Enables shippers to discover available truck capacity, truckers to find freight loads,
/// and both parties to manage My Bids, My Booking Requests, Incoming Requests, and My Listings.
class MarketplaceHubScreen extends StatelessWidget {
  final MarketplaceHubController? hubController;

  const MarketplaceHubScreen({super.key, this.hubController});

  @override
  Widget build(BuildContext context) {
    final MarketplaceHubController controller =
        hubController ??
        Get.put<MarketplaceHubController>(MarketplaceHubController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          // ─── Segmented Tab Switcher ───
          _buildSegmentedTabs(controller),

          // ─── Active Filter & Route Corridor Indicator Banner ───
          Obx(() {
            final hasFilters =
                controller.filterOrigin.value != null ||
                controller.filterDestination.value != null ||
                controller.filterCargoType.value != null;

            if (!hasFilters) return const SizedBox.shrink();

            final distKm = controller.filterRouteDistanceKm;
            final isTruckTab = controller.currentTabIndex.value == 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Filtered by: ${_filterDescription(controller)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distKm != null && distKm > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            LocationService.formatDistanceKm(distKm),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                      InkWell(
                        onTap: controller.clearFilters,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isTruckTab &&
                      (controller.filterOrigin.value != null ||
                          controller.filterDestination.value != null)) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.radar,
                          size: 13,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Showing trucks within ${controller.filterRadiusKm.value.round()} km of '
                            '${controller.filterOrigin.value ?? "Any"} → ${controller.filterDestination.value ?? "Any"}'
                            '${distKm != null && distKm > 0 ? " (${LocationService.formatDistanceKm(distKm)})" : ""}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),

          // ─── Feed / Activity Content ───
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.currentTabIndex.value != 2) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.currentTabIndex.value != 2) {
                return _buildErrorState(controller);
              }

              final tab = controller.currentTabIndex.value;
              if (tab == 0) {
                return _buildLoadsList(controller);
              } else if (tab == 1) {
                return _buildTrucksList(controller);
              } else {
                return _buildMyActivitySection(context, controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: _buildPostFloatingButton(context, controller),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, color: AppColors.primaryBlue, size: 22),
          SizedBox(width: 8),
          Text(
            'Marketplace',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final hasFilters =
              controller.filterOrigin.value != null ||
              controller.filterDestination.value != null ||
              controller.filterCargoType.value != null;
          return IconButton(
            icon: Badge(
              isLabelVisible: hasFilters,
              smallSize: 8,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.tune, color: Color(0xFF334155)),
            ),
            tooltip: 'Filter Listings',
            onPressed: () {
              MarketplaceFilterSheet.show(
                context: context,
                origin: controller.filterOrigin.value,
                destination: controller.filterDestination.value,
                originLat: controller.filterOriginLat.value,
                originLng: controller.filterOriginLng.value,
                destLat: controller.filterDestLat.value,
                destLng: controller.filterDestLng.value,
                cargoType: controller.filterCargoType.value,
                isTruckSearch: controller.currentTabIndex.value == 1,
                onApply: controller.applyFilters,
              );
            },
          );
        }),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF334155)),
          tooltip: 'Marketplace Chat',
          onPressed: () => Get.to(() => const MarketplaceChatScreen()),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF334155)),
          tooltip: 'Marketplace Options',
          onSelected: (val) {
            if (val == 'bookings') {
              Get.to(() => const MyBookingsScreen(initialTab: 0));
            } else if (val == 'incoming') {
              Get.to(() => const MyBookingsScreen(initialTab: 1));
            } else if (val == 'activity') {
              controller.setTab(2);
            } else if (val == 'wallet') {
              Get.to(() => const MarketplaceWalletScreen());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'activity',
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_ind_outlined,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(width: 10),
                  Text('My Activity & Bids', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bookings',
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(width: 10),
                  Text('My Booking Requests', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'incoming',
              child: Row(
                children: [
                  Icon(
                    Icons.move_to_inbox_outlined,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(width: 10),
                  Text('Incoming Requests', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'wallet',
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(width: 10),
                  Text('Escrow Wallet', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }

  Widget _buildSegmentedTabs(MarketplaceHubController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        final activeTab = controller.currentTabIndex.value;
        final badgeCount = controller.pendingIncomingCount;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _tabButton(
                title: 'Find Loads',
                icon: Icons.inventory_2_outlined,
                isSelected: activeTab == 0,
                onTap: () => controller.setTab(0),
              ),
              _tabButton(
                title: 'Find Trucks',
                icon: Icons.local_shipping_outlined,
                isSelected: activeTab == 1,
                onTap: () => controller.setTab(1),
              ),
              _tabButton(
                title: 'My Activity',
                icon: Icons.assignment_outlined,
                isSelected: activeTab == 2,
                badgeCount: badgeCount,
                onTap: () => controller.setTab(2),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadsList(MarketplaceHubController controller) {
    if (controller.loads.isEmpty) {
      return _buildEmptyState(
        title: 'No Loads Found',
        subtitle:
            'There are no active freight load postings matching your filters right now.',
        buttonLabel: 'Post a Load',
        onButtonTap: () async {
          final created = await Get.to(() => const CreateLoadPostScreen());
          if (created == true) controller.fetchLoads();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchLoads,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.loads.length,
        itemBuilder: (context, index) {
          final load = controller.loads[index];
          return LoadCardWidget(
            load: load,
            onTap: () => Get.to(
              () => LoadDetailScreen(load: load, service: controller.service),
            ),
            onBidTap: () {
              OfferBottomSheet.show(
                context: context,
                title: 'Submit Offer',
                routeSubtitle: '${load.originCity} → ${load.destinationCity}',
                targetPrice: load.askingPrice,
                onSubmit: (amount, advancePct, terms, remarks) {
                  controller.submitBidOnLoad(
                    load: load,
                    amount: amount,
                    advancePct: advancePct,
                    terms: terms,
                    remarks: remarks,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrucksList(MarketplaceHubController controller) {
    if (controller.trucks.isEmpty) {
      return _buildEmptyState(
        title: 'No Available Trucks',
        subtitle:
            controller.filterOrigin.value != null ||
                controller.filterDestination.value != null
            ? 'No trucks found within ${controller.filterRadiusKm.value.round()} km of the selected route corridor.'
            : 'There are no active truck capacity postings right now.',
        buttonLabel: 'Post Available Truck',
        onButtonTap: () async {
          final created = await Get.to(() => const CreateTruckPostScreen());
          if (created == true) controller.fetchTrucks();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchTrucks,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.trucks.length,
        itemBuilder: (context, index) {
          final truck = controller.trucks[index];
          return TruckCardWidget(
            truck: truck,
            onTap: () => Get.to(
              () =>
                  TruckDetailScreen(truck: truck, service: controller.service),
            ),
            onBookTap: () => Get.to(
              () =>
                  TruckDetailScreen(truck: truck, service: controller.service),
            ),
          );
        },
      ),
    );
  }

  // ─── MY ACTIVITY SECTION (Sub-tabs: My Bids | My Requests | Incoming | My Listings) ───
  Widget _buildMyActivitySection(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Obx(() {
            final subTab = controller.activitySubTabIndex.value;
            final incomingCount = controller.pendingIncomingCount;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _activitySubChip(
                    label: 'My Bids (${controller.myBids.length})',
                    icon: Icons.gavel_outlined,
                    isSelected: subTab == 0,
                    onTap: () => controller.setActivitySubTab(0),
                  ),
                  const SizedBox(width: 8),
                  _activitySubChip(
                    label:
                        'My Booking Requests (${controller.myOutgoingBookings.length})',
                    icon: Icons.outbox_outlined,
                    isSelected: subTab == 1,
                    onTap: () => controller.setActivitySubTab(1),
                  ),
                  const SizedBox(width: 8),
                  _activitySubChip(
                    label:
                        'Incoming Requests (${controller.incomingBookings.length + controller.incomingOffers.length})',
                    icon: Icons.move_to_inbox_outlined,
                    isSelected: subTab == 2,
                    badgeCount: incomingCount,
                    onTap: () => controller.setActivitySubTab(2),
                  ),
                  const SizedBox(width: 8),
                  _activitySubChip(
                    label:
                        'My Listings (${controller.myLoads.length + controller.myTrucks.length})',
                    icon: Icons.list_alt_outlined,
                    isSelected: subTab == 3,
                    onTap: () => controller.setActivitySubTab(3),
                  ),
                ],
              ),
            );
          }),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: Obx(() {
            if (controller.isActivityLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final subTab = controller.activitySubTabIndex.value;
            if (subTab == 0) {
              return _buildMyBidsTab(context, controller);
            } else if (subTab == 1) {
              return _buildMyOutgoingBookingsTab(context, controller);
            } else if (subTab == 2) {
              return _buildIncomingRequestsTab(context, controller);
            } else {
              return _buildMyListingsTab(context, controller);
            }
          }),
        ),
      ],
    );
  }

  Widget _activitySubChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── 1. MY BIDS TAB ───
  Widget _buildMyBidsTab(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    if (controller.myBids.isEmpty) {
      return _buildEmptyState(
        title: 'No Bids Submitted Yet',
        subtitle:
            'Bids and price offers you place on freight loads or trucks will appear here.',
        buttonLabel: 'Browse Loads',
        onButtonTap: () => controller.setTab(0),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: controller.fetchMyActivity,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myBids.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = controller.myBids[index];
          return _buildOfferActivityCard(
            context: context,
            controller: controller,
            offer: offer,
            isIncoming: false,
            currencyFormatter: currencyFormatter,
          );
        },
      ),
    );
  }

  // ─── 2. MY BOOKING REQUESTS TAB (OUTGOING) ───
  Widget _buildMyOutgoingBookingsTab(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    if (controller.myOutgoingBookings.isEmpty) {
      return _buildEmptyState(
        title: 'No Outgoing Booking Requests',
        subtitle:
            'Truck capacity requests you send to transporters will appear here with live approval status.',
        buttonLabel: 'Find Trucks',
        onButtonTap: () => controller.setTab(1),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: controller.fetchMyActivity,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myOutgoingBookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = controller.myOutgoingBookings[index];
          return _buildBookingActivityCard(
            context: context,
            controller: controller,
            booking: booking,
            isIncoming: false,
            currencyFormatter: currencyFormatter,
          );
        },
      ),
    );
  }

  // ─── 3. INCOMING REQUESTS TAB (RECEIVED ON OWNED LISTINGS) ───
  Widget _buildIncomingRequestsTab(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    if (controller.incomingBookings.isEmpty &&
        controller.incomingOffers.isEmpty) {
      return _buildEmptyState(
        title: 'No Incoming Requests Yet',
        subtitle:
            'Booking requests and bids received on your load or truck listings will appear here for approval.',
        buttonLabel: 'Create Listing',
        onButtonTap: () => _showPostChoiceSheet(context, controller),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: controller.fetchMyActivity,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.incomingBookings.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Incoming Booking Requests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ...controller.incomingBookings.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBookingActivityCard(
                  context: context,
                  controller: controller,
                  booking: b,
                  isIncoming: true,
                  currencyFormatter: currencyFormatter,
                ),
              ),
            ),
          ],
          if (controller.incomingOffers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 10),
              child: Text(
                'Incoming Bids & Price Offers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ...controller.incomingOffers.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfferActivityCard(
                  context: context,
                  controller: controller,
                  offer: o,
                  isIncoming: true,
                  currencyFormatter: currencyFormatter,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 4. MY LISTINGS TAB (OWNED LOADS + TRUCKS) ───
  Widget _buildMyListingsTab(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    if (controller.myLoads.isEmpty && controller.myTrucks.isEmpty) {
      return _buildEmptyState(
        title: 'You Have No Active Posts',
        subtitle:
            'Post loads or truck availability to connect with freight partners across India.',
        buttonLabel: 'Create Post',
        onButtonTap: () => _showPostChoiceSheet(context, controller),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchMyActivity,
      color: AppColors.primaryBlue,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.myLoads.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'My Load Postings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ...controller.myLoads.map(
              (load) => LoadCardWidget(
                load: load,
                onTap: () => Get.to(
                  () =>
                      LoadDetailScreen(load: load, service: controller.service),
                ),
                onBidTap: () => Get.to(
                  () =>
                      LoadDetailScreen(load: load, service: controller.service),
                ),
              ),
            ),
          ],
          if (controller.myTrucks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                'My Truck Availability Postings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ...controller.myTrucks.map(
              (truck) => TruckCardWidget(
                truck: truck,
                onTap: () => Get.to(
                  () => TruckDetailScreen(
                    truck: truck,
                    service: controller.service,
                  ),
                ),
                onBookTap: () => Get.to(
                  () => TruckDetailScreen(
                    truck: truck,
                    service: controller.service,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferActivityCard({
    required BuildContext context,
    required MarketplaceHubController controller,
    required MarketplaceOfferModel offer,
    required bool isIncoming,
    required NumberFormat currencyFormatter,
  }) {
    final routeText =
        (offer.originCity != null && offer.destinationCity != null)
        ? '${offer.originCity} → ${offer.destinationCity}'
        : (offer.listingNumber ?? 'Marketplace Listing');
    final counterpartName = isIncoming
        ? (offer.offeredByCompanyName ?? 'Bidder Company')
        : (offer.listingOwnerCompanyName ?? 'Listing Owner');
    final canAct = isIncoming
        ? (offer.status == OfferStatus.PENDING ||
              offer.status == OfferStatus.COUNTERED)
        : (offer.status == OfferStatus.COUNTERED);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      offer.listingNumber ?? (offer.listingType?.name ?? 'BID'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    counterpartName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              _buildOfferStatusBadge(offer.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeText,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (offer.listingAskingPrice != null &&
                        offer.listingAskingPrice! > 0)
                      Text(
                        'Asking Price: ${currencyFormatter.format(offer.listingAskingPrice)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(offer.offeredAmount),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    isIncoming ? 'Offered Rate' : 'Your Bid',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (offer.latestCounterAmount != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      'Latest Counter-Offer: ${currencyFormatter.format(offer.latestCounterAmount)}'
                      '${offer.latestCounterRemarks != null && offer.latestCounterRemarks!.isNotEmpty ? " · ${offer.latestCounterRemarks}" : ""}',
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
          if (offer.remarks != null && offer.remarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Note: ${offer.remarks}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canAct && offer.id != null) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await controller.acceptOffer(offer.id!);
                    if (ok) {
                      Get.snackbar(
                        'Offer Accepted',
                        'Booking has been confirmed from this offer!',
                        backgroundColor: const Color(0xFF059669),
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 15),
                  label: Text(
                    offer.status == OfferStatus.COUNTERED && !isIncoming
                        ? 'Accept Counter'
                        : 'Accept',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    OfferBottomSheet.show(
                      context: context,
                      title: 'Send Counter-Offer',
                      routeSubtitle: routeText,
                      targetPrice:
                          offer.latestCounterAmount ?? offer.offeredAmount,
                      onSubmit: (amount, advancePct, terms, remarks) async {
                        final ok = await controller.sendCounterOffer(
                          offerId: offer.id!,
                          amount: amount,
                          advancePct: advancePct,
                          paymentTerms: terms,
                          remarks: remarks,
                        );
                        if (ok) {
                          Get.snackbar(
                            'Counter-Offer Sent',
                            'Proposed ₹${amount.toStringAsFixed(0)}',
                            backgroundColor: AppColors.primaryBlue,
                            colorText: Colors.white,
                          );
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.swap_horiz, size: 15),
                  label: const Text('Counter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await controller.rejectOffer(offer.id!);
                    if (ok) {
                      Get.snackbar(
                        'Offer Rejected',
                        'Offer has been declined.',
                        backgroundColor: const Color(0xFF991B1B),
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.close, size: 15),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
              TextButton.icon(
                onPressed: () async {
                  final targetCompanyId = isIncoming
                      ? offer.offeredByCompanyId
                      : offer.listingOwnerCompanyId;
                  if (targetCompanyId != null) {
                    final convo = await controller.service.startConversation(
                      listingId: offer.listingId,
                      participantCompanyId: targetCompanyId,
                      initialMessage: 'Regarding offer on $routeText',
                    );
                    if (convo != null && convo.id != null) {
                      Get.to(
                        () => MarketplaceChatScreen(
                          conversationId: convo.id,
                          title: counterpartName,
                        ),
                      );
                      return;
                    }
                  }
                  Get.to(() => const MarketplaceChatScreen());
                },
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
      ),
    );
  }

  Widget _buildBookingActivityCard({
    required BuildContext context,
    required MarketplaceHubController controller,
    required MarketplaceBookingModel booking,
    required bool isIncoming,
    required NumberFormat currencyFormatter,
  }) {
    final routeText =
        (booking.originCity != null && booking.destinationCity != null)
        ? '${booking.originCity} → ${booking.destinationCity}'
        : (booking.bookingNumber ?? 'Booking Request');
    final counterpartName = isIncoming
        ? (booking.requestedByCompanyName ??
              booking.shipperCompanyName ??
              'Requester Company')
        : (booking.listingOwnerCompanyName ??
              booking.transporterCompanyName ??
              'Listing Owner');
    final canApprove =
        isIncoming &&
        (booking.status == BookingStatus.PENDING_APPROVAL ||
            booking.status == BookingStatus.REQUESTED);
    final canRespondCounter =
        !isIncoming && booking.status == BookingStatus.COUNTERED;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () async {
          final changed = await Get.to(
            () => BookingDetailScreen(
              booking: booking,
              isIncomingRequest: isIncoming,
              service: controller.service,
            ),
          );
          if (changed == true) controller.fetchMyActivity();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.bookingNumber ?? 'BOOKING REQ',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      counterpartName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                _buildBookingStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (booking.requestedCapacity != null &&
                          booking.requestedCapacity! > 0)
                        Text(
                          'Requested Capacity: ${booking.requestedCapacity} ${booking.capacityUnit ?? "TONNE"}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(
                        booking.proposedFreight ?? booking.agreedFreight,
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      booking.status == BookingStatus.CONFIRMED
                          ? 'Confirmed'
                          : 'Proposed',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
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
                child: Text(
                  'Counter Freight: ${currencyFormatter.format(booking.counterFreight)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
            if (booking.rejectionReason != null &&
                booking.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Rejection Reason: ${booking.rejectionReason}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF991B1B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((canApprove || canRespondCounter) &&
                    booking.id != null) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await controller.acceptBookingRequest(
                        booking.id!,
                      );
                      if (ok) {
                        Get.snackbar(
                          'Booking Confirmed',
                          'Booking request has been approved and confirmed.',
                          backgroundColor: const Color(0xFF059669),
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 15),
                    label: Text(
                      canRespondCounter ? 'Accept Counter' : 'Accept',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (canApprove)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _promptBookingCounter(context, controller, booking),
                      icon: const Icon(Icons.swap_horiz, size: 15),
                      label: const Text('Counter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _promptBookingReject(context, controller, booking),
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                TextButton.icon(
                  onPressed: () => Get.to(
                    () => BookingDetailScreen(
                      booking: booking,
                      isIncomingRequest: isIncoming,
                      service: controller.service,
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final targetCompanyId = isIncoming
                        ? (booking.requestedByCompanyId ??
                              booking.shipperCompanyId)
                        : (booking.listingOwnerCompanyId ??
                              booking.transporterCompanyId);
                    if (targetCompanyId != null) {
                      final convo = await controller.service.startConversation(
                        bookingId: booking.id,
                        listingId: booking.listingId,
                        participantCompanyId: targetCompanyId,
                        initialMessage:
                            'Regarding booking ${booking.bookingNumber ?? ""}',
                      );
                      if (convo != null && convo.id != null) {
                        Get.to(
                          () => MarketplaceChatScreen(
                            conversationId: convo.id,
                            title: counterpartName,
                          ),
                        );
                        return;
                      }
                    }
                    Get.to(() => const MarketplaceChatScreen());
                  },
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
        ),
      ),
    );
  }

  void _promptBookingCounter(
    BuildContext context,
    MarketplaceHubController controller,
    MarketplaceBookingModel booking,
  ) {
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
      textConfirm: 'Send Counter',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryBlue,
      onConfirm: () async {
        final val = double.tryParse(freightCtrl.text.trim()) ?? 0;
        if (val <= 0 || booking.id == null) return;
        Get.back();
        final ok = await controller.counterBookingRequest(
          booking.id!,
          counterFreight: val,
          remarks: remarksCtrl.text.trim().isNotEmpty
              ? remarksCtrl.text.trim()
              : null,
        );
        if (ok) {
          Get.snackbar(
            'Counter Sent',
            'Counter freight of ₹${val.toStringAsFixed(0)} has been sent.',
            backgroundColor: AppColors.primaryBlue,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _promptBookingReject(
    BuildContext context,
    MarketplaceHubController controller,
    MarketplaceBookingModel booking,
  ) {
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
        final ok = await controller.rejectBookingRequest(
          booking.id!,
          reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : 'Declined',
        );
        if (ok) {
          Get.snackbar(
            'Rejected',
            'Booking request rejected and capacity restored.',
            backgroundColor: const Color(0xFF991B1B),
            colorText: Colors.white,
          );
        }
      },
    );
  }

  Widget _buildOfferStatusBadge(OfferStatus status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFF92400E);
    if (status == OfferStatus.ACCEPTED) {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (status == OfferStatus.COUNTERED) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (status == OfferStatus.REJECTED ||
        status == OfferStatus.WITHDRAWN) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _buildBookingStatusBadge(BookingStatus status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFF92400E);
    if (status == BookingStatus.CONFIRMED ||
        status == BookingStatus.IN_PROGRESS) {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (status == BookingStatus.COUNTERED) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (status == BookingStatus.REJECTED ||
        status == BookingStatus.CANCELLED) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onButtonTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MarketplaceHubController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: controller.fetchMarketplaceFeed,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostFloatingButton(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    return FloatingActionButton.extended(
      onPressed: () => _showPostChoiceSheet(context, controller),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add, size: 20),
      label: const Text(
        'Post on Marketplace',
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _showPostChoiceSheet(
    BuildContext context,
    MarketplaceHubController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              'What would you like to post?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: const Text(
                'Post a Load (Freight Demand)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'I have goods to transport and need a truck',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              onTap: () async {
                Get.back();
                final created = await Get.to(
                  () => const CreateLoadPostScreen(),
                );
                if (created == true) {
                  controller.fetchLoads();
                  controller.fetchMyActivity();
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF059669),
                ),
              ),
              title: const Text(
                'Post Truck Availability',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'I have an empty or returning truck looking for loads',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              onTap: () async {
                Get.back();
                final created = await Get.to(
                  () => const CreateTruckPostScreen(),
                );
                if (created == true) {
                  controller.fetchTrucks();
                  controller.fetchMyActivity();
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _filterDescription(MarketplaceHubController controller) {
    final parts = <String>[];
    if (controller.filterOrigin.value != null)
      parts.add('From ${controller.filterOrigin.value}');
    if (controller.filterDestination.value != null)
      parts.add('To ${controller.filterDestination.value}');
    if (controller.filterCargoType.value != null)
      parts.add(controller.filterCargoType.value!.displayName);
    return parts.join(', ');
  }
}
