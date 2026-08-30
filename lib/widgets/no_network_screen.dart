import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Full-screen "No Internet Connection" screen.
///
/// Shows a transport-themed illustration (truck with broken signal)
/// and a retry button. Reusable across the app.
///
/// Usage:
/// ```dart
/// NoNetworkScreen(onRetry: () => fetchData());
/// ```
class NoNetworkScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? title;
  final String? subtitle;

  const NoNetworkScreen({
    super.key,
    this.onRetry,
    this.title,
    this.subtitle,
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

                // ─── Transport-themed illustration ─────────────
                _buildIllustration(),

                const SizedBox(height: 40),

                // ─── Title ─────────────────────────────────────
                Text(
                  title ?? 'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Subtitle ──────────────────────────────────
                Text(
                  subtitle ??
                      'Looks like your connection took a wrong route.\nPlease check your network and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 36),

                // ─── Retry Button ──────────────────────────────
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
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

                const SizedBox(height: 14),

                // ─── Hint ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Check Wi-Fi or mobile data settings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Transport-themed illustration: a truck with a "no signal" icon.
  Widget _buildIllustration() {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2563EB).withValues(alpha: 0.06),
            ),
          ),
          // Inner glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            ),
          ),
          // Truck icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 42,
              color: Color(0xFF94A3B8),
            ),
          ),
          // No-signal badge (bottom right)
          Positioned(
            bottom: 22,
            right: 20,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 22,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
