import 'dart:convert';

import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Redesigned CargoSetu dashboard matching the Figma design.
///
/// Layout (top → bottom):
/// 1. AppBar: CargoSetu logo + notification bell
/// 2. Business Profile Card (dark navy)
/// 3. Stats Row (Active Trips + Pending Invoices)
/// 4. Find Loads Near Me CTA
/// 5. Customer Management tile
/// 6. Staff Management tile
/// 7. FLEET CONTROL section (Vehicles, Trip Tracking, Driver Mgmt)
/// 8. AUTO-GENERATE DOCUMENTS section (2×2 grid + Shifting Mgmt)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Section Label ──────────────────────────
            Text(
              'YOUR BUSINESS PROFILE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // ─── Business Profile Card ─────────────────
            const _BusinessProfileCard(),
            const SizedBox(height: 18),

            // ─── Stats Row ─────────────────────────────
            const _StatsRow(),
            const SizedBox(height: 18),

            // ─── Find Loads Near Me ────────────────────
            const _FindLoadsCard(),
            const SizedBox(height: 14),

            // ─── Customer Management ───────────────────
            _buildMenuTile(
              icon: Icons.people_outline,
              title: 'Customer Management',
              subtitle: 'Directory & CRM',
              onTap: () {},
            ),
            const SizedBox(height: 10),

            // ─── Staff Management ──────────────────────
            _buildMenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Staff Management',
              subtitle: 'Roles & Permissions',
              onTap: () {},
            ),
            const SizedBox(height: 22),

            // ─── FLEET CONTROL ─────────────────────────
            _buildSectionLabel('FLEET CONTROL'),
            const SizedBox(height: 10),
            _buildFleetCard(
              icon: Icons.local_shipping_outlined,
              label: 'Vehicles',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildFleetCard(
              icon: Icons.route_outlined,
              label: 'Trip Tracking',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildFleetCard(
              icon: Icons.badge_outlined,
              label: 'Driver Mgmt',
              onTap: () {},
            ),
            const SizedBox(height: 22),

            // ─── AUTO-GENERATE DOCUMENTS ───────────────
            _buildSectionLabel('AUTO-GENERATE DOCUMENTS'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDocCard(
                    icon: Icons.calculate_outlined,
                    label: 'Quotations',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDocCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Invoices',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDocCard(
                    icon: Icons.description_outlined,
                    label: 'LR Copies',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDocCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Packing Lists',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFleetCard(
              icon: Icons.swap_horiz_outlined,
              label: 'Shifting Mgmt',
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      titleSpacing: 16,
      title: Row(
        children: [
          // App Logo Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo/app_icon_without_name.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, _) => const Icon(
                  Icons.local_shipping,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Cargo',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Setu',
            style: TextStyle(
              color: AppColors.accentOrange,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF0F172A),
            size: 24,
          ),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 0.5),
      ),
    );
  }

  // ─── Section Label ─────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  // ─── Menu Tile (Customer / Staff) ──────────────────────
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFF334155)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Fleet Control Card ────────────────────────────────
  Widget _buildFleetCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF475569)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Document Card (2-column grid) ─────────────────────
  Widget _buildDocCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF475569)),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BUSINESS PROFILE CARD — Dark navy card with company info
// ══════════════════════════════════════════════════════════
class _BusinessProfileCard extends StatelessWidget {
  const _BusinessProfileCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final companyCtrl = Get.find<CompanyController>();
      final company = companyCtrl.currentCompany.value;

      final name = company?.companyName ?? 'CargoSetu';
      final email = company?.companyEmail ?? '';
      final phone = company?.whatsappNumber ?? company?.contactNo1 ?? '';
      final city = company?.city ?? '';
      final website = company?.website ?? '';
      final logo = company?.logoUrlOrBase64;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Company Name + Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: (logo != null && logo.isNotEmpty)
                        ? _buildLogoImage(logo)
                        : Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'C',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (website.isNotEmpty)
                        _infoRow(Icons.language, website),
                      if (email.isNotEmpty)
                        _infoRow(Icons.email_outlined, email),
                      if (city.isNotEmpty)
                        _infoRow(Icons.location_on_outlined,
                            '$city${company?.state != null ? ", ${company!.state}" : ""}'),
                      if (phone.isNotEmpty)
                        _infoRow(Icons.phone_outlined, _formatPhone(phone)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Manage Company button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.companyProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Manage Company',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Download Card button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Placeholder for card download
                  Get.snackbar(
                    'Coming Soon',
                    'Digital business card download will be available soon.',
                    snackPosition: SnackPosition.TOP,
                  );
                },
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text(
                  'Download Card',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF475569)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPhone(String phone) {
    if (phone.startsWith('+')) return phone;
    if (phone.length >= 10) {
      return '+$phone';
    }
    return phone;
  }

  static Widget _buildLogoImage(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) =>
            const Icon(Icons.business, size: 24, color: Color(0xFF1E293B)),
      );
    }
    try {
      final cleanBase64 =
          source.contains(',') ? source.split(',').last : source;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.business, size: 24, color: Color(0xFF1E293B));
    }
  }
}

// ══════════════════════════════════════════════════════════
//  STATS ROW — Active Trips + Pending Invoices
// ══════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Active Trips',
            count: '14',
            badgeText: 'In Transit',
            badgeColor: const Color(0xFFF97316),
            badgeBgColor: const Color(0xFFFFF7ED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Pending Invoices',
            count: '8',
            badgeText: 'Action Needed',
            badgeColor: const Color(0xFFDC3545),
            badgeBgColor: const Color(0xFFFEF2F2),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String count;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;

  const _StatTile({
    required this.label,
    required this.count,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  FIND LOADS NEAR ME — Highlighted CTA card
// ══════════════════════════════════════════════════════════
class _FindLoadsCard extends StatelessWidget {
  const _FindLoadsCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Find Loads Near Me',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Discover active requirements in your radius.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
