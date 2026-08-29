import 'package:cargo_setu/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Module rights and permissions evaluation service.
///
/// Matches the web UI's permission checking architecture:
/// - SuperAdmin & CompanyAdmin have full access to all features.
/// - Matches `${MODULE}_${ACTION}` (e.g., `COMPANY_CREATE`, `CUSTOMER_READ`).
/// - Matches `${MODULE}_ALL` wildcard.
/// - Supports alias actions: `MODIFY` -> `UPDATE`, `VIEW` -> `READ`.
/// - Supports combined `UPDATE_DELETE` permissions.
class PermissionService {
  PermissionService._();

  static SessionService get _session {
    if (Get.isRegistered<SessionService>()) {
      return Get.find<SessionService>();
    }
    return Get.put(SessionService());
  }

  /// Core permission check method.
  static bool hasPermission(String module, String action) {
    return _session.hasPermission(module, action);
  }

  /// Convenience helpers for Company Module
  static bool get canCreateCompany => hasPermission('COMPANY', 'CREATE');
  static bool get canReadCompany => hasPermission('COMPANY', 'READ');
  static bool get canUpdateCompany => hasPermission('COMPANY', 'UPDATE');
  static bool get canDeleteCompany => hasPermission('COMPANY', 'DELETE');

  /// Convenience helpers for Staff Module
  static bool get canReadStaff => hasPermission('STAFF', 'READ');
  static bool get canCreateStaff => hasPermission('STAFF', 'CREATE');
  static bool get canUpdateStaff => hasPermission('STAFF', 'UPDATE');
  static bool get canDeleteStaff => hasPermission('STAFF', 'DELETE');

  /// Convenience helpers for Customer Module
  static bool get canReadCustomer => hasPermission('CUSTOMER', 'READ');
  static bool get canCreateCustomer => hasPermission('CUSTOMER', 'CREATE');
  static bool get canUpdateCustomer => hasPermission('CUSTOMER', 'UPDATE');
  static bool get canDeleteCustomer => hasPermission('CUSTOMER', 'DELETE');

  /// Convenience helpers for Role Module
  static bool get canReadRole => hasPermission('ROLE', 'READ');
  static bool get canCreateRole => hasPermission('ROLE', 'CREATE');
  static bool get canUpdateRole => hasPermission('ROLE', 'UPDATE');
  static bool get canDeleteRole => hasPermission('ROLE', 'DELETE');

  /// Check if current user is SuperAdmin or CompanyAdmin
  static bool get isSuperAdmin => _session.isSuperAdmin;
  static bool get isCompanyAdmin => _session.isCompanyAdmin;
}

/// A reactive widget that conditionally renders [child] only if the user has
/// the specified permission. If denied, optionally renders [fallback] or `SizedBox.shrink()`.
class HasPermission extends StatelessWidget {
  final String module;
  final String action;
  final Widget child;
  final Widget? fallback;

  const HasPermission({
    super.key,
    required this.module,
    required this.action,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final session = Get.find<SessionService>();
      final allowed = session.hasPermission(module, action);
      if (allowed) {
        return child;
      }
      return fallback ?? const SizedBox.shrink();
    });
  }
}
