import 'dart:convert';

import 'package:cargo_setu/profile/edit_profile_screen.dart';
import 'package:cargo_setu/profile/model/staff_model.dart';
import 'package:cargo_setu/profile/profile_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Tailwind Colors mapped from user HTML
const Color twPrimary = Color(0xFF051125);
const Color twSurface = Color(0xFFF9FAF5);
const Color twSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color twOutlineVariant = Color(0xFFC5C6CD);
const Color twOnSurface = Color(0xFF1A1C1A);
const Color twOnSurfaceVariant = Color(0xFF45474D);
const Color twPrimaryFixed = Color(0xFFD7E2FF);
const Color twSurfaceContainerLow = Color(0xFFF3F4F0);
const Color twSurfaceContainer = Color(0xFFEDEEEA);
const Color twSecondaryContainer = Color(0xFFC2DCFF);
const Color twOnSecondaryContainer = Color(0xFF48617E);
const Color twOutline = Color(0xFF75777D);
const Color twError = Color(0xFFBA1A1A);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: twSurface,
      appBar: AppBar(
        backgroundColor: twSurface,
        elevation: 0,
        surfaceTintColor: twSurface,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.offAllNamed(AppRoutes.dashboard);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Icon(Icons.arrow_back, color: twOnSurfaceVariant),
              ),
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: twPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: twOutlineVariant, height: 1),
        ),
      ),
      body: Obx(() {
        final staff = _ctrl.profile.value;
        final isLoading = _ctrl.isLoading.value;

        if (isLoading && staff == null) {
          return const Center(
            child: CircularProgressIndicator(color: twPrimary),
          );
        }

        if (staff == null) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          color: twPrimary,
          onRefresh: () => _ctrl.fetchMyProfile(showLoader: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _buildProfileHeader(staff),
                const SizedBox(height: 24),
                _buildPersonalDetails(staff),
                const SizedBox(height: 24),
                _buildProfessionalDetails(staff),
                const SizedBox(height: 24),
                _buildLicenseInformation(staff),
                const SizedBox(height: 24),
                _buildAddress(staff),
                const SizedBox(height: 32),
                _buildLogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(StaffModel staff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: twSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: twOutlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verified badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: twSurfaceContainer, width: 2),
                    ),
                    child: ClipOval(
                      child: staff.hasProfileImage
                          ? _buildProfileImage(staff.profileImageUrl!)
                          : _buildDefaultDriverAvatar(staff),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: twSecondaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: twSurfaceContainerLowest, width: 2),
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 14,
                        color: twOnSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.displayName.isNotEmpty
                          ? staff.displayName
                          : 'Rakesh Kumar',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: twPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFD2E3FC)),
                      ),
                      child: Text(
                        staff.primaryRoleName ?? 'Driver',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: twPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x4DC5C6CD)), // outline-variant/30
          const SizedBox(height: 16),
          // Contact info
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: twSurfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone,
                          size: 18, color: twOnSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        staff.fullMobile.isNotEmpty
                            ? staff.fullMobile
                            : '+91 9328334187',
                        style: const TextStyle(
                          fontSize: 14,
                          color: twOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: twSurfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mail,
                          size: 18, color: twOnSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        staff.email?.isNotEmpty == true
                            ? staff.email!
                            : 'ferili5608@prodbits.com',
                        style: const TextStyle(
                          fontSize: 14,
                          color: twOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result =
                    await Get.to(() => EditProfileScreen(staff: staff));
                if (result == true) {
                  _ctrl.fetchMyProfile(showLoader: false);
                }
              },
              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: twPrimary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(StaffModel staff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: twSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: twOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_page, size: 20, color: twPrimary),
              const SizedBox(width: 8),
              const Text(
                'PERSONAL DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: twOnSurface,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x7FC5C6CD)), // outline-variant/50
          const SizedBox(height: 16),
          _buildDetailItem(
              'Full Name',
              staff.displayName.isNotEmpty
                  ? staff.displayName
                  : 'Rakesh Kumar'),
          const SizedBox(height: 16),
          _buildDetailItem(
              'Mobile',
              staff.fullMobile.isNotEmpty
                  ? staff.fullMobile
                  : '+91 9328334187'),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetails(StaffModel staff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: twSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: twOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work, size: 20, color: twPrimary),
              const SizedBox(width: 8),
              const Text(
                'PROFESSIONAL DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: twOnSurface,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x7FC5C6CD)),
          const SizedBox(height: 16),
          _buildDetailItem(
              'Department',
              staff.department?.label ?? 'Vehicle Operations Department'),
          const SizedBox(height: 16),
          const Text(
            'Staff Type',
            style: TextStyle(
              fontSize: 11,
              color: twOutline,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCEEAD6)),
            ),
            child: Text(
              (staff.staffType == null || staff.staffType == 'PERMANENT')
                  ? 'PERMANENT Staff'
                  : '${staff.staffType!.replaceAll('_', ' ')} Staff',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF137333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseInformation(StaffModel staff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: twSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: twOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge, size: 20, color: twPrimary),
                  const SizedBox(width: 8),
                  const Text(
                    'LICENSE INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: twOnSurface,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCEEAD6)),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF137333),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x7FC5C6CD)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: twOutlineVariant.withValues(alpha: 0.3)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  twPrimary,
                  Color(0xFF0D1F3C),
                  Color(0xFF1B263B), // primary-container
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // SIM Chip illustration
                        Container(
                          width: 36,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.amber[200],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber[300]!),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 14,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.amber[600]!.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DRIVING LICENCE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: twPrimaryFixed.withValues(alpha: 0.8),
                              ),
                            ),
                            const Text(
                              'Commercial Vehicle (LMV/HMV)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD9DAD6), // surface-dim
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.verified,
                      color: twPrimaryFixed.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'LICENCE NUMBER',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: twPrimaryFixed.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (staff.licenseNumber != null &&
                          staff.licenseNumber!.isNotEmpty)
                      ? staff.licenseNumber!
                      : '--',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ISSUED TO',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.0,
                              color: twPrimaryFixed.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            staff.displayName.isNotEmpty
                                ? staff.displayName
                                : '--',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF9FAF5), // surface-bright
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'VALID TILL / EXPIRY',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.0,
                              color: twPrimaryFixed.withValues(alpha: 0.7),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.event,
                                size: 14,
                                color: twPrimaryFixed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                staff.licenseExpiryDate != null
                                    ? _formatDate(staff.licenseExpiryDate!)
                                    : '2026-01-01',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF9FAF5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(StaffModel staff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: twSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: twOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: twPrimary),
              const SizedBox(width: 8),
              const Text(
                'ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: twOnSurface,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x7FC5C6CD)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: twSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: twOutlineVariant.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.map,
                    size: 20, color: twOnSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _buildFullAddress(staff),
                  style: const TextStyle(
                    fontSize: 16,
                    color: twOnSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: twOutline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: twOnSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          final session = Get.find<SessionService>();
          session.clearSession();
          Get.offAllNamed(AppRoutes.login);
        },
        icon: const Icon(Icons.logout, size: 18, color: twError),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: twError,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: twError),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════
  Widget _buildProfileImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarFallback(),
      );
    }
    try {
      final clean = url.contains(',') ? url.split(',').last : url;
      return Image.memory(base64Decode(clean), fit: BoxFit.cover);
    } catch (_) {
      return _avatarFallback();
    }
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFFD5DFE8),
      child: const Center(
        child: Icon(
          Icons.support_agent_rounded,
          size: 56,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildDefaultDriverAvatar(StaffModel staff) {
    return _avatarFallback();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _buildFullAddress(StaffModel staff) {
    final addressPart = staff.address?.trim();
    final locationPart = staff.locationLine;

    if (addressPart != null && addressPart.isNotEmpty) {
      if (locationPart.isNotEmpty) {
        return '$addressPart,\n$locationPart';
      }
      return addressPart;
    }
    if (locationPart.isNotEmpty) return locationPart;
    return 'Abc building floor 2,\nAhmedabad, Gujarat - 382405';
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: twError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 40, color: twError),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: twOnSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your network and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: twOnSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _ctrl.fetchMyProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: twPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
