import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized modern snackbar notification utility for CargoSetu.
///
/// Features:
/// - Always displayed at the TOP of the screen (`SnackPosition.TOP`).
/// - Never shows the written word "Error" as a header; renders the message directly.
/// - Floating rounded card with smooth animations and dismissibility.
class AppSnackbar {
  AppSnackbar._();

  /// Generic display method anchored to top
  static void show(
    String message, {
    String? title,
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    // If title is "Error", nullify it so it is never shown
    final sanitizedTitle = (title != null && title.trim().toLowerCase() != 'error' && title.trim().isNotEmpty)
        ? title.trim()
        : null;

    Get.snackbar(
      sanitizedTitle ?? '',
      message,
      titleText: sanitizedTitle != null
          ? Text(
              sanitizedTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            )
          : const SizedBox.shrink(),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.3,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: icon != null ? Icon(icon, color: textColor, size: 20) : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration,
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Error notification: Red badge at the TOP, no "Error" heading
  static void error(String message) {
    show(
      message,
      backgroundColor: const Color(0xFFDC2626),
      textColor: Colors.white,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Success notification: Green badge at the TOP
  static void success(String message, {String? title}) {
    show(
      message,
      title: title,
      backgroundColor: const Color(0xFF16A34A),
      textColor: Colors.white,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Information notification: Blue badge at the TOP
  static void info(String message, {String? title}) {
    show(
      message,
      title: title,
      backgroundColor: const Color(0xFF2563EB),
      textColor: Colors.white,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Warning notification: Amber badge at the TOP
  static void warning(String message, {String? title}) {
    show(
      message,
      title: title,
      backgroundColor: const Color(0xFFD97706),
      textColor: Colors.white,
      icon: Icons.warning_amber_rounded,
    );
  }
}
