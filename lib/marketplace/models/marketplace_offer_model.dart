import 'marketplace_enums.dart';

class MarketplaceOfferModel {
  final int? id;
  final int? listingId;
  final String? listingNumber;
  final ListingType? listingType;
  final ListingStatus? listingStatus;
  final int? listingOwnerCompanyId;
  final String? listingOwnerCompanyName;
  final int? listingPostedByStaffId;
  final String? originCity;
  final String? originState;
  final String? destinationCity;
  final String? destinationState;
  final double? listingAskingPrice;
  final CargoType? cargoType;
  final double? weight;
  final CapacityUnit? weightUnit;
  final int? bidderCompanyId;
  final String? bidderCompanyName;
  final int? offeredByStaffId;
  final String? offeredByStaffName;
  final double offeredAmount;
  final int? advancePercentage;
  final PaymentTermType? paymentTerms;
  final String? availableFrom;
  final String? validUntil;
  final String? remarks;
  final OfferStatus status;
  final int? parentOfferId;
  final String? createdAt;
  final String? updatedAt;
  final int? latestCounterOfferId;
  final double? latestCounterAmount;
  final OfferStatus? latestCounterStatus;
  final String? latestCounterRemarks;

  int? get offeredByCompanyId => bidderCompanyId;
  String? get offeredByCompanyName => bidderCompanyName;

  MarketplaceOfferModel({
    this.id,
    this.listingId,
    this.listingNumber,
    this.listingType,
    this.listingStatus,
    this.listingOwnerCompanyId,
    this.listingOwnerCompanyName,
    this.listingPostedByStaffId,
    this.originCity,
    this.originState,
    this.destinationCity,
    this.destinationState,
    this.listingAskingPrice,
    this.cargoType,
    this.weight,
    this.weightUnit,
    this.bidderCompanyId,
    this.bidderCompanyName,
    this.offeredByStaffId,
    this.offeredByStaffName,
    required this.offeredAmount,
    this.advancePercentage,
    this.paymentTerms,
    this.availableFrom,
    this.validUntil,
    this.remarks,
    this.status = OfferStatus.PENDING,
    this.parentOfferId,
    this.createdAt,
    this.updatedAt,
    this.latestCounterOfferId,
    this.latestCounterAmount,
    this.latestCounterStatus,
    this.latestCounterRemarks,
  });

  factory MarketplaceOfferModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceOfferModel(
      id: (json['id'] as num?)?.toInt(),
      listingId: (json['listingId'] as num?)?.toInt(),
      listingNumber: json['listingNumber']?.toString(),
      listingType: json['listingType'] != null
          ? ListingType.fromString(json['listingType'].toString())
          : null,
      listingStatus: json['listingStatus'] != null
          ? ListingStatus.fromString(json['listingStatus'].toString())
          : null,
      listingOwnerCompanyId: (json['listingOwnerCompanyId'] as num?)?.toInt(),
      listingOwnerCompanyName: json['listingOwnerCompanyName']?.toString(),
      listingPostedByStaffId: (json['listingPostedByStaffId'] as num?)?.toInt(),
      originCity: json['originCity']?.toString(),
      originState: json['originState']?.toString(),
      destinationCity: json['destinationCity']?.toString(),
      destinationState: json['destinationState']?.toString(),
      listingAskingPrice: (json['listingAskingPrice'] as num?)?.toDouble(),
      cargoType: json['cargoType'] != null
          ? CargoType.fromString(json['cargoType'].toString())
          : null,
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] != null
          ? CapacityUnit.fromString(json['weightUnit'].toString())
          : null,
      bidderCompanyId: (json['bidderCompanyId'] as num?)?.toInt(),
      bidderCompanyName: json['bidderCompanyName']?.toString(),
      offeredByStaffId: (json['offeredByStaffId'] as num?)?.toInt(),
      offeredByStaffName: (json['offeredByName'] ?? json['offeredByStaffName'])
          ?.toString(),
      offeredAmount:
          ((json['amount'] ?? json['offeredAmount']) as num?)?.toDouble() ??
          0.0,
      advancePercentage: (json['advancePercentage'] as num?)?.toInt(),
      paymentTerms: json['paymentTerms'] != null
          ? PaymentTermType.fromString(json['paymentTerms'].toString())
          : null,
      availableFrom: json['availableFrom']?.toString(),
      validUntil: json['validUntil']?.toString(),
      remarks: (json['message'] ?? json['remarks'])?.toString(),
      status: OfferStatus.fromString(json['status']?.toString()),
      parentOfferId: (json['parentOfferId'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      latestCounterOfferId: (json['latestCounterOfferId'] as num?)?.toInt(),
      latestCounterAmount: (json['latestCounterAmount'] as num?)?.toDouble(),
      latestCounterStatus: json['latestCounterStatus'] != null
          ? OfferStatus.fromString(json['latestCounterStatus'].toString())
          : null,
      latestCounterRemarks: json['latestCounterRemarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': offeredAmount,
      if (paymentTerms != null) 'paymentTerms': paymentTerms!.name,
      if (validUntil != null) 'validUntil': validUntil,
      if (remarks != null) 'message': remarks,
    };
  }
}
