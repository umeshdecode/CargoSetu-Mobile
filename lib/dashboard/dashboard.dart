import 'dart:convert';

import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.bgLight,
      appBar: _appBar(context),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActiveWorkspaceCard(),
            SizedBox(height: 24),
            _QuickActionsGrid(),
            SizedBox(height: 32),
            _RecentActivityList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.white,
      toolbarHeight: 60,
      titleSpacing: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: const Row(
        children: [
          Text(
            "Cargo",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Setu",
            style: TextStyle(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Obx(() {
            final companyCtrl = Get.find<CompanyController>();
            final company = companyCtrl.currentCompany.value;
            final logo = company?.logoUrlOrBase64;
            final initial = company?.companyName.isNotEmpty == true
                ? company!.companyName[0].toUpperCase()
                : 'C';

            return IconButton(
              onPressed: () => Get.toNamed(AppRoutes.companyProfile),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue,
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: (logo != null && logo.isNotEmpty)
                      ? _buildLogoImage(logo)
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  static Widget _buildLogoImage(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.business, size: 18, color: Colors.white),
      );
    }
    try {
      final cleanBase64 =
          source.contains(',') ? source.split(',').last : source;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.business, size: 18, color: Colors.white);
    }
  }
}

////////////////////////
/// ACTIVE WORKSPACE CARD — reads from CompanyController
////////////////////////
class _ActiveWorkspaceCard extends StatelessWidget {
  const _ActiveWorkspaceCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final companyCtrl = Get.find<CompanyController>();
      final company = companyCtrl.currentCompany.value;

      final name = company?.companyName ?? 'Your Company';
      final email = company?.companyEmail ?? '';
      final logo = company?.logoUrlOrBase64;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: AppColors.accentOrange, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW (LOGO + INFO)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: (logo != null && logo.isNotEmpty)
                        ? DashboardScreen._buildLogoImage(logo)
                        : const Icon(
                            Icons.business_rounded,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          _Chip(
                            text: 'Transport',
                            bg: Color(0xFFF1F5F9),
                            color: Color(0xFF334155),
                          ),
                          SizedBox(width: 6),
                          _Chip(
                            text: '● Active',
                            bg: Color(0xFFE6F9EC),
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(AppRoutes.companyProfile),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Manage Company",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlueDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Open Dashboard",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color color;

  const _Chip({
    required this.text,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

////////////////////////
/// QUICK ACTIONS GRID
////////////////////////
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _actions.length,
          padding: const EdgeInsets.only(bottom: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final item = _actions[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: item.color.withValues(alpha: 0.12),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

////////////////////////
/// RECENT ACTIVITY
////////////////////////
class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._activities.map(
          (a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        a.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: a.status),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == "Paid"
        ? AppColors.success
        : status == "Pending"
            ? AppColors.info
            : AppColors.accentOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

////////////////////////
/// DATA
////////////////////////
class _DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _DashboardAction(this.title, this.subtitle, this.icon, this.color);
}

class _ActivityItem {
  final String title;
  final String time;
  final String status;

  _ActivityItem(this.title, this.time, this.status);
}

final _actions = [
  _DashboardAction(
      "Manage Staff", "Team roles", Icons.people_outline, AppColors.primaryBlue),
  _DashboardAction("Vehicles", "Fleet", Icons.local_shipping_outlined,
      AppColors.primaryBlue),
  _DashboardAction("Create Customer", "Register client", Icons.person_add_outlined,
      AppColors.primaryBlue),
  _DashboardAction("Generate Bilty", "LR note", Icons.receipt_outlined,
      AppColors.accentOrange),
  _DashboardAction("Quotation", "Estimate costs", Icons.calculate_outlined,
      AppColors.accentOrange),
  _DashboardAction("Invoicing", "Billing", Icons.attach_money_outlined,
      AppColors.accentOrange),
  _DashboardAction(
    "Other Type Bills",
    "Packaging list/others",
    Icons.description_outlined,
    AppColors.accentOrange,
  ),
];

final _activities = [
  _ActivityItem("Bilty: BT-9902", "10 mins ago", "Generated"),
  _ActivityItem("Invoice: INV-441", "2 hrs ago", "Paid"),
  _ActivityItem("Quotation: QT-102", "5 hrs ago", "Pending"),
];
