import 'marketplace_enums.dart';

class MarketplaceBookingModel {
  final int? id;
  final String? bookingNumber;
  final int? listingId;
  final String? listingNumber;
  final ListingType? listingType;
  final int? shipperCompanyId;
  final String? shipperCompanyName;
  final int? transporterCompanyId;
  final String? transporterCompanyName;
  final int? offerId;
  final int? vehicleId;
  final String? vehicleNumber;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final double agreedFreight;
  final PaymentTermType paymentTerms;
  final int? advancePercentage;
  final BookingStatus status;
  final double? requestedCapacity;
  final String? bookedAt;
  final String? createdAt;

  MarketplaceBookingModel({
    this.id,
    this.bookingNumber,
    this.listingId,
    this.listingNumber,
    this.listingType,
    this.shipperCompanyId,
    this.shipperCompanyName,
    this.transporterCompanyId,
    this.transporterCompanyName,
    this.offerId,
    this.vehicleId,
    this.vehicleNumber,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.agreedFreight,
    this.paymentTerms = PaymentTermType.ADVANCE_PERCENT,
    this.advancePercentage,
    this.status = BookingStatus.PENDING_PAYMENT,
    this.requestedCapacity,
    this.bookedAt,
    this.createdAt,
  });

  factory MarketplaceBookingModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceBookingModel(
      id: json['id'] as int?,
      bookingNumber: json['bookingNumber']?.toString(),
      listingId: json['listingId'] as int?,
      listingNumber: json['listingNumber']?.toString(),
      listingType: json['listingType'] != null
          ? ListingType.fromString(json['listingType'].toString())
          : null,
      shipperCompanyId: json['shipperCompanyId'] as int?,
      shipperCompanyName: json['shipperCompanyName']?.toString(),
      transporterCompanyId: json['transporterCompanyId'] as int?,
      transporterCompanyName: json['transporterCompanyName']?.toString(),
      offerId: json['offerId'] as int?,
      vehicleId: json['vehicleId'] as int?,
      vehicleNumber: json['vehicleNumber']?.toString(),
      driverId: json['driverId'] as int?,
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      agreedFreight: (json['agreedFreight'] as num?)?.toDouble() ?? 0.0,
      paymentTerms: PaymentTermType.fromString(json['paymentTerms']?.toString()),
      advancePercentage: json['advancePercentage'] as int?,
      status: BookingStatus.fromString(json['status']?.toString()),
      requestedCapacity: (json['requestedCapacity'] as num?)?.toDouble(),
      bookedAt: json['bookedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (listingId != null) 'listingId': listingId,
      if (offerId != null) 'offerId': offerId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (driverId != null) 'driverId': driverId,
      'agreedFreight': agreedFreight,
      'paymentTerms': paymentTerms.name,
      if (advancePercentage != null) 'advancePercentage': advancePercentage,
      if (requestedCapacity != null) 'requestedCapacity': requestedCapacity,
    };
  }
}
