import 'dart:convert';
import 'dart:developer';

import 'package:cargo_setu/auth/login_controller.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Centralized session management service.
///
/// Manages user authentication state, token storage, and user profile data.
/// Parses JWT token claims to extract roles, permissions, and company info.
/// Initialize in main() with `Get.put(SessionService())`.
class SessionService extends GetxService {
  final GetStorage _storage = GetStorage();

  // ─── REACTIVE STATE ───────────────────────────────────────
  final RxBool isLoggedIn = false.obs;
  final RxBool hasCompany = false.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentEmail = ''.obs;
  final RxInt currentStaffId = 0.obs;
  final RxList<String> roles = <String>[].obs;
  final RxList<String> permissions = <String>[].obs;

  /// Viewable profile photo URL, kept in sync by `ProfileController`.
  ///
  /// Not persisted — presigned URLs expire, so it is repopulated from the
  /// cached profile on start-up and refreshed on every profile fetch.
  final RxString currentProfileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    if (isLoggedIn.value) {
      _proactiveTokenRefresh();
    }
  }

  /// Silently refresh the token in the background so the user stays logged in
  Future<void> _proactiveTokenRefresh() async {
    try {
      final data = await ApiRequest().refreshToken();
      if (data != null) {
        log('🔄 Background token refresh succeeded — session extended');
      }
    } catch (e) {
      log('⚠️ Background token refresh check: $e');
    }
  }

  /// Load session data from persistent storage.
  void _loadFromStorage() {
    final token = _storage.read(Constant.token);
    isLoggedIn.value = token != null && token.toString().isNotEmpty;

    final cachedCompanyStatus = _storage.read(Constant.companyStatus);
    hasCompany.value =
        cachedCompanyStatus == true || cachedCompanyStatus == 'true';

    currentUserName.value = _storage.read(Constant.userName) ?? '';
    currentEmail.value = _storage.read(Constant.userEmail) ?? '';
    currentStaffId.value = _storage.read(Constant.staffId) ?? 0;

    // Load roles and permissions
    final storedRoles = _storage.read(Constant.userRoles);
    if (storedRoles != null) {
      roles.value = List<String>.from(
        storedRoles is String ? jsonDecode(storedRoles) : storedRoles,
      );
    }

    final storedPerms = _storage.read(Constant.userPermissions);
    if (storedPerms != null) {
      permissions.value = List<String>.from(
        storedPerms is String ? jsonDecode(storedPerms) : storedPerms,
      );
    }
  }

  /// Save session data from a login/token response.
  ///
  /// Expects the response data map containing:
  /// `accessToken`, `staffId`, `userName`, `email`, `roles`, `permissions`
  void saveSession(Map<String, dynamic> tokenResponse) {
    final token = tokenResponse['accessToken'] as String?;
    if (token == null || token.isEmpty) return;

    // Store token
    _storage.write(Constant.token, token);
    isLoggedIn.value = true;

    // Store user info
    final staffIdVal = tokenResponse['staffId'];
    if (staffIdVal != null) {
      final id = staffIdVal is int ? staffIdVal : int.tryParse('$staffIdVal') ?? 0;
      _storage.write(Constant.staffId, id);
      currentStaffId.value = id;
    }

    final userName = tokenResponse['userName'] as String? ?? '';
    _storage.write(Constant.userName, userName);
    currentUserName.value = userName;

    final email = tokenResponse['email'] as String? ?? '';
    _storage.write(Constant.userEmail, email);
    currentEmail.value = email;

    // Store roles
    final rolesList = tokenResponse['roles'];
    if (rolesList is List) {
      final roleStrings = rolesList.map((r) => r.toString().toUpperCase()).toList();
      _storage.write(Constant.userRoles, jsonEncode(roleStrings));
      roles.value = List<String>.from(roleStrings);
    }

    // Store permissions
    final permsList = tokenResponse['permissions'];
    if (permsList is List) {
      final permStrings = permsList.map((p) => p.toString().toUpperCase()).toList();
      _storage.write(Constant.userPermissions, jsonEncode(permStrings));
      permissions.value = List<String>.from(permStrings);
    }

    // Store full session for reference
    _storage.write(Constant.userSession, jsonEncode(tokenResponse));

    log('✅ Session saved: user=$userName, staffId=$staffIdVal, '
        'roles=${roles.length}, permissions=${permissions.length}');
  }

  /// Update company status.
  void setCompanyStatus(bool status) {
    hasCompany.value = status;
    _storage.write(Constant.companyStatus, status);
  }

  /// Keep the cached identity in step with a freshly fetched/edited profile so
  /// the drawer and dashboard header do not show stale details.
  ///
  /// Pass an empty string to clear the photo.
  void updateIdentity({
    String? userName,
    String? email,
    String? profileImageUrl,
  }) {
    if (userName != null && userName.trim().isNotEmpty) {
      currentUserName.value = userName.trim();
      _storage.write(Constant.userName, userName.trim());
    }
    if (email != null && email.trim().isNotEmpty) {
      currentEmail.value = email.trim();
      _storage.write(Constant.userEmail, email.trim());
    }
    if (profileImageUrl != null) {
      currentProfileImage.value = profileImageUrl.trim();
    }
  }

  /// Clear all session data (logout).
  void clearSession() {
    _storage.remove(Constant.token);
    _storage.remove(Constant.userSession);
    _storage.remove(Constant.staffInfo);
    _storage.remove(Constant.companyStatus);
    _storage.remove(Constant.companyData);
    _storage.remove(Constant.refreshTokenKey);
    _storage.remove(Constant.userRoles);
    _storage.remove(Constant.userPermissions);
    _storage.remove(Constant.staffId);
    _storage.remove(Constant.userName);
    _storage.remove(Constant.userEmail);

    isLoggedIn.value = false;
    hasCompany.value = false;
    currentUserName.value = '';
    currentEmail.value = '';
    currentStaffId.value = 0;
    currentProfileImage.value = '';
    roles.clear();
    permissions.clear();

    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }

    log('🔒 Session cleared');
  }

  /// Check if user is a SuperAdmin or CompanyAdmin.
  bool get isSuperAdmin {
    return roles.any(
      (r) => r == 'SUPERADMIN' || r == 'SUPER_ADMIN' || r == 'ADMIN',
    );
  }

  bool get isCompanyAdmin {
    return roles.any(
      (r) => r == 'COMPANY_ADMIN' || r == 'COMPANYADMIN',
    );
  }

  /// Check if user has a specific permission.
  ///
  /// Matches against:
  /// - SuperAdmin/CompanyAdmin bypass
  /// - Exact match: `MODULE_ACTION` (e.g. COMPANY_CREATE)
  /// - Wildcard: `MODULE_ALL` (e.g. COMPANY_ALL)
  /// - Combined: `MODULE_UPDATE_DELETE` for UPDATE or DELETE
  /// - VIEW alias for READ
  bool hasPermission(String module, String action) {
    // SuperAdmin / CompanyAdmin bypass
    if (isSuperAdmin || isCompanyAdmin) return true;

    final mod = module.toUpperCase().replaceAll(' ', '_');
    String act = action.toUpperCase();

    // Normalize aliases
    if (act == 'MODIFY') act = 'UPDATE';
    if (act == 'VIEW') act = 'READ';

    final permSet = permissions.map((p) => p.toUpperCase()).toSet();

    // Exact match
    if (permSet.contains('${mod}_$act')) return true;

    // Wildcard
    if (permSet.contains('${mod}_ALL')) return true;

    // Combined UPDATE_DELETE
    if ((act == 'UPDATE' || act == 'DELETE') &&
        permSet.contains('${mod}_UPDATE_DELETE')) {
      return true;
    }

    // READ aliases
    if (act == 'READ') {
      if (permSet.contains('${mod}_VIEW') ||
          permSet.contains('${mod}_READ') ||
          permSet.contains(mod)) {
        return true;
      }
    }

    return false;
  }
}
