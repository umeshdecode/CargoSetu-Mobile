import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBG,
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: AppTheme.colorPrimaryTheme,
        foregroundColor: AppTheme.colorWhite,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // static for now
        itemBuilder: (context, index) {
          return _OrderCard(
            index: index,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(
                    orderId: "CS${1000 + index}",
                    status: _getStatus(index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===================================================================
/// =========================== ORDER CARD =============================
/// ===================================================================

class _OrderCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _OrderCard({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(index);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.colorWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ORDER ID + STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #CS${1000 + index}",
                    style: TextStyle(
                      fontSize: AppTheme.medium,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.colorBlack,
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 12),

              /// FROM → TO
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Ahmedabad → Mumbai",
                      style: TextStyle(
                        fontSize: AppTheme.small + 1,
                        color: AppTheme.colorGrey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// DATE + AMOUNT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "12 Jan 2026",
                    style: TextStyle(
                      fontSize: AppTheme.small,
                      color: AppTheme.colorGrey,
                    ),
                  ),
                  Text(
                    "₹ 4,500",
                    style: TextStyle(
                      fontSize: AppTheme.medium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colorPrimaryTheme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================================================================
/// ========================= STATUS BADGE ==============================
/// ===================================================================

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;

    switch (status) {
      case "Pending":
        bgColor = AppTheme.statusPending;
        break;
      case "In Transit":
        bgColor = AppTheme.statusAssignOrange;
        break;
      case "Delivered":
        bgColor = AppTheme.statusApprove;
        break;
      default:
        bgColor = AppTheme.colorGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _getStatus(int index) {
  if (index % 3 == 0) return "Pending";
  if (index % 3 == 1) return "In Transit";
  return "Delivered";
}
