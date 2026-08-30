import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-screen runtime error fallback screen.
///
/// Shown instead of the default red "RenderFlex overflowed" screen or app crash.
/// Transport-themed illustration with recovery options.
///
/// Usage:
/// ```dart
/// ErrorScreen(
///   error: 'NullPointerException',
///   onRetry: () => Navigator.pop(context),
/// );
/// ```
class ErrorScreen extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final bool showBackToDashboard;

  const ErrorScreen({
    super.key,
    this.error,
    this.onRetry,
    this.showBackToDashboard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ─── Broken Truck Illustration ─────────────────
                _buildBrokenTruckIllustration(),

                const SizedBox(height: 36),

                // ─── Title ─────────────────────────────────────
                const Text(
                  'Oops! Something Went Wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Subtitle ──────────────────────────────────
                const Text(
                  'Our transport system hit a bump in the road.\nDon\'t worry — your data is safe.\nPlease try again or head back home.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 36),

                // ─── Action Buttons ────────────────────────────
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                if (onRetry != null) const SizedBox(height: 12),

                if (showBackToDashboard)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Get.offAllNamed(AppRoutes.dashboard),
                      icon: const Icon(Icons.home_outlined, size: 20),
                      label: const Text(
                        'Back to Dashboard',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                // ─── Error Details (debug info, small text) ────
                if (error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Broken-down truck illustration built with icons and shapes.
  Widget _buildBrokenTruckIllustration() {
    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Road line
          Positioned(
            bottom: 8,
            left: 20,
            right: 20,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Dashed road markings
          Positioned(
            bottom: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                7,
                (i) => Container(
                  width: 12,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          // Truck body
          Positioned(
            bottom: 14,
            child: Container(
              width: 110,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Warning triangle (top right of truck)
          Positioned(
            top: 20,
            right: 30,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 26,
                color: AppColors.warning,
              ),
            ),
          ),
          // Smoke puffs (top left of truck)
          Positioned(
            top: 30,
            left: 30,
            child: Row(
              children: [
                _smokePuff(16),
                const SizedBox(width: 3),
                _smokePuff(10),
                const SizedBox(width: 2),
                _smokePuff(7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smokePuff(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCBD5E1).withValues(alpha: 0.5),
      ),
    );
  }
}
