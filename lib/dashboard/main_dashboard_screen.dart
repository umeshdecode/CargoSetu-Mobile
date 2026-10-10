import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/no_company_screen.dart';
import 'package:cargo_setu/dashboard/dashboard.dart';
import 'package:cargo_setu/profile/profile_screen.dart';
import 'package:cargo_setu/marketplace/screens/marketplace_hub_screen.dart';
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
    const MarketplaceHubScreen(),
    const ProfileScreen(),
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
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFD0E3FB),
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      );
                    }
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(
                        size: 22,
                        color: Color(0xFF0F172A),
                      );
                    }
                    return const IconThemeData(
                      size: 22,
                      color: Color(0xFF64748B),
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 65,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.description_outlined),
                      selectedIcon: Icon(Icons.description),
                      label: 'Documents',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.local_shipping_outlined),
                      selectedIcon: Icon(Icons.local_shipping),
                      label: 'Loads',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
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
