import 'package:cargo_setu/customer/models/customer_model.dart';

class ShiftingListItem {
  int shiftingId;
  String shiftFromCity;
  String shiftToCity;
  String fromAddress;
  String toAddress;
  String shiftingType;
  DateTime? shiftingStartDate;
  DateTime? shiftReachedDate;
  bool isShiftCompleted;
  int? customerId;
  int? companyId;
  double tokenMoney;
  String customerName;
  String customerMobileNo;
  String customerEmail;
  Charges charges;

  ShiftingListItem({
    required this.shiftingId,
    this.shiftFromCity = '',
    this.shiftToCity = '',
    this.fromAddress = '',
    this.toAddress = '',
    this.shiftingType = '',
    this.shiftingStartDate,
    this.shiftReachedDate,
    this.isShiftCompleted = false,
    this.customerId,
    this.companyId,
    this.tokenMoney = 0.0,
    this.customerName = '',
    this.customerMobileNo = '',
    this.customerEmail = '',
    required this.charges,
  });

  String get routeSummary => '$shiftFromCity → $shiftToCity';

  double get grandTotal {
    double total = 0.0;
    total += charges.transportCharge;
    total += charges.packingCharge;
    total += charges.loadingCharge;
    total += charges.unloadingCharge;
    total += charges.unpackingCharge;
    total += charges.carTransportCharge;
    total += charges.riskInsureCharge;
    total += charges.storageCharge;
    total += charges.statisticalCharge;
    total += charges.serviceCharge;
    total += charges.gstCharge;
    for (var extra in charges.extraCharges) {
      total += extra.chargeValue;
    }
    return total;
  }

  factory ShiftingListItem.fromJson(Map<String, dynamic> json) {
    return ShiftingListItem(
      shiftingId: json['shiftingId'] ?? 0,
      shiftFromCity: json['shiftFromCity'] ?? '',
      shiftToCity: json['shiftToCity'] ?? '',
      fromAddress: json['fromAddress'] ?? '',
      toAddress: json['toAddress'] ?? '',
      shiftingType: json['shiftingType'] ?? '',
      shiftingStartDate: json['shiftingStartDate'] != null
          ? DateTime.tryParse(json['shiftingStartDate'])
          : null,
      shiftReachedDate: json['shiftReachedDate'] != null
          ? DateTime.tryParse(json['shiftReachedDate'])
          : null,
      isShiftCompleted: json['isShiftCompleted'] ?? false,
      customerId: json['customerId'],
      companyId: json['companyId'],
      tokenMoney: (json['tokenMoney'] is num)
          ? (json['tokenMoney'] as num).toDouble()
          : double.tryParse(json['tokenMoney']?.toString() ?? '0') ?? 0.0,
      customerName: json['customerName'] ?? '',
      customerMobileNo: json['customerMobileNo'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      charges: json['charges'] != null
          ? Charges.fromJson(json['charges'])
          : Charges(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftingId': shiftingId,
      'shiftFromCity': shiftFromCity,
      'shiftToCity': shiftToCity,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'shiftingType': shiftingType,
      'shiftingStartDate': shiftingStartDate?.toIso8601String(),
      'shiftReachedDate': shiftReachedDate?.toIso8601String(),
      'isShiftCompleted': isShiftCompleted,
      'customerId': customerId,
      'companyId': companyId,
      'tokenMoney': tokenMoney,
      'customerName': customerName,
      'customerMobileNo': customerMobileNo,
      'customerEmail': customerEmail,
      'charges': charges.toJson(),
    };
  }
}
