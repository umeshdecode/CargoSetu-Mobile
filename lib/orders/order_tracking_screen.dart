import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("Order Tracking"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 ORDER ID
            Text(
              "Order #$orderId",
              style: TextStyle(
                fontSize: AppTheme.large,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 TIMELINE
            Expanded(
              child: ListView(
                children: const [
                  _TrackingStep(
                    title: "Order Placed",
                    subtitle: "12 Jan 2026, 10:30 AM",
                    isCompleted: true,
                  ),
                  _TrackingStep(
                    title: "Pickup Scheduled",
                    subtitle: "12 Jan 2026, 2:00 PM",
                    isCompleted: true,
                  ),
                  _TrackingStep(
                    title: "In Transit",
                    subtitle: "Vehicle is on the way",
                    isCompleted: true,
                  ),
                  _TrackingStep(
                    title: "Out for Delivery",
                    subtitle: "Expected today",
                    isCompleted: false,
                  ),
                  _TrackingStep(
                    title: "Delivered",
                    subtitle: "Pending",
                    isCompleted: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================================================================
/// ======================= TIMELINE STEP ==============================
/// ===================================================================

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT TIMELINE
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.colorPrimaryTheme
                    : AppTheme.colorLightGrey,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
                  : null,
            ),

            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted
                    ? AppTheme.colorPrimaryTheme
                    : AppTheme.colorLightGrey,
              ),
          ],
        ),

        const SizedBox(width: 12),

        /// RIGHT CONTENT
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.colorWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.medium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTheme.small,
                    color: AppTheme.colorGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
