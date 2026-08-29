import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    final companyCtrl = Get.find<CompanyController>();

    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final userName = session.currentUserName.value.isNotEmpty
            ? session.currentUserName.value
            : "User";
        final email = session.currentEmail.value.isNotEmpty
            ? session.currentEmail.value
            : "Not provided";
        final company = companyCtrl.currentCompany.value;
        final companyName = company?.companyName ?? "No company attached";
        final phone = company?.contactNo1 ?? company?.whatsappNumber ?? "N/A";
        final address = [
          if (company?.city != null) company!.city,
          if (company?.state != null) company!.state,
          if (company?.country != null) company!.country,
        ].join(', ');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// ================= PROFILE HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.15),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: AppTheme.small,
                        color: AppTheme.colorGrey,
                      ),
                    ),
                    if (session.roles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session.roles.first.replaceAll('_', ' '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= PROFILE OPTIONS =================
              _profileTile(
                icon: Icons.phone,
                title: "Contact",
                value: phone,
              ),

              _profileTile(
                icon: Icons.location_on,
                title: "Location",
                value: address.isNotEmpty ? address : "Not specified",
              ),

              _profileTile(
                icon: Icons.business,
                title: "Company",
                value: companyName,
                onTap: company != null
                    ? () => Get.toNamed(AppRoutes.companyProfile)
                    : () => Get.toNamed(AppRoutes.companyCreate),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),

              const SizedBox(height: 20),

              /// ================= ACTION BUTTONS =================
              if (company != null)
                _actionButton(
                  icon: Icons.business_center,
                  title: "Manage Company Profile",
                  onTap: () => Get.toNamed(AppRoutes.companyProfile),
                ),

              _actionButton(
                icon: Icons.settings,
                title: "Settings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              _actionButton(
                icon: Icons.logout,
                title: "Logout",
                isLogout: true,
                onTap: () {
                  session.clearSession();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  /// ================= PROFILE INFO TILE =================
  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.colorWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.small,
                      color: AppTheme.colorGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  /// ================= ACTION BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.colorWhite,
        leading: Icon(
          icon,
          color: isLogout ? AppTheme.colorError : AppColors.primaryBlue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? AppTheme.colorError : AppTheme.colorBlack,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
