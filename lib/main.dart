import 'dart:async';
import 'dart:developer';

import 'package:cargo_setu/routes/app_pages.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/services/connectivity_service.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/theme/theme_controller.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/widgets/error_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme/app_theme.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await GetStorage.init();

      // Initialize core services
      Get.put(SessionService());
      Get.put(ConnectivityService());

      // ─── Global Error Handling ───────────────────────────────
      // Override Flutter's default error widget (red screen) with custom error screen
      ErrorWidget.builder = (FlutterErrorDetails details) {
        if (kDebugMode) {
          return ErrorWidget(details.exception);
        }
        return ErrorScreen(
          error: details.exceptionAsString(),
          onRetry: () {
            if (Get.context != null) {
              Get.offAllNamed(AppRoutes.dashboard);
            }
          },
        );
      };

      // Catch unhandled Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        log('🚨 Flutter Error: ${details.exceptionAsString()}');
        log('Stack: ${details.stack}');
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
      };

      runApp(const CargoSetuApp());
    },
    (error, stackTrace) {
      log('🚨 Uncaught async error: $error');
      log('Stack: $stackTrace');
    },
  );
}

class CargoSetuApp extends StatelessWidget {
  const CargoSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cargo Setu',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}

////////////////////////////////////////////////
/// SPLASH SCREEN (TOKEN CHECK + COMPANY CHECK)
////////////////////////////////////////////////
class FlutterSplashScreen extends StatefulWidget {
  const FlutterSplashScreen({super.key});

  @override
  State<FlutterSplashScreen> createState() => _FlutterSplashScreenState();
}

class _FlutterSplashScreenState extends State<FlutterSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    /// Loading animation (3 seconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final storage = GetStorage();
    final token = storage.read(Constant.token);

    if (token != null && token.toString().isNotEmpty) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            /// LOGO ICON
            Image.asset(
              'assets/logo/app_icon_without_name.png',
              height: 240,
            ),

            /// APP NAME
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: "Cargo",
                    style: TextStyle(color: Color(0xFF2563EB)),
                  ),
                  TextSpan(
                    text: "Setu",
                    style: TextStyle(color: Color(0xFFF97316)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// TAGLINE
            const Text(
              "Transport Business. Ab Digital",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const Spacer(),

            /// LOADING BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// LOADING TEXT
            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
