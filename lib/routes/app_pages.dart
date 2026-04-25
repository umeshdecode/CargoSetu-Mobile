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
      name: '/dashboard',
      page: () => const MainDashboardScreen(),
    ),
  ];
}
