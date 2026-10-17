import 'marketplace_enums.dart';

class TruckPostModel {
  final int? id;
  final int? listingId;
  final String? listingNumber;
  final int? companyId;
  final int? postedByStaffId;
  final ListingStatus status;
  final int? vehicleId;
  final int? driverId;
  final String currentCity;
  final String? currentState;
  final String? currentPincode;
  final double? currentLat;
  final double? currentLng;
  final String? availableFrom;
  final String? availableTo;
  final String? routeFrom;
  final String? routeFromState;
  final double? routeFromLat;
  final double? routeFromLng;
  final String? routeTo;
  final String? routeToState;
  final double? routeToLat;
  final double? routeToLng;
  final String? returnRoute;
  final double? availableCapacity;
  final CapacityUnit capacityUnit;
  final String? truckStatus;
  final double? pricePerKm;
  final double? minimumPrice;
  final String? companyName;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? truckType;
  final String? bodyType;
  final double? truckLengthFeet;
  final double? passingCapacityTons;
  final String? driverName;
  final String? driverPhone;
  final String? verificationStatus;
  final double? overallRating;
  final int? completedTrips;
  final double? routeDistanceKm;
  final double? distanceFromOriginKm;
  final double? distanceFromDestinationKm;
  final double? distanceFromCorridorKm;
  final String? distanceType;
  final String? createdAt;

  TruckPostModel({
    this.id,
    this.listingId,
    this.listingNumber,
    this.companyId,
    this.postedByStaffId,
    this.status = ListingStatus.PUBLISHED,
    this.vehicleId,
    this.driverId,
    required this.currentCity,
    this.currentState,
    this.currentPincode,
    this.currentLat,
    this.currentLng,
    this.availableFrom,
    this.availableTo,
    this.routeFrom,
    this.routeFromState,
    this.routeFromLat,
    this.routeFromLng,
    this.routeTo,
    this.routeToState,
    this.routeToLat,
    this.routeToLng,
    this.returnRoute,
    this.availableCapacity,
    this.capacityUnit = CapacityUnit.TONNE,
    this.truckStatus = 'EMPTY_STANDING',
    this.pricePerKm,
    this.minimumPrice,
    this.companyName,
    this.vehicleNumber,
    this.vehicleType,
    this.truckType,
    this.bodyType,
    this.truckLengthFeet,
    this.passingCapacityTons,
    this.driverName,
    this.driverPhone,
    this.verificationStatus,
    this.overallRating,
    this.completedTrips,
    this.routeDistanceKm,
    this.distanceFromOriginKm,
    this.distanceFromDestinationKm,
    this.distanceFromCorridorKm,
    this.distanceType,
    this.createdAt,
  });

  factory TruckPostModel.fromJson(Map<String, dynamic> json) {
    return TruckPostModel(
      id: (json['id'] as num?)?.toInt(),
      listingId: (json['listingId'] as num?)?.toInt(),
      listingNumber: json['listingNumber']?.toString(),
      companyId: (json['companyId'] as num?)?.toInt(),
      postedByStaffId: (json['postedByStaffId'] as num?)?.toInt(),
      status: ListingStatus.fromString(json['status']?.toString()),
      vehicleId: (json['vehicleId'] as num?)?.toInt(),
      driverId: (json['driverId'] as num?)?.toInt(),
      currentCity: json['currentCity']?.toString() ?? '',
      currentState: json['currentState']?.toString(),
      currentPincode: json['currentPincode']?.toString(),
      currentLat: (json['currentLat'] as num?)?.toDouble(),
      currentLng: (json['currentLng'] as num?)?.toDouble(),
      availableFrom: json['availableFrom']?.toString(),
      availableTo: json['availableTo']?.toString(),
      routeFrom: json['routeFrom']?.toString(),
      routeFromState: json['routeFromState']?.toString(),
      routeFromLat: (json['routeFromLat'] as num?)?.toDouble(),
      routeFromLng: (json['routeFromLng'] as num?)?.toDouble(),
      routeTo: json['routeTo']?.toString(),
      routeToState: json['routeToState']?.toString(),
      routeToLat: (json['routeToLat'] as num?)?.toDouble(),
      routeToLng: (json['routeToLng'] as num?)?.toDouble(),
      returnRoute: json['returnRoute']?.toString(),
      availableCapacity: (json['availableCapacity'] as num?)?.toDouble(),
      capacityUnit: CapacityUnit.fromString(json['capacityUnit']?.toString()),
      truckStatus: json['truckStatus']?.toString(),
      pricePerKm: (json['pricePerKm'] as num?)?.toDouble(),
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble(),
      companyName: json['companyName']?.toString(),
      vehicleNumber: json['vehicleNumber']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      truckType: json['truckType']?.toString(),
      bodyType: json['bodyType']?.toString(),
      truckLengthFeet: (json['truckLengthFeet'] as num?)?.toDouble(),
      passingCapacityTons: (json['passingCapacityTons'] as num?)?.toDouble(),
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      verificationStatus: json['verificationStatus']?.toString(),
      overallRating: (json['overallRating'] as num?)?.toDouble(),
      completedTrips: (json['completedTrips'] as num?)?.toInt(),
      routeDistanceKm: (json['routeDistanceKm'] as num?)?.toDouble(),
      distanceFromOriginKm: (json['distanceFromOriginKm'] as num?)?.toDouble(),
      distanceFromDestinationKm: (json['distanceFromDestinationKm'] as num?)
          ?.toDouble(),
      distanceFromCorridorKm: (json['distanceFromCorridorKm'] as num?)
          ?.toDouble(),
      distanceType: json['distanceType']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (driverId != null) 'driverId': driverId,
      'currentCity': currentCity,
      if (currentState != null) 'currentState': currentState,
      if (currentPincode != null) 'currentPincode': currentPincode,
      if (currentLat != null) 'currentLat': currentLat,
      if (currentLng != null) 'currentLng': currentLng,
      'routeFrom': routeFrom ?? currentCity,
      if (routeFromState != null || currentState != null)
        'routeFromState': routeFromState ?? currentState,
      if (routeFromLat != null || currentLat != null)
        'routeFromLat': routeFromLat ?? currentLat,
      if (routeFromLng != null || currentLng != null)
        'routeFromLng': routeFromLng ?? currentLng,
      if (availableFrom != null) 'availableFrom': availableFrom,
      if (availableTo != null) 'availableTo': availableTo,
      if (routeTo != null) 'routeTo': routeTo,
      if (routeToState != null) 'routeToState': routeToState,
      if (routeToLat != null) 'routeToLat': routeToLat,
      if (routeToLng != null) 'routeToLng': routeToLng,
      if (returnRoute != null) 'returnRoute': returnRoute,
      'totalCapacity': passingCapacityTons ?? availableCapacity ?? 10.0,
      'availableCapacity': availableCapacity ?? 10.0,
      'capacityUnit': capacityUnit.name,
      'truckStatus': truckStatus ?? 'EMPTY_STANDING',
      if (pricePerKm != null) 'pricePerKm': pricePerKm,
      if (minimumPrice != null) 'minimumPrice': minimumPrice,
    };
  }
}
