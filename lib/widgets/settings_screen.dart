import 'package:cargo_setu/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Appearance"),

          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Obx(() {
              final controller = Get.find<ThemeController>();
              return Switch(
                value: controller.isDarkMode.value,
                onChanged: (_) => controller.toggleTheme(),
              );
            }),
          ),

          const SizedBox(height: 16),

          _sectionTitle("Preferences"),

          _settingsTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
              },
            ),
          ),

          const SizedBox(height: 16),

          _sectionTitle("About"),

          _settingsTile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle: "v1.0.0",
          ),

          _settingsTile(
            icon: Icons.support_agent_outlined,
            title: "Support",
            onTap: () {
              // Navigate to support screen later
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppTheme.medium,
          fontWeight: FontWeight.w600,
          color: AppTheme.colorGrey,
        ),
      ),
    );
  }

  /// 🔹 SETTINGS TILE
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.colorWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.colorPrimaryTheme),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
