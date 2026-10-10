import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/marketplace_hub_controller.dart';
import '../widgets/load_card_widget.dart';
import '../widgets/truck_card_widget.dart';
import '../widgets/marketplace_filter_sheet.dart';
import '../widgets/offer_bottom_sheet.dart';
import 'create_load_post_screen.dart';
import 'create_truck_post_screen.dart';
import 'load_detail_screen.dart';
import 'truck_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'marketplace_wallet_screen.dart';
import 'marketplace_chat_screen.dart';

/// Central discovery hub for the CargoSetu Two-Sided Marketplace.
/// Enables shippers to discover available truck capacity and truckers to find freight loads.
/// Strictly follows design guidelines: zero raw primary keys shown to users,
/// clean visual typography, and intuitive high-contrast badges.
class MarketplaceHubScreen extends StatelessWidget {
  const MarketplaceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketplaceHubController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          // ─── Segmented Tab Switcher ───
          _buildSegmentedTabs(controller),

          // ─── Active Filter Indicator Chip (if any) ───
          Obx(() {
            final hasFilters = controller.filterOrigin.value != null ||
                controller.filterDestination.value != null ||
                controller.filterCargoType.value != null;

            if (!hasFilters) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 14, color: AppColors.primaryBlue),
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
                  InkWell(
                    onTap: controller.clearFilters,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            );
          }),

          // ─── Feed Content ───
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(controller);
              }

              final tab = controller.currentTabIndex.value;
              if (tab == 0) {
                return _buildLoadsList(controller);
              } else if (tab == 1) {
                return _buildTrucksList(controller);
              } else {
                return _buildMyPostsList(controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: _buildPostFloatingButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MarketplaceHubController controller) {
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
          final hasFilters = controller.filterOrigin.value != null ||
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
                cargoType: controller.filterCargoType.value,
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
              Get.to(() => const MyBookingsScreen());
            } else if (val == 'wallet') {
              Get.to(() => const MarketplaceWalletScreen());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'bookings',
              child: Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFF334155)),
                  SizedBox(width: 10),
                  Text('My Bookings', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'wallet',
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF334155)),
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
                title: 'My Posts',
                icon: Icons.assignment_outlined,
                isSelected: activeTab == 2,
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
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                ),
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
        subtitle: 'There are no active freight load postings matching your filters right now.',
        buttonLabel: 'Post a Load',
        onButtonTap: () => Get.to(() => const CreateLoadPostScreen()),
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
            onTap: () => Get.to(() => LoadDetailScreen(load: load)),
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
        subtitle: 'There are no active truck capacity postings right now.',
        buttonLabel: 'Post Available Truck',
        onButtonTap: () => Get.to(() => const CreateTruckPostScreen()),
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
            onTap: () => Get.to(() => TruckDetailScreen(truck: truck)),
            onBookTap: () => Get.to(() => TruckDetailScreen(truck: truck)),
          );
        },
      ),
    );
  }

  Widget _buildMyPostsList(MarketplaceHubController controller) {
    if (controller.myLoads.isEmpty) {
      return _buildEmptyState(
        title: 'You Have No Active Posts',
        subtitle: 'Post loads or truck availability to connect with freight partners across India.',
        buttonLabel: 'Create Post',
        onButtonTap: () => _showPostChoiceSheet(Get.context!),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchMyListings,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myLoads.length,
        itemBuilder: (context, index) {
          final load = controller.myLoads[index];
          return LoadCardWidget(
            load: load,
            onTap: () => Get.to(() => LoadDetailScreen(load: load)),
            onBidTap: () => Get.to(() => LoadDetailScreen(load: load)),
          );
        },
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
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildPostFloatingButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showPostChoiceSheet(context),
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

  void _showPostChoiceSheet(BuildContext context) {
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
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue),
              ),
              title: const Text(
                'Post a Load (Freight Demand)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'I have goods to transport and need a truck',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              onTap: () {
                Get.back();
                Get.to(() => const CreateLoadPostScreen());
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
                child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF059669)),
              ),
              title: const Text(
                'Post Truck Availability',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'I have an empty or returning truck looking for loads',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              onTap: () {
                Get.back();
                Get.to(() => const CreateTruckPostScreen());
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
    if (controller.filterOrigin.value != null) parts.add('From ${controller.filterOrigin.value}');
    if (controller.filterDestination.value != null) parts.add('To ${controller.filterDestination.value}');
    if (controller.filterCargoType.value != null) parts.add(controller.filterCargoType.value!.displayName);
    return parts.join(', ');
  }
}
