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

import 'package:cargo_setu/packing_list/screens/create_packing_list_screen.dart';
import 'package:cargo_setu/packing_list/screens/packing_list_shift_selection_screen.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/vehicle_management/screens/assign_driver_screen.dart';
import 'package:cargo_setu/vehicle_management/screens/drivers_list_screen.dart';
import 'package:cargo_setu/vehicle_management/screens/vehicle_management_hub_screen.dart';
import 'package:cargo_setu/vehicle_management/screens/vehicles_list_screen.dart';
import 'package:cargo_setu/marketplace/screens/marketplace_hub_screen.dart';
import 'package:cargo_setu/marketplace/screens/create_load_post_screen.dart';
import 'package:cargo_setu/marketplace/screens/create_truck_post_screen.dart';
import 'package:cargo_setu/marketplace/screens/my_bookings_screen.dart';
import 'package:cargo_setu/marketplace/screens/marketplace_wallet_screen.dart';
import 'package:cargo_setu/marketplace/screens/marketplace_chat_screen.dart';

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
    GetPage(
      name: '/packing-list',
      page: () => const PackingListShiftSelectionScreen(),
    ),
    GetPage(
      name: '/create-packing-list',
      page: () => const CreatePackingListScreen(),
    ),
    GetPage(
      name: AppRoutes.vehicleManagement,
      page: () => const VehicleManagementHubScreen(),
    ),
    GetPage(
      name: AppRoutes.vehicles,
      page: () => const VehiclesListScreen(),
    ),
    GetPage(
      name: AppRoutes.drivers,
      page: () => const DriversListScreen(),
    ),
    GetPage(
      name: AppRoutes.assignments,
      page: () => const AssignDriverScreen(),
    ),
    GetPage(
      name: AppRoutes.marketplace,
      page: () => const MarketplaceHubScreen(),
    ),
    GetPage(
      name: AppRoutes.createLoadPost,
      page: () => const CreateLoadPostScreen(),
    ),
    GetPage(
      name: AppRoutes.createTruckPost,
      page: () => const CreateTruckPostScreen(),
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const MyBookingsScreen(),
    ),
    GetPage(
      name: AppRoutes.marketplaceWallet,
      page: () => const MarketplaceWalletScreen(),
    ),
    GetPage(
      name: AppRoutes.marketplaceChat,
      page: () => const MarketplaceChatScreen(),
    ),
  ];
}
