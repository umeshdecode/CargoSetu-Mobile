import 'marketplace_enums.dart';

class MarketplaceOfferModel {
  final int? id;
  final int? listingId;
  final String? listingNumber;
  final int? bidderCompanyId;
  final String? bidderCompanyName;
  final int? offeredByStaffId;
  final String? offeredByStaffName;
  final double offeredAmount;
  final int? advancePercentage;
  final PaymentTermType? paymentTerms;
  final String? availableFrom;
  final String? remarks;
  final OfferStatus status;
  final int? parentOfferId;
  final String? createdAt;

  MarketplaceOfferModel({
    this.id,
    this.listingId,
    this.listingNumber,
    this.bidderCompanyId,
    this.bidderCompanyName,
    this.offeredByStaffId,
    this.offeredByStaffName,
    required this.offeredAmount,
    this.advancePercentage,
    this.paymentTerms,
    this.availableFrom,
    this.remarks,
    this.status = OfferStatus.PENDING,
    this.parentOfferId,
    this.createdAt,
  });

  factory MarketplaceOfferModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceOfferModel(
      id: json['id'] as int?,
      listingId: json['listingId'] as int?,
      listingNumber: json['listingNumber']?.toString(),
      bidderCompanyId: json['bidderCompanyId'] as int?,
      bidderCompanyName: json['bidderCompanyName']?.toString(),
      offeredByStaffId: json['offeredByStaffId'] as int?,
      offeredByStaffName: json['offeredByStaffName']?.toString(),
      offeredAmount: (json['offeredAmount'] as num?)?.toDouble() ?? 0.0,
      advancePercentage: json['advancePercentage'] as int?,
      paymentTerms: json['paymentTerms'] != null
          ? PaymentTermType.fromString(json['paymentTerms'].toString())
          : null,
      availableFrom: json['availableFrom']?.toString(),
      remarks: json['remarks']?.toString(),
      status: OfferStatus.fromString(json['status']?.toString()),
      parentOfferId: json['parentOfferId'] as int?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (listingId != null) 'listingId': listingId,
      'amount': offeredAmount,
      'offeredAmount': offeredAmount,
      if (advancePercentage != null) 'advancePercentage': advancePercentage,
      if (paymentTerms != null) 'paymentTerms': paymentTerms!.name,
      if (availableFrom != null) 'availableFrom': availableFrom,
      if (remarks != null) 'message': remarks,
      if (remarks != null) 'remarks': remarks,
      'status': status.name,
      if (parentOfferId != null) 'parentOfferId': parentOfferId,
    };
  }
}
