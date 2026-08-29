import 'package:cargo_setu/auth/sign_up_screen.dart';
import 'package:cargo_setu/company/company_create_screen.dart';
import 'package:cargo_setu/company/company_edit_screen.dart';
import 'package:cargo_setu/company/company_profile_screen.dart';
import 'package:cargo_setu/main.dart';
import 'package:get/get.dart';
import '../auth/login_screen.dart';
import '../dashboard/main_dashboard_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const FlutterSplashScreen(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/signup',
      page: () => const SignUpScreen(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const MainDashboardScreen(),
    ),
    GetPage(
      name: '/company-create',
      page: () => const CompanyCreateScreen(),
    ),
    GetPage(
      name: '/company-profile',
      page: () => const CompanyProfileScreen(),
    ),
    GetPage(
      name: '/company-edit',
      page: () => const CompanyEditScreen(),
    ),
  ];
}
