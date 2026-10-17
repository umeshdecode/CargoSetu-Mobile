import 'marketplace_enums.dart';

class LoadPostModel {
  final int? id;
  final int? listingId;
  final String? listingNumber;
  final int? companyId;
  final int? postedByStaffId;
  final ListingStatus status;
  final String originCity;
  final String? originAddress;
  final String? originState;
  final String? originPincode;
  final double? originLat;
  final double? originLng;
  final String destinationCity;
  final String? destinationAddress;
  final String? destinationState;
  final String? destinationPincode;
  final double? destinationLat;
  final double? destinationLng;
  final String? pickupFrom;
  final String? pickupTo;
  final String? deliveryFrom;
  final String? deliveryTo;
  final CargoType cargoType;
  final String? cargoDescription;
  final double? weight;
  final CapacityUnit weightUnit;
  final double? volume;
  final int? packageCount;
  final String? requiredTruckType;
  final double? requiredTruckLength;
  final String? requiredBodyType;
  final String? priceType;
  final double? askingPrice;
  final PaymentTermType paymentTerms;
  final int? advancePercentage;
  final String? companyName;
  final String? verificationStatus;
  final double? routeDistanceKm;
  final String? routeDistanceType;
  final String? createdAt;

  LoadPostModel({
    this.id,
    this.listingId,
    this.listingNumber,
    this.companyId,
    this.postedByStaffId,
    this.status = ListingStatus.PUBLISHED,
    required this.originCity,
    this.originAddress,
    this.originState,
    this.originPincode,
    this.originLat,
    this.originLng,
    required this.destinationCity,
    this.destinationAddress,
    this.destinationState,
    this.destinationPincode,
    this.destinationLat,
    this.destinationLng,
    this.pickupFrom,
    this.pickupTo,
    this.deliveryFrom,
    this.deliveryTo,
    this.cargoType = CargoType.GENERAL,
    this.cargoDescription,
    this.weight,
    this.weightUnit = CapacityUnit.TONNE,
    this.volume,
    this.packageCount,
    this.requiredTruckType,
    this.requiredTruckLength,
    this.requiredBodyType,
    this.priceType,
    this.askingPrice,
    this.paymentTerms = PaymentTermType.ADVANCE_PERCENT,
    this.advancePercentage,
    this.companyName,
    this.verificationStatus,
    this.routeDistanceKm,
    this.routeDistanceType,
    this.createdAt,
  });

  factory LoadPostModel.fromJson(Map<String, dynamic> json) {
    return LoadPostModel(
      id: (json['id'] as num?)?.toInt(),
      listingId: (json['listingId'] as num?)?.toInt(),
      listingNumber: json['listingNumber']?.toString(),
      companyId: (json['companyId'] as num?)?.toInt(),
      postedByStaffId: (json['postedByStaffId'] as num?)?.toInt(),
      status: ListingStatus.fromString(json['status']?.toString()),
      originCity: json['originCity']?.toString() ?? '',
      originAddress: json['originAddress']?.toString(),
      originState: json['originState']?.toString(),
      originPincode: json['originPincode']?.toString(),
      originLat: (json['originLat'] as num?)?.toDouble(),
      originLng: (json['originLng'] as num?)?.toDouble(),
      destinationCity: json['destinationCity']?.toString() ?? '',
      destinationAddress: json['destinationAddress']?.toString(),
      destinationState: json['destinationState']?.toString(),
      destinationPincode: json['destinationPincode']?.toString(),
      destinationLat: (json['destinationLat'] as num?)?.toDouble(),
      destinationLng: (json['destinationLng'] as num?)?.toDouble(),
      pickupFrom: json['pickupFrom']?.toString(),
      pickupTo: json['pickupTo']?.toString(),
      deliveryFrom: json['deliveryFrom']?.toString(),
      deliveryTo: json['deliveryTo']?.toString(),
      cargoType: CargoType.fromString(json['cargoType']?.toString()),
      cargoDescription: json['cargoDescription']?.toString(),
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: CapacityUnit.fromString(json['weightUnit']?.toString()),
      volume: (json['volume'] as num?)?.toDouble(),
      packageCount: (json['packageCount'] as num?)?.toInt(),
      requiredTruckType: json['requiredTruckType']?.toString(),
      requiredTruckLength: (json['requiredTruckLength'] as num?)?.toDouble(),
      requiredBodyType: json['requiredBodyType']?.toString(),
      priceType: json['priceType']?.toString(),
      askingPrice: (json['askingPrice'] as num?)?.toDouble(),
      paymentTerms: PaymentTermType.fromString(
        json['paymentTerms']?.toString(),
      ),
      advancePercentage: (json['advancePercentage'] as num?)?.toInt(),
      companyName: json['companyName']?.toString(),
      verificationStatus: json['verificationStatus']?.toString(),
      routeDistanceKm: (json['routeDistanceKm'] as num?)?.toDouble(),
      routeDistanceType: json['routeDistanceType']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'originCity': originCity,
      if (originAddress != null) 'originAddress': originAddress,
      if (originState != null) 'originState': originState,
      if (originPincode != null) 'originPincode': originPincode,
      if (originLat != null) 'originLat': originLat,
      if (originLng != null) 'originLng': originLng,
      'destinationCity': destinationCity,
      if (destinationAddress != null) 'destinationAddress': destinationAddress,
      if (destinationState != null) 'destinationState': destinationState,
      if (destinationPincode != null) 'destinationPincode': destinationPincode,
      if (destinationLat != null) 'destinationLat': destinationLat,
      if (destinationLng != null) 'destinationLng': destinationLng,
      if (pickupFrom != null) 'pickupFrom': pickupFrom,
      if (pickupTo != null) 'pickupTo': pickupTo,
      if (deliveryFrom != null) 'deliveryFrom': deliveryFrom,
      if (deliveryTo != null) 'deliveryTo': deliveryTo,
      'cargoType': cargoType.name,
      if (cargoDescription != null) 'cargoDescription': cargoDescription,
      if (weight != null) 'weight': weight,
      'weightUnit': weightUnit.name,
      if (volume != null) 'volume': volume,
      if (packageCount != null) 'packageCount': packageCount,
      if (requiredTruckType != null) 'requiredTruckType': requiredTruckType,
      if (requiredTruckLength != null)
        'requiredTruckLength': requiredTruckLength,
      if (requiredBodyType != null) 'requiredBodyType': requiredBodyType,
      if (priceType != null) 'priceType': priceType,
      if (askingPrice != null) 'askingPrice': askingPrice,
      'paymentTerms': paymentTerms.name,
      if (advancePercentage != null) 'advancePercentage': advancePercentage,
    };
  }
}
