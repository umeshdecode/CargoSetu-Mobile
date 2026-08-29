/// Token response from the backend auth endpoints.
///
/// Contains JWT access token along with user identity, roles, and permissions.
/// Used by login, OTP verify, and signup auto-login flows.
class LoginResponse {
  final String accessToken;
  final String? tokenType;
  final int? expiresIn;
  final int? expirationTime;
  final int? staffId;
  final String? userName;
  final String? email;
  final List<String> roles;
  final List<String> permissions;

  LoginResponse({
    required this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.expirationTime,
    this.staffId,
    this.userName,
    this.email,
    this.roles = const [],
    this.permissions = const [],
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String?,
      expiresIn: json['expiresIn'] as int?,
      expirationTime: json['expirationTime'] as int?,
      staffId: json['staffId'] as int?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : const [],
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : const [],
    );
  }

  /// Convert to map for session storage.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (tokenType != null) 'tokenType': tokenType,
      if (expiresIn != null) 'expiresIn': expiresIn,
      if (expirationTime != null) 'expirationTime': expirationTime,
      if (staffId != null) 'staffId': staffId,
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
      'roles': roles,
      'permissions': permissions,
    };
  }
}
