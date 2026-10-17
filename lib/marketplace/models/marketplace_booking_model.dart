import 'marketplace_enums.dart';

class MarketplaceBookingModel {
  final int? id;
  final String? bookingNumber;
  final int? listingId;
  final String? listingNumber;
  final ListingType? listingType;
  final int? listingOwnerCompanyId;
  final String? listingOwnerCompanyName;
  final int? listingPostedByStaffId;
  final int? requestedByCompanyId;
  final String? requestedByCompanyName;
  final int? requestedByStaffId;
  final int? shipperCompanyId;
  final String? shipperCompanyName;
  final int? transporterCompanyId;
  final String? transporterCompanyName;
  final int? offerId;
  final int? vehicleId;
  final String? vehicleNumber;
  final String? vehicleType;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final double agreedFreight;
  final double? proposedFreight;
  final double? counterFreight;
  final int? lastActionByCompanyId;
  final PaymentTermType paymentTerms;
  final int? advancePercentage;
  final BookingStatus status;
  final double? requestedCapacity;
  final CapacityUnit? capacityUnit;
  final String? originCity;
  final String? originState;
  final String? destinationCity;
  final String? destinationState;
  final String? cargoType;
  final double? weight;
  final String? rejectionReason;
  final String? remarks;
  final String? bookedAt;
  final String? createdAt;
  final String? updatedAt;

  BookingStatus get bookingStatus => status;

  MarketplaceBookingModel({
    this.id,
    this.bookingNumber,
    this.listingId,
    this.listingNumber,
    this.listingType,
    this.listingOwnerCompanyId,
    this.listingOwnerCompanyName,
    this.listingPostedByStaffId,
    this.requestedByCompanyId,
    this.requestedByCompanyName,
    this.requestedByStaffId,
    this.shipperCompanyId,
    this.shipperCompanyName,
    this.transporterCompanyId,
    this.transporterCompanyName,
    this.offerId,
    this.vehicleId,
    this.vehicleNumber,
    this.vehicleType,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.agreedFreight,
    this.proposedFreight,
    this.counterFreight,
    this.lastActionByCompanyId,
    this.paymentTerms = PaymentTermType.ADVANCE_PERCENT,
    this.advancePercentage,
    BookingStatus? status,
    BookingStatus? bookingStatus,
    this.requestedCapacity,
    this.capacityUnit,
    this.originCity,
    this.originState,
    this.destinationCity,
    this.destinationState,
    this.cargoType,
    this.weight,
    this.rejectionReason,
    this.remarks,
    this.bookedAt,
    this.createdAt,
    this.updatedAt,
  }) : status = status ?? bookingStatus ?? BookingStatus.PENDING_APPROVAL;

  factory MarketplaceBookingModel.fromJson(Map<String, dynamic> json) {
    final lType = json['listingType'] != null
        ? ListingType.fromString(json['listingType'].toString())
        : null;
    final shipperName = json['shipperCompanyName']?.toString();
    final transporterName = json['transporterCompanyName']?.toString();
    final ownerName =
        json['listingOwnerCompanyName']?.toString() ??
        (lType == ListingType.TRUCK_POST ? transporterName : shipperName);
    final reqName =
        json['requestedByCompanyName']?.toString() ??
        (lType == ListingType.TRUCK_POST ? shipperName : transporterName);

    return MarketplaceBookingModel(
      id: (json['id'] as num?)?.toInt(),
      bookingNumber: json['bookingNumber']?.toString(),
      listingId: (json['listingId'] as num?)?.toInt(),
      listingNumber: json['listingNumber']?.toString(),
      listingType: lType,
      listingOwnerCompanyId: (json['listingOwnerCompanyId'] as num?)?.toInt(),
      listingOwnerCompanyName: ownerName,
      listingPostedByStaffId: (json['listingPostedByStaffId'] as num?)?.toInt(),
      requestedByCompanyId: (json['requestedByCompanyId'] as num?)?.toInt(),
      requestedByCompanyName: reqName,
      requestedByStaffId: (json['requestedByStaffId'] as num?)?.toInt(),
      shipperCompanyId: (json['shipperCompanyId'] as num?)?.toInt(),
      shipperCompanyName: shipperName,
      transporterCompanyId: (json['transporterCompanyId'] as num?)?.toInt(),
      transporterCompanyName: transporterName,
      offerId: (json['offerId'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num?)?.toInt(),
      vehicleNumber: json['vehicleNumber']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      driverId: (json['driverId'] as num?)?.toInt(),
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      agreedFreight: (json['agreedFreight'] as num?)?.toDouble() ?? 0.0,
      proposedFreight: (json['proposedFreight'] as num?)?.toDouble(),
      counterFreight: (json['counterFreight'] as num?)?.toDouble(),
      lastActionByCompanyId: (json['lastActionByCompanyId'] as num?)?.toInt(),
      paymentTerms: PaymentTermType.fromString(
        json['paymentTerms']?.toString(),
      ),
      advancePercentage: (json['advancePercentage'] as num?)?.toInt(),
      status: BookingStatus.fromString(
        (json['status'] ?? json['bookingStatus'])?.toString(),
      ),
      requestedCapacity: (json['requestedCapacity'] as num?)?.toDouble(),
      capacityUnit: json['capacityUnit'] != null
          ? CapacityUnit.fromString(json['capacityUnit'].toString())
          : null,
      originCity: json['originCity']?.toString(),
      originState: json['originState']?.toString(),
      destinationCity: json['destinationCity']?.toString(),
      destinationState: json['destinationState']?.toString(),
      cargoType: json['cargoType']?.toString(),
      weight: (json['weight'] as num?)?.toDouble(),
      rejectionReason: json['rejectionReason']?.toString(),
      remarks: json['remarks']?.toString(),
      bookedAt: json['bookedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
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
      if (proposedFreight != null) 'proposedFreight': proposedFreight,
      'paymentTerms': paymentTerms.name,
      if (advancePercentage != null) 'advancePercentage': advancePercentage,
      if (requestedCapacity != null) 'requestedCapacity': requestedCapacity,
      if (remarks != null && remarks!.isNotEmpty) 'remarks': remarks,
    };
  }
}
