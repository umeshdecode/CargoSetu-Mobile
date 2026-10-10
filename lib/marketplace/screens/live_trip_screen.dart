import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_enums.dart';
import '../models/marketplace_trip_model.dart';
import '../services/marketplace_service.dart';

/// Screen for tracking real-time marketplace trip milestones and progress.
/// Displays timeline events, milestone progression, and status updates.
/// Zero internal database primary key exposure.
class LiveTripScreen extends StatefulWidget {
  final int? tripId;
  final int? bookingId;

  const LiveTripScreen({
    super.key,
    this.tripId,
    this.bookingId,
  });

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  final _service = MarketplaceService();
  bool _isLoading = true;
  MarketplaceTripModel? _trip;
  List<TripEventModel> _timeline = [];

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.tripId != null) {
        _trip = await _service.getTrip(widget.tripId!);
      } else if (widget.bookingId != null) {
        final activeTrips = await _service.getActiveTrips();
        _trip = activeTrips.firstWhereOrNull((t) => t.bookingId == widget.bookingId);
      }

      if (_trip?.id != null) {
        _timeline = await _service.getTripTimeline(_trip!.id!);
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Milestone Tracking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (_trip?.tripNumber != null)
              Text(
                'Trip Ref: ${_trip!.tripNumber}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadTripData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trip == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRouteHeaderCard(),
                      const SizedBox(height: 16),
                      _buildMilestoneProgression(),
                      const SizedBox(height: 16),
                      _buildTimelineSection(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trip In Preparation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A trip record is created once loading begins or advance payment is verified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusPill(_trip!.status),
              if (_trip!.actualStartTime != null)
                Text(
                  'Started: ${DateFormat('dd MMM, hh:mm a').format(DateTime.tryParse(_trip!.actualStartTime!) ?? DateTime.now())}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trip_origin, color: Color(0xFF059669), size: 14),
                        SizedBox(width: 4),
                        Text('Origin', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _trip!.startCity ?? 'Origin City',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    if (_trip!.startAddress != null)
                      Text(
                        _trip!.startAddress!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFDC2626), size: 14),
                        SizedBox(width: 4),
                        Text('Destination', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _trip!.endCity ?? 'Destination City',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    if (_trip!.endAddress != null)
                      Text(
                        _trip!.endAddress!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneProgression() {
    final stages = [
      {'title': 'Booked', 'key': MarketplaceTripStatus.BOOKED},
      {'title': 'At Loading', 'key': MarketplaceTripStatus.REACHED_LOADING},
      {'title': 'In Transit', 'key': MarketplaceTripStatus.IN_TRANSIT},
      {'title': 'Delivered', 'key': MarketplaceTripStatus.DELIVERED},
      {'title': 'POD Upload', 'key': MarketplaceTripStatus.POD_UPLOADED},
    ];

    final currentIdx = stages.indexWhere((s) => s['key'] == _trip!.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Milestone Progression',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(stages.length * 2 - 1, (i) {
              if (i.isOdd) {
                final lineIdx = i ~/ 2;
                final isDone = lineIdx < currentIdx;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isDone ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                  ),
                );
              }
              final stageIdx = i ~/ 2;
              final isDone = stageIdx <= currentIdx;
              final isCurrent = stageIdx == currentIdx;

              return Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? (isCurrent ? AppColors.primary : const Color(0xFF059669))
                          : const Color(0xFFE2E8F0),
                    ),
                    child: Center(
                      child: Icon(
                        isDone ? Icons.check : Icons.circle,
                        size: isDone ? 14 : 8,
                        color: isDone ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stages[stageIdx]['title'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trip Activity Feed',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              Text(
                '${_timeline.length} Events',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_timeline.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No milestone events recorded yet.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeline.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final ev = _timeline[idx];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.eventType.replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          if (ev.remarks != null && ev.remarks!.isNotEmpty)
                            Text(
                              ev.remarks!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            ),
                          if (ev.location != null)
                            Text(
                              'Near ${ev.location}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                        ],
                      ),
                    ),
                    if (ev.eventTime != null)
                      Text(
                        DateFormat('hh:mm a').format(DateTime.tryParse(ev.eventTime!) ?? DateTime.now()),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showAddMilestoneSheet,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Post Milestone Update',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(MarketplaceTripStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E40AF),
        ),
      ),
    );
  }

  void _showAddMilestoneSheet() {
    final remarksCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String eventType = 'IN_TRANSIT_CHECKPOINT';

    final options = [
      'REACHED_LOADING',
      'LOADING_COMPLETE',
      'IN_TRANSIT_CHECKPOINT',
      'REACHED_UNLOADING',
      'UNLOADING_COMPLETE',
      'DELIVERED',
      'POD_UPLOADED',
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Record Trip Milestone',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: eventType,
                        items: options.map((o) {
                          return DropdownMenuItem(value: o, child: Text(o.replaceAll('_', ' ')));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => eventType = val);
                        },
                        decoration: InputDecoration(
                          labelText: 'Milestone Type',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationCtrl,
                        decoration: InputDecoration(
                          labelText: 'Current Location City / Landmark',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: remarksCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Status Remarks',
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (_trip?.id == null) return;
                    Get.back();
                    final event = TripEventModel(
                      tripId: _trip!.id,
                      eventType: eventType,
                      location: locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : null,
                      remarks: remarksCtrl.text.trim().isNotEmpty ? remarksCtrl.text.trim() : null,
                    );
                    final success = await _service.addTripEvent(_trip!.id!, event);
                    if (success) {
                      Get.snackbar('Milestone Added', 'Trip update recorded successfully.',
                          backgroundColor: const Color(0xFF059669), colorText: Colors.white);
                      _loadTripData();
                    }
                  },
                  child: const Text('Save Milestone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
