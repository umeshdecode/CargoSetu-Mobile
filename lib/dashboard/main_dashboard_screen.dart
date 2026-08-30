import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/no_company_screen.dart';
import 'package:cargo_setu/dashboard/dashboard.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main dashboard shell with bottom navigation bar.
///
/// Bottom nav tabs: Home, Documents, Loads, Profile
/// Gates access: if user has no company, shows [NoCompanyScreen] instead.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const _ComingSoonPlaceholder(
      icon: Icons.description_outlined,
      title: 'Documents',
      subtitle: 'Generate LR copies, invoices,\nquotations and packing lists.',
    ),
    const _ComingSoonPlaceholder(
      icon: Icons.local_shipping_outlined,
      title: 'Loads',
      subtitle: 'Find and manage freight loads\nnear your location.',
    ),
    const _ComingSoonPlaceholder(
      icon: Icons.person_outline,
      title: 'Profile',
      subtitle: 'View and manage your\naccount settings.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initCompanyCheck();
  }

  void _initCompanyCheck() {
    final companyCtrl = Get.put(CompanyController());
    companyCtrl.fetchCurrentCompany();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompanyController>(
      init: Get.find<CompanyController>(),
      builder: (companyCtrl) {
        return Obx(() {
          // Company check gate: show create company screen if no company
          if (!companyCtrl.hasCompany.value && !companyCtrl.isLoading.value) {
            return const NoCompanyScreen();
          }

          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedFontSize: 11.5,
                unselectedFontSize: 11.5,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.home_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.home_filled, size: 22),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.description_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.description, size: 22),
                    ),
                    label: 'Documents',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.local_shipping_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.local_shipping, size: 22),
                    ),
                    label: 'Loads',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.person_outline, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.person, size: 22),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
//  Coming Soon Placeholder for unimplemented tabs
// ──────────────────────────────────────────────────────────
class _ComingSoonPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoonPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 0.5),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction_outlined,
                        size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      'This module is under development',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
