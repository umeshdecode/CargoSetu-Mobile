/// Staff / user profile models mirroring the backend `StaffDTO`.
///
/// Endpoint reference:
/// - `GET    /api/v2/cargosetu/staff/myprofile`
/// - `PUT    /api/v2/cargosetu/staff/myprofile`
/// - `POST   /api/v2/cargosetu/staff/myprofile/image` (multipart)
/// - `DELETE /api/v2/cargosetu/staff/myprofile/image`
/// - `GET    /api/v2/cargosetu/staff/{staffId}`
/// - `PUT    /api/v2/cargosetu/staff/{staffId}`
class StaffModel {
  final int? staffId;
  final String? uuid;
  final String? userName;
  final String firstName;
  final String lastName;
  final String? mobileCode;
  final String? mobileNumber;
  final String? email;
  final String? staffType;
  final bool isActive;

  /// Viewable (public or presigned) photo URL. Server-generated, read-only.
  final String? profileImageUrl;

  /// Raw S3 object key behind [profileImageUrl]. Send this back on writes.
  final String? profileImageKey;

  final String? alternateMobile;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? licenseNumber;
  final DateTime? licenseExpiryDate;
  final DateTime? lastLoginAt;
  final int? companyId;
  final int? salary;
  final StaffDepartment? department;
  final List<StaffRole> roles;

  const StaffModel({
    this.staffId,
    this.uuid,
    this.userName,
    this.firstName = '',
    this.lastName = '',
    this.mobileCode,
    this.mobileNumber,
    this.email,
    this.staffType,
    this.isActive = true,
    this.profileImageUrl,
    this.profileImageKey,
    this.alternateMobile,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.licenseNumber,
    this.licenseExpiryDate,
    this.lastLoginAt,
    this.companyId,
    this.salary,
    this.department,
    this.roles = const [],
  });

  // ─── DERIVED DISPLAY HELPERS ────────────────────────────

  /// "First Last", falling back to the username when both names are empty.
  String get fullName {
    final name = '${firstName.trim()} ${lastName.trim()}'.trim();
    if (name.isNotEmpty) return name;
    return userName?.trim() ?? '';
  }

  /// Best available label for the user, never empty.
  String get displayName => fullName.isNotEmpty ? fullName : 'User';

  /// Up to two uppercase letters for the avatar fallback.
  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    final source = fullName.isNotEmpty ? fullName : 'U';
    return source[0].toUpperCase();
  }

  /// "+91 9876543210", or just the number when no code is stored.
  String get fullMobile {
    final number = mobileNumber?.trim() ?? '';
    if (number.isEmpty) return '';
    final code = mobileCode?.trim() ?? '';
    if (code.isEmpty) return number;
    return '${code.startsWith('+') ? code : '+$code'} $number';
  }

  /// "City, State — 400001" built from whichever parts exist.
  String get locationLine {
    final parts = [city, state].where((p) => p != null && p.trim().isNotEmpty);
    final joined = parts.join(', ');
    final pin = pincode?.trim() ?? '';
    if (joined.isEmpty) return pin;
    return pin.isEmpty ? joined : '$joined — $pin';
  }

  /// Human-readable primary role, e.g. "Company Admin".
  String? get primaryRoleName {
    if (roles.isEmpty) return null;
    final role = roles.first;
    final label = role.roleName?.trim();
    if (label != null && label.isNotEmpty) return label;
    return role.code?.replaceAll('_', ' ');
  }

  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.trim().isNotEmpty;

  // ─── JSON ───────────────────────────────────────────────

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      staffId: _asInt(json['staffId']),
      uuid: _asString(json['uuid']),
      userName: _asString(json['userName']),
      firstName: _asString(json['firstName']) ?? '',
      lastName: _asString(json['lastName']) ?? '',
      mobileCode: _asString(json['mobileCode']),
      mobileNumber: _asString(json['mobileNumber']),
      email: _asString(json['email']),
      staffType: _asString(json['staffType']),
      isActive: json['isActive'] == true,
      profileImageUrl: _asString(json['profileImageUrl']),
      profileImageKey: _asString(json['profileImageKey']),
      alternateMobile: _asString(json['alternateMobile']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      state: _asString(json['state']),
      pincode: _asString(json['pincode']),
      licenseNumber: _asString(json['licenseNumber']),
      licenseExpiryDate: _asDate(json['licenseExpiryDate']),
      lastLoginAt: _asDate(json['lastLoginAt']),
      companyId: _asInt(json['companyId']),
      salary: _asInt(json['salary']),
      department: json['department'] is Map<String, dynamic>
          ? StaffDepartment.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(StaffRole.fromJson)
              .toList() ??
          const [],
    );
  }

  /// Payload for `PUT /staff/myprofile`.
  ///
  /// The backend applies only non-blank values, so nulls are stripped. Fields a
  /// staff member may not change about themselves (roles, company, salary,
  /// staffType, isActive, password) are deliberately never sent.
  Map<String, dynamic> toMyProfileJson() {
    final json = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileCode': mobileCode,
      'mobileNumber': mobileNumber,
      'alternateMobile': alternateMobile,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': _dateOnly(licenseExpiryDate),
    };
    json.removeWhere((_, v) => v == null || (v is String && v.trim().isEmpty));
    return json;
  }

  /// Full payload for the admin route `PUT /staff/{staffId}`.
  ///
  /// `profileImageKey` carries the stored S3 key so the photo survives the
  /// update — the server ignores `profileImageUrl` on writes.
  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'uuid': uuid,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileCode': mobileCode,
      'mobileNumber': mobileNumber,
      'alternateMobile': alternateMobile,
      'staffType': staffType,
      'isActive': isActive,
      'profileImageKey': profileImageKey,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': _dateOnly(licenseExpiryDate),
      'companyId': companyId,
      'salary': salary,
      'department': department?.toJson(),
      'roleIds': roles.map((r) => r.roleId).whereType<int>().toList(),
    };
  }

  StaffModel copyWith({
    int? staffId,
    String? uuid,
    String? userName,
    String? firstName,
    String? lastName,
    String? mobileCode,
    String? mobileNumber,
    String? email,
    String? staffType,
    bool? isActive,
    String? profileImageUrl,
    String? profileImageKey,
    bool clearProfileImage = false,
    String? alternateMobile,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    DateTime? lastLoginAt,
    int? companyId,
    int? salary,
    StaffDepartment? department,
    List<StaffRole>? roles,
  }) {
    return StaffModel(
      staffId: staffId ?? this.staffId,
      uuid: uuid ?? this.uuid,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileCode: mobileCode ?? this.mobileCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      staffType: staffType ?? this.staffType,
      isActive: isActive ?? this.isActive,
      profileImageUrl:
          clearProfileImage ? null : (profileImageUrl ?? this.profileImageUrl),
      profileImageKey:
          clearProfileImage ? null : (profileImageKey ?? this.profileImageKey),
      alternateMobile: alternateMobile ?? this.alternateMobile,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      companyId: companyId ?? this.companyId,
      salary: salary ?? this.salary,
      department: department ?? this.department,
      roles: roles ?? this.roles,
    );
  }

}

