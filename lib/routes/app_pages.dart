import 'package:cargo_setu/auth/sign_up_screen.dart';
import 'package:cargo_setu/company/company_create_screen.dart';
import 'package:cargo_setu/company/company_edit_screen.dart';
import 'package:cargo_setu/company/company_profile_screen.dart';
import 'package:cargo_setu/main.dart';
import 'package:cargo_setu/profile/edit_profile_screen.dart';
import 'package:cargo_setu/customer/screens/create_customer_screen.dart';
import 'package:cargo_setu/customer/screens/customer_management_screen.dart';
import 'package:cargo_setu/quotation/screens/quotation_screen.dart';
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
    GetPage(
      name: '/edit-profile',
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: '/create-customer',
      page: () => CreateCustomerScreen(),
    ),
    GetPage(
      name: '/customer-management',
      page: () => const CustomerManagementScreen(),
    ),
    GetPage(
      name: '/quotations',
      page: () => const QuotationScreen(),
    ),
  ];
}
