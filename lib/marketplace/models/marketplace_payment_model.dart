import 'marketplace_enums.dart';

class PaymentOrderModel {
  final int? id;
  final int? bookingId;
  final int? payerCompanyId;
  final int? payeeCompanyId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? providerRef;
  final String? idempotencyKey;
  final String? dueAt;
  final String? createdAt;

  PaymentOrderModel({
    this.id,
    this.bookingId,
    this.payerCompanyId,
    this.payeeCompanyId,
    required this.amount,
    this.currency = 'INR',
    this.status = PaymentStatus.PENDING,
    this.providerRef,
    this.idempotencyKey,
    this.dueAt,
    this.createdAt,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'] as int?,
      bookingId: json['bookingId'] as int?,
      payerCompanyId: json['payerCompanyId'] as int?,
      payeeCompanyId: json['payeeCompanyId'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      status: PaymentStatus.fromString(json['status']?.toString()),
      providerRef: json['providerRef']?.toString(),
      idempotencyKey: json['idempotencyKey']?.toString(),
      dueAt: json['dueAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bookingId != null) 'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    };
  }
}

class WalletStatementModel {
  final double balance;
  final double heldBalance;
  final double availableBalance;

  WalletStatementModel({
    required this.balance,
    required this.heldBalance,
    required this.availableBalance,
  });

  factory WalletStatementModel.fromJson(Map<String, dynamic> json) {
    final bal = (json['balance'] as num?)?.toDouble() ?? 0.0;
    final held = (json['heldBalance'] as num?)?.toDouble() ?? 0.0;
    return WalletStatementModel(
      balance: bal,
      heldBalance: held,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? (bal - held),
    );
  }
}
