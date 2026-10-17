import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/truck_post_model.dart';

/// Professional available truck capacity card.
/// Displays vehicle passing specs, available tonnage, target route,
/// corridor distance, and transporter credibility without exposing raw database IDs.
class TruckCardWidget extends StatelessWidget {
  final TruckPostModel truck;
  final VoidCallback onTap;
  final VoidCallback onBookTap;

  const TruckCardWidget({
    super.key,
    required this.truck,
    required this.onTap,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final routeDistKm =
        truck.routeDistanceKm ??
        LocationService.estimateCityDistanceKm(
          originLat: truck.currentLat,
          originLng: truck.currentLng,
          originCity: truck.currentCity,
          destLat: truck.routeToLat,
          destLng: truck.routeToLng,
          destCity: truck.routeTo,
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
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              truck.listingNumber ?? 'TRUCK POST',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (truck.companyName != null &&
                              truck.companyName!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                truck.companyName!,
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
                    if (truck.overallRating != null && truck.overallRating! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              truck.overallRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Location & Route ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            truck.vehicleNumber ??
                                (truck.truckType ?? 'Truck Available'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 13,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  truck.currentState != null &&
                                          truck.currentState!.isNotEmpty
                                      ? 'At ${truck.currentCity}, ${truck.currentState}'
                                      : 'At ${truck.currentCity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (truck.routeTo != null &&
                              truck.routeTo!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.alt_route,
                                  size: 13,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Route: ${truck.currentCity} → ${truck.routeTo!}',
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
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ─── Available Capacity Badge ───
                    if (truck.availableCapacity != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${truck.availableCapacity} ${truck.capacityUnit.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Specs: Distance, Corridor Proximity, Body Type, Truck Length, Pricing ───
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (routeDistKm != null && routeDistKm > 0)
                      _specPill(
                        Icons.route_outlined,
                        LocationService.formatDistanceKm(routeDistKm),
                      ),
                    if (truck.distanceFromOriginKm != null)
                      _specPill(
                        Icons.near_me_outlined,
                        truck.distanceFromOriginKm! < 5
                            ? 'At origin city'
                            : '~${truck.distanceFromOriginKm!.round()} km from origin',
                      )
                    else if (truck.distanceFromCorridorKm != null)
                      _specPill(
                        Icons.radar,
                        '~${truck.distanceFromCorridorKm!.round()} km from route',
                      ),
                    if (truck.bodyType != null && truck.bodyType!.isNotEmpty)
                      _specPill(Icons.category_outlined, truck.bodyType!),
                    if (truck.truckLengthFeet != null &&
                        truck.truckLengthFeet! > 0)
                      _specPill(
                        Icons.straighten,
                        '${truck.truckLengthFeet} Ft',
                      ),
                    if (truck.pricePerKm != null && truck.pricePerKm! > 0)
                      _specPill(
                        Icons.currency_rupee,
                        '₹${truck.pricePerKm!.toStringAsFixed(0)} / km',
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // ─── Footer: Availability Date & Request Button ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          truck.availableFrom != null
                              ? 'Ready: ${_formatDate(truck.availableFrom!)}'
                              : 'Ready for loading',
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
                        onPressed: onBookTap,
                        icon: const Icon(Icons.send_outlined, size: 14),
                        label: const Text('Request Truck'),
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
