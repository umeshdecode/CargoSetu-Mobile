import 'package:cargo_setu/orders/order_list_screen.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/shippment/create_shippment_screen.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final GetStorage getStorage = GetStorage();
   AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.colorWhite,
      child: Column(
        children: [
          /// 🔹 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.colorPrimaryTheme,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 32),
                ),
                SizedBox(height: 12),
                Text(
                  "Vivek Mishra",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "cargo@setu.com",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
              getStorage.remove(Constant.USER_DATA);
              getStorage.remove(Constant.USER_TOKEN);
              getStorage.remove(Constant.USER_SERVICES_AREA);
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
