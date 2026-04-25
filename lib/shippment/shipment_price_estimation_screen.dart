import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriceEstimationScreen extends StatelessWidget {
  const PriceEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("Price Estimation"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 ROUTE CARD
            _infoCard(
              title: "Route",
              value: "Ahmedabad → Mumbai",
              icon: Icons.location_on,
            ),

            _infoCard(
              title: "Vehicle Type",
              value: "Truck (14 ft)",
              icon: Icons.local_shipping_outlined,
            ),

            _infoCard(
              title: "Weight",
              value: "1200 kg",
              icon: Icons.scale_outlined,
            ),

            const SizedBox(height: 20),

            /// 🔹 PRICE BREAKUP
            Container(
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
                children: [
                  _priceRow("Base Fare", "₹ 3,800"),
                  _priceRow("Fuel Charges", "₹ 400"),
                  _priceRow("GST", "₹ 300"),
                  const Divider(height: 24),
                  _priceRow(
                    "Total Amount",
                    "₹ 4,500",
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// 🔹 ACTION BUTTON
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
                  Navigator.pop(context); // go back to review for now
                },
                child: const Text(
                  "PROCEED TO CONFIRM",
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

  /// ===================== INFO CARD =====================
  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  style: const TextStyle(
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

  /// ===================== PRICE ROW =====================
  Widget _priceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? AppTheme.medium : AppTheme.small,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? AppTheme.medium : AppTheme.small,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? AppTheme.colorPrimaryTheme
                  : AppTheme.colorBlack,
            ),
          ),
        ],
      ),
    );
  }
}
