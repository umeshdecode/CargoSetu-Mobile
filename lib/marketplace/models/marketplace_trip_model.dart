import 'marketplace_enums.dart';

class MarketplaceTripModel {
  final int? id;
  final String? tripNumber;
  final int? bookingId;
  final int? existingTripId;
  final int? vehicleId;
  final int? driverId;
  final int? companyId;
  final String? startCity;
  final String? startAddress;
  final double? startLat;
  final double? startLng;
  final String? endCity;
  final String? endAddress;
  final double? endLat;
  final double? endLng;
  final String? plannedStartTime;
  final String? plannedEndTime;
  final String? actualStartTime;
  final String? actualEndTime;
  final MarketplaceTripStatus status;
  final String? createdAt;

  MarketplaceTripModel({
    this.id,
    this.tripNumber,
    this.bookingId,
    this.existingTripId,
    this.vehicleId,
    this.driverId,
    this.companyId,
    this.startCity,
    this.startAddress,
    this.startLat,
    this.startLng,
    this.endCity,
    this.endAddress,
    this.endLat,
    this.endLng,
    this.plannedStartTime,
    this.plannedEndTime,
    this.actualStartTime,
    this.actualEndTime,
    this.status = MarketplaceTripStatus.BOOKED,
    this.createdAt,
  });

  factory MarketplaceTripModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceTripModel(
      id: json['id'] as int?,
      tripNumber: json['tripNumber']?.toString(),
      bookingId: json['bookingId'] as int?,
      existingTripId: json['existingTripId'] as int?,
      vehicleId: json['vehicleId'] as int?,
      driverId: json['driverId'] as int?,
      companyId: json['companyId'] as int?,
      startCity: json['startCity']?.toString(),
      startAddress: json['startAddress']?.toString(),
      startLat: (json['startLat'] as num?)?.toDouble(),
      startLng: (json['startLng'] as num?)?.toDouble(),
      endCity: json['endCity']?.toString(),
      endAddress: json['endAddress']?.toString(),
      endLat: (json['endLat'] as num?)?.toDouble(),
      endLng: (json['endLng'] as num?)?.toDouble(),
      plannedStartTime: json['plannedStartTime']?.toString(),
      plannedEndTime: json['plannedEndTime']?.toString(),
      actualStartTime: json['actualStartTime']?.toString(),
      actualEndTime: json['actualEndTime']?.toString(),
      status: MarketplaceTripStatus.fromString(json['status']?.toString()),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class TripEventModel {
  final int? id;
  final int? tripId;
  final String eventType;
  final String? eventTime;
  final String? location;
  final double? lat;
  final double? lng;
  final String? remarks;
  final String? evidenceFileRef;
  final String? previousStatus;
  final String? newStatus;

  TripEventModel({
    this.id,
    this.tripId,
    required this.eventType,
    this.eventTime,
    this.location,
    this.lat,
    this.lng,
    this.remarks,
    this.evidenceFileRef,
    this.previousStatus,
    this.newStatus,
  });

  factory TripEventModel.fromJson(Map<String, dynamic> json) {
    return TripEventModel(
      id: json['id'] as int?,
      tripId: json['tripId'] as int?,
      eventType: json['eventType']?.toString() ?? '',
      eventTime: json['eventTime']?.toString(),
      location: json['location']?.toString(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      remarks: json['remarks']?.toString(),
      evidenceFileRef: json['evidenceFileRef']?.toString(),
      previousStatus: json['previousStatus']?.toString(),
      newStatus: json['newStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      if (location != null) 'location': location,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (remarks != null) 'remarks': remarks,
      if (evidenceFileRef != null) 'evidenceFileRef': evidenceFileRef,
      if (newStatus != null) 'newStatus': newStatus,
    };
  }
}
