/// All API endpoint URLs for the CargoSetu backend.
class Urls {
  static const String baseUrl = "http://192.168.1.6:31201";
  // static const String baseUrl = "https://gameless-vacillating-stevie.ngrok-free.dev";

  // ─── AUTH ───────────────────────────────────────────────
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/user/register";
  static const String sendOtp = "$baseUrl/auth/otp/send";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String checkUser = "$baseUrl/auth/check-user";
  static const String googleLogin = "$baseUrl/auth/google/login";
  static const String googleSignup = "$baseUrl/auth/google/signup";

  // ─── TOKEN ──────────────────────────────────────────────
  static const String refreshToken = "$baseUrl/api/v2/cargosetu/refreshtoken";

  // ─── COMPANY ────────────────────────────────────────────
  static const String company = "$baseUrl/api/v2/cargosetu/company";
  static const String currentCompany = "$company/currentCompany";

  // ─── BRANCHES ───────────────────────────────────────────
  static const String branches = "$baseUrl/api/v2/cargosetu/branches";

  // ─── ROLES & PERMISSIONS ────────────────────────────────
  static const String roles = "$baseUrl/api/v2/cargosetu/role";
  static const String permissions = "$baseUrl/api/v2/cargosetu/permission";
}
