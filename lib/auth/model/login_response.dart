class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
    );
  }
}
