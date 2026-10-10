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
  final String? routeTo;
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
    this.routeTo,
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
    this.createdAt,
  });

  factory TruckPostModel.fromJson(Map<String, dynamic> json) {
    return TruckPostModel(
      id: json['id'] as int?,
      listingId: json['listingId'] as int?,
      listingNumber: json['listingNumber']?.toString(),
      companyId: json['companyId'] as int?,
      postedByStaffId: json['postedByStaffId'] as int?,
      status: ListingStatus.fromString(json['status']?.toString()),
      vehicleId: json['vehicleId'] as int?,
      driverId: json['driverId'] as int?,
      currentCity: json['currentCity']?.toString() ?? '',
      currentState: json['currentState']?.toString(),
      currentPincode: json['currentPincode']?.toString(),
      currentLat: (json['currentLat'] as num?)?.toDouble(),
      currentLng: (json['currentLng'] as num?)?.toDouble(),
      availableFrom: json['availableFrom']?.toString(),
      availableTo: json['availableTo']?.toString(),
      routeTo: json['routeTo']?.toString(),
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
      completedTrips: json['completedTrips'] as int?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicleId': vehicleId ?? 1,
      if (driverId != null) 'driverId': driverId,
      'currentCity': currentCity,
      if (currentState != null) 'currentState': currentState,
      if (currentPincode != null) 'currentPincode': currentPincode,
      if (currentLat != null) 'currentLat': currentLat,
      if (currentLng != null) 'currentLng': currentLng,
      'routeFrom': currentCity,
      if (availableFrom != null) 'availableFrom': availableFrom,
      if (availableTo != null) 'availableTo': availableTo,
      if (routeTo != null) 'routeTo': routeTo,
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
