import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum DialogType { success, error, warning, info, confirmation }

/// Professional, futuristic modal dialog for CargoSetu.
///
/// Designed to be reused throughout the app for all success, error,
/// confirmation, and info popups with modern aesthetics.
class AppDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String positiveBtnText;
  final String? negativeBtnText;
  final VoidCallback? onPositive;
  final VoidCallback? onNegative;
  final Widget? customContent;
  final bool barrierDismissible;

  const AppDialog({
    super.key,
    this.type = DialogType.info,
    required this.title,
    required this.message,
    this.positiveBtnText = "Got it",
    this.negativeBtnText,
    this.onPositive,
    this.onNegative,
    this.customContent,
    this.barrierDismissible = true,
  });

  /// Static helper for Success dialog
  static Future<T?> showSuccess<T>(
    BuildContext context, {
    required String title,
    required String message,
    String positiveBtnText = "Continue",
    VoidCallback? onPositive,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppDialog(
        type: DialogType.success,
        title: title,
        message: message,
        positiveBtnText: positiveBtnText,
        onPositive: onPositive,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Static helper for Error dialog
  static Future<T?> showError<T>(
    BuildContext context, {
    required String title,
    required String message,
    String positiveBtnText = "OK",
    VoidCallback? onPositive,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AppDialog(
        type: DialogType.error,
        title: title,
        message: message,
        positiveBtnText: positiveBtnText,
        onPositive: onPositive,
      ),
    );
  }

  /// Static helper for Confirmation dialog
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String positiveBtnText = "Confirm",
    String negativeBtnText = "Cancel",
    VoidCallback? onPositive,
    VoidCallback? onNegative,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        type: DialogType.confirmation,
        title: title,
        message: message,
        positiveBtnText: positiveBtnText,
        negativeBtnText: negativeBtnText,
        onPositive: () {
          Navigator.of(ctx).pop(true);
          onPositive?.call();
        },
        onNegative: () {
          Navigator.of(ctx).pop(false);
          onNegative?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getThemeByType(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Futuristic Header with glowing badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 28, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.gradientStart.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient outer glow
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withValues(alpha: 0.14),
                        ),
                      ),
                      // Core glowing icon sphere
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.gradientStart,
                              theme.gradientEnd,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          theme.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title and Message Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (customContent != null) ...[
                      const SizedBox(height: 16),
                      customContent!,
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    if (negativeBtnText != null &&
                        negativeBtnText!.isNotEmpty) ...[
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: onNegative ??
                                () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              negativeBtnText!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.gradientStart,
                                theme.gradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onPositive ??
                                () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              positiveBtnText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DialogTheme _getThemeByType(DialogType type) {
    switch (type) {
      case DialogType.success:
        return _DialogTheme(
          primaryColor: const Color(0xFF10B981),
          gradientStart: const Color(0xFF10B981),
          gradientEnd: const Color(0xFF059669),
          icon: Icons.check_rounded,
        );
      case DialogType.error:
        return _DialogTheme(
          primaryColor: const Color(0xFFEF4444),
          gradientStart: const Color(0xFFF87171),
          gradientEnd: const Color(0xFFDC2626),
          icon: Icons.priority_high_rounded,
        );
      case DialogType.warning:
        return _DialogTheme(
          primaryColor: const Color(0xFFF59E0B),
          gradientStart: const Color(0xFFFBBF24),
          gradientEnd: const Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
        );
      case DialogType.confirmation:
        return _DialogTheme(
          primaryColor: AppColors.primaryBlue,
          gradientStart: const Color(0xFF3B82F6),
          gradientEnd: const Color(0xFF1D4ED8),
          icon: Icons.help_outline_rounded,
        );
      case DialogType.info:
        return _DialogTheme(
          primaryColor: const Color(0xFF0EA5E9),
          gradientStart: const Color(0xFF38BDF8),
          gradientEnd: const Color(0xFF0284C7),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _DialogTheme {
  final Color primaryColor;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;

  _DialogTheme({
    required this.primaryColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
  });
}
