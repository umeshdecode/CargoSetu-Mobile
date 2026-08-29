import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/orders/order_list_screen.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/shippment/create_shippment_screen.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    final companyCtrl = Get.find<CompanyController>();

    return Drawer(
      backgroundColor: AppTheme.colorWhite,
      child: Column(
        children: [
          /// 🔹 HEADER (Real User & Company Info)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Obx(() {
              final userName = session.currentUserName.value.isNotEmpty
                  ? session.currentUserName.value
                  : "User";
              final email = session.currentEmail.value.isNotEmpty
                  ? session.currentEmail.value
                  : "user@cargosetu.com";
              final company = companyCtrl.currentCompany.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (company != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        company.companyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),

          /// 🔹 MENU ITEMS
          _drawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            onTap: () => Navigator.pop(context),
          ),

          _drawerItem(
            context,
            icon: Icons.business_outlined,
            title: "Company Profile",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.companyProfile);
            },
          ),

          _drawerItem(
            context,
            icon: Icons.add_box_outlined,
            title: "Create Shipment",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateShipmentScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: "My Orders",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrdersListScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          const Divider(),

          _drawerItem(
            context,
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
            onTap: () {
              session.clearSession();
              Get.offAllNamed(AppRoutes.login);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : AppTheme.colorBlack,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : AppTheme.colorBlack,
        ),
      ),
      onTap: onTap,
    );
  }
}
