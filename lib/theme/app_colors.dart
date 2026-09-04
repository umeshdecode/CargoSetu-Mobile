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

  // Tailwind mapped colors for new UI
  static const Color primary = Color(0xFF051125);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B263B);
  static const Color onPrimaryContainer = Color(0xFF828DA7);
  
  static const Color secondary = Color(0xFF47607E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC2DCFF);
  static const Color onSecondaryContainer = Color(0xFF48617E);
  
  static const Color surface = Color(0xFFF9FAF5);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF45474D);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F0);
  static const Color surfaceContainer = Color(0xFFEDEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E4);
  
  static const Color tertiaryFixedVariant = Color(0xFF6F3800);
  static const Color onTertiaryContainer = Color(0xFFC67C3E);
  static const Color primaryFixed = Color(0xFFD7E2FF);
}
