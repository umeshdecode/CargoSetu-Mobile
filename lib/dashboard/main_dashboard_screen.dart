import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/no_company_screen.dart';
import 'package:cargo_setu/dashboard/dashboard.dart';
import 'package:cargo_setu/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../orders/order_list_screen.dart';
import 'notification_screen.dart';

/// Main dashboard shell with bottom navigation.
///
/// Gates access: if user has no company, shows [NoCompanyScreen] instead.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    OrdersListScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initCompanyCheck();
  }

  /// Ensure CompanyController is initialized and fetch company data.
  void _initCompanyCheck() {
    final companyCtrl = Get.put(CompanyController());
    // Fetch company on dashboard load (ensures fresh data)
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
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping_outlined),
                  label: "Orders",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none),
                  label: "Alerts",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "Profile",
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
