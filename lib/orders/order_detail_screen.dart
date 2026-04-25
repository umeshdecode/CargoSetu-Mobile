import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String status;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.colorWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #$orderId",
                    style: TextStyle(
                      fontSize: AppTheme.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      color: AppTheme.colorPrimaryTheme,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ROUTE INFO
            _infoCard(
              title: "Route",
              value: "Ahmedabad → Mumbai",
              icon: Icons.location_on,
            ),

            _infoCard(
              title: "Pickup Date",
              value: "12 Jan 2026",
              icon: Icons.calendar_today,
            ),

            _infoCard(
              title: "Vehicle Type",
              value: "Truck (14 ft)",
              icon: Icons.local_shipping,
            ),

            _infoCard(
              title: "Amount",
              value: "₹ 4,500",
              icon: Icons.account_balance_wallet,
            ),

            const SizedBox(height: 30),

            /// ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorPrimaryTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(
                        orderId: orderId,
                      ),
                    ),
                  );
                },

                child: const Text(
                  "TRACK ORDER",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.colorWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.colorPrimaryTheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.small,
                    color: AppTheme.colorGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTheme.medium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