// ─── PARSE HELPERS ────────────────────────────────────────

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty || text == 'null' ? null : text;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Accepts `yyyy-MM-dd` (LocalDate) and ISO date-times (LocalDateTime).
DateTime? _asDate(dynamic value) {
  final text = _asString(value);
  if (text == null) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

String? _dateOnly(DateTime? date) {
  if (date == null) return null;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Slim view of the backend `RolesDTO` — permissions are handled by
/// `SessionService`, so only the labels are kept here.
class StaffRole {
  final int? roleId;
  final String? code;
  final String? roleName;
  final String? description;
  final String? scope;

  const StaffRole({
    this.roleId,
    this.code,
    this.roleName,
    this.description,
    this.scope,
  });

  factory StaffRole.fromJson(Map<String, dynamic> json) => StaffRole(
        roleId: _asInt(json['roleId']),
        code: _asString(json['code']),
        roleName: _asString(json['roleName']),
        description: _asString(json['description']),
        scope: _asString(json['scope']),
      );

  Map<String, dynamic> toJson() => {
        'roleId': roleId,
        'code': code,
        'roleName': roleName,
        'description': description,
        'scope': scope,
      };

  /// "Company Admin" from either the stored name or the code.
  String get label {
    final name = roleName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final raw = code?.trim() ?? '';
    if (raw.isEmpty) return '';
    return raw
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

/// Slim view of the backend `DepartmentDTO`.
class StaffDepartment {
  final int? departmentId;
  final String? departmentUuid;
  final String? code;
  final String? name;
  final String? description;

  const StaffDepartment({
    this.departmentId,
    this.departmentUuid,
    this.code,
    this.name,
    this.description,
  });

  factory StaffDepartment.fromJson(Map<String, dynamic> json) =>
      StaffDepartment(
        departmentId: _asInt(json['departmentId']),
        departmentUuid: _asString(json['departmentUuid']),
        code: _asString(json['code']),
        name: _asString(json['name']),
        description: _asString(json['description']),
      );

  Map<String, dynamic> toJson() => {
        'departmentId': departmentId,
        'departmentUuid': departmentUuid,
        'code': code,
        'name': name,
        'description': description,
      };

  String get label => name?.trim().isNotEmpty == true
      ? name!.trim()
      : (code?.trim() ?? '');
}
