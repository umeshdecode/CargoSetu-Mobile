import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                    AppTheme.colorPrimaryTheme.withOpacity(0.15),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.colorPrimaryTheme,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Vivek Mishra",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "vivek@email.com",
                    style: TextStyle(
                      fontSize: AppTheme.small,
                      color: AppTheme.colorGrey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= PROFILE OPTIONS =================
            _profileTile(
              icon: Icons.phone,
              title: "Mobile Number",
              value: "+91 98765 43210",
            ),

            _profileTile(
              icon: Icons.location_on,
              title: "Address",
              value: "Ahmedabad, Gujarat",
            ),

            _profileTile(
              icon: Icons.business,
              title: "Company",
              value: "Cargo Setu Logistics",
            ),

            const SizedBox(height: 24),

            /// ================= ACTION BUTTONS =================
            _actionButton(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () {
                // TODO: Navigate to Edit Profile
              },
            ),

            _actionButton(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {
                // TODO: Navigate to Settings
              },
            ),

            _actionButton(
              icon: Icons.logout,
              title: "Logout",
              isLogout: true,
              onTap: () {
                // TODO: Clear session & navigate to login
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ================= PROFILE INFO TILE =================
  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.colorWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.colorPrimaryTheme),
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
        ],
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
          color: isLogout ? AppTheme.colorError : AppTheme.colorPrimaryTheme,
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
