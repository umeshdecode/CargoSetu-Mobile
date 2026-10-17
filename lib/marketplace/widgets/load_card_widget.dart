import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/load_post_model.dart';
import '../models/marketplace_enums.dart';

/// Professional freight load card tailored for drivers, transporters, and shippers.
/// Designed for high clarity in the field: large route badges, prominent pricing,
/// and clear commodity indicators. NEVER exposes internal database IDs.
class LoadCardWidget extends StatelessWidget {
  final LoadPostModel load;
  final VoidCallback onTap;
  final VoidCallback onBidTap;

  const LoadCardWidget({
    super.key,
    required this.load,
    required this.onTap,
    required this.onBidTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final distKm =
        load.routeDistanceKm ??
        LocationService.estimateCityDistanceKm(
          originLat: load.originLat,
          originLng: load.originLng,
          originCity: load.originCity,
          destLat: load.destinationLat,
          destLng: load.destinationLng,
          destCity: load.destinationCity,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header: Post Number & Status Pill ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              load.listingNumber ?? 'LOAD POST',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (load.companyName != null &&
                              load.companyName!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                load.companyName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(load.status),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Route: Origin → Destination ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 10,
                          color: Color(0xFF10B981),
                        ),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: const Color(0xFFCBD5E1),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Color(0xFFEF4444),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            load.originState != null &&
                                    load.originState!.isNotEmpty
                                ? '${load.originCity}, ${load.originState}'
                                : load.originCity,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            load.destinationState != null &&
                                    load.destinationState!.isNotEmpty
                                ? '${load.destinationCity}, ${load.destinationState}'
                                : load.destinationCity,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Price Block ───
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (load.askingPrice != null &&
                            load.askingPrice! > 0) ...[
                          Text(
                            currencyFormatter.format(load.askingPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            load.priceType == 'PER_TON'
                                ? 'per ton'
                                : 'Fixed Freight',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Negotiable',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Specs Pills: Distance, Weight, Cargo Type, Truck Type ───
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (distKm != null && distKm > 0)
                      _specPill(
                        Icons.route_outlined,
                        LocationService.formatDistanceKm(distKm),
                      ),
                    if (load.weight != null)
                      _specPill(
                        Icons.scale_outlined,
                        '${load.weight} ${load.weightUnit.name}',
                      ),
                    _specPill(
                      Icons.inventory_2_outlined,
                      load.cargoType.displayName,
                    ),
                    if (load.requiredTruckType != null &&
                        load.requiredTruckType!.isNotEmpty)
                      _specPill(
                        Icons.local_shipping_outlined,
                        load.requiredTruckType!,
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // ─── Footer: Date & Quick Actions ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          load.pickupFrom != null
                              ? 'Pickup: ${_formatDate(load.pickupFrom!)}'
                              : 'Immediate Pickup',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: onBidTap,
                        icon: const Icon(Icons.gavel, size: 14),
                        label: const Text('Bid / Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ListingStatus status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);

    if (status == ListingStatus.PUBLISHED) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    } else if (status == ListingStatus.NEGOTIATING ||
        status == ListingStatus.MATCHED) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    } else if (status == ListingStatus.BOOKED) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _specPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
