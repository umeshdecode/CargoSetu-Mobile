import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable section header used across forms and detail screens.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.only(bottom: 16, top: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
