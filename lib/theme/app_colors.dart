import 'package:flutter/material.dart';

/// Centralized CargoSetu brand colors.
/// Use these instead of scattered Color(...) literals.
class AppColors {
  AppColors._();

  // Brand
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1E40AF);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentOrangeLight = Color(0xFFFFF7ED);

  // Background
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCard = Colors.white;
  static const Color bgDark = Color(0xFF121212);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status
  static const Color statusPending = Color(0xFF17A2B8);
  static const Color statusApproved = Color(0xFF28A745);
  static const Color statusRejected = Color(0xFFDC3545);
  static const Color statusWarning = Color(0xFFE69F08);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF2563EB);

  // Functional
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  static const Color warning = Color(0xFFE69F08);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
  );
}
