import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExtraCharge {
  String chargeName;
  double chargeValue;
  double chargeRate;

  ExtraCharge({
    this.chargeName = '',
    this.chargeValue = 0.0,
    this.chargeRate = 0.0,
  });

  factory ExtraCharge.fromJson(Map<String, dynamic> json) {
    return ExtraCharge(
      chargeName: json['chargeName']?.toString() ?? '',
      chargeValue: (json['chargeValue'] is num)
          ? (json['chargeValue'] as num).toDouble()
          : double.tryParse(json['chargeValue']?.toString() ?? '0') ?? 0.0,
      chargeRate: (json['chargeRate'] is num)
          ? (json['chargeRate'] as num).toDouble()
          : double.tryParse(json['chargeRate']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'chargeName': chargeName,
        'chargeValue': chargeValue,
        'chargeRate': chargeRate,
      };
}

class Charges {
  int? chargeId;
  double transportCharge;
  double packingCharge;
  double loadingCharge;
  double unloadingCharge;
  double unpackingCharge;
  double carTransportCharge;
  double riskInsureCharge;
  double storageCharge;
  double statisticalCharge;
  double serviceCharge;
  double serviceRate;
  double gstRate;
  double gstCharge;
  List<ExtraCharge> extraCharges;
  double advancePaid;

  Charges({
    this.chargeId,
    this.transportCharge = 0.0,
    this.packingCharge = 0.0,
    this.loadingCharge = 0.0,
    this.unloadingCharge = 0.0,
    this.unpackingCharge = 0.0,
    this.carTransportCharge = 0.0,
    this.riskInsureCharge = 0.0,
    this.storageCharge = 0.0,
    this.statisticalCharge = 0.0,
    this.serviceCharge = 0.0,
    this.serviceRate = 1.0,
    this.gstRate = 18.0,
    this.gstCharge = 0.0,
    List<ExtraCharge>? extraCharges,
    this.advancePaid = 0.0,
  }) : extraCharges = extraCharges ?? [];

  static double _numToDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? def;
  }

  factory Charges.fromJson(Map<String, dynamic> json) {
    var rawExtras = json['extracharges'] ?? json['extraChargesList'] ?? [];
    List<ExtraCharge> extras = [];
    if (rawExtras is List) {
      extras = rawExtras
          .whereType<Map<String, dynamic>>()
          .map((e) => ExtraCharge.fromJson(e))
          .toList();
    }

    return Charges(
      chargeId: json['chargeId'] as int?,
      transportCharge: _numToDouble(json['transportCharge']),
      packingCharge: _numToDouble(json['packingCharge']),
      loadingCharge: _numToDouble(json['loadingCharge']),
      unloadingCharge: _numToDouble(json['unloadingCharge']),
      unpackingCharge: _numToDouble(json['unpackingCharge']),
      carTransportCharge: _numToDouble(json['carTransportCharge']),
      riskInsureCharge: _numToDouble(json['riskInsureCharge']),
      storageCharge: _numToDouble(json['storageCharge']),
      statisticalCharge: _numToDouble(json['statisticalCharge']),
      serviceCharge: _numToDouble(json['serviceCharge']),
      serviceRate: _numToDouble(json['serviceRate'], 1.0),
      gstRate: _numToDouble(json['gstRate'], 18.0),
      gstCharge: _numToDouble(json['gstCharge']),
      extraCharges: extras,
      advancePaid: _numToDouble(json['advancePaid'] ?? json['tokenMoney']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (chargeId != null) 'chargeId': chargeId,
        'transportCharge': transportCharge,
        'packingCharge': packingCharge,
        'loadingCharge': loadingCharge,
        'unloadingCharge': unloadingCharge,
        'unpackingCharge': unpackingCharge,
        'carTransportCharge': carTransportCharge,
        'riskInsureCharge': riskInsureCharge,
        'storageCharge': storageCharge,
        'statisticalCharge': statisticalCharge,
        'serviceCharge': serviceCharge,
        'serviceRate': serviceRate,
        'gstRate': gstRate,
        'gstCharge': gstCharge,
        'extracharges': extraCharges.map((e) => e.toJson()).toList(),
      };
}

class Shifting {
  int? shiftingId;
  String shiftFromCity;
  String shiftToCity;
  String fromAddress;
  String toAddress;
  String shiftingType;
  DateTime? shiftingStartDate;
  DateTime? shiftReachedDate;
  bool isShiftCompleted;
  String? shiftCompletedBy;
  int? shiftCompletedById;
  double tokenMoney;
  Charges charges;

  Shifting({
    this.shiftingId,
    this.shiftFromCity = '',
    this.shiftToCity = '',
    this.fromAddress = '',
    this.toAddress = '',
    this.shiftingType = 'household',
    this.shiftingStartDate,
    this.shiftReachedDate,
    this.isShiftCompleted = false,
    this.shiftCompletedBy,
    this.shiftCompletedById,
    this.tokenMoney = 0.0,
    Charges? charges,
  }) : charges = charges ?? Charges();

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is String && val.isNotEmpty) {
      return DateTime.tryParse(val);
    }
    return null;
  }

  factory Shifting.fromJson(Map<String, dynamic> json) {
    final chargesJson = json['charges'] ?? json['chargesDTO'] ?? {};
    Charges chargesObj = chargesJson is Map<String, dynamic>
        ? Charges.fromJson(chargesJson)
        : Charges();

    double token = (json['tokenMoney'] is num)
        ? (json['tokenMoney'] as num).toDouble()
        : double.tryParse(json['tokenMoney']?.toString() ?? '0') ?? 0.0;

    if (token > 0 && chargesObj.advancePaid == 0) {
      chargesObj.advancePaid = token;
    }

    return Shifting(
      shiftingId: json['shiftingId'] as int?,
      shiftFromCity: json['shiftFromCity']?.toString() ?? '',
      shiftToCity: json['shiftToCity']?.toString() ?? '',
      fromAddress: json['fromAddress']?.toString() ?? '',
      toAddress: json['toAddress']?.toString() ?? '',
      shiftingType: json['shiftingType']?.toString() ?? 'household',
      shiftingStartDate: _parseDate(json['shiftingStartDate']),
      shiftReachedDate: _parseDate(json['shiftReachedDate']),
      isShiftCompleted: json['isShiftCompleted'] == true,
      shiftCompletedBy: json['shiftCompletedBy']?.toString(),
      shiftCompletedById: json['shiftCompletedById'] as int?,
      tokenMoney: token,
      charges: chargesObj,
    );
  }

  Map<String, dynamic> toJson() => {
        if (shiftingId != null) 'shiftingId': shiftingId,
        'shiftFromCity': shiftFromCity,
        'shiftToCity': shiftToCity,
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'shiftingType': shiftingType,
        if (shiftingStartDate != null)
          'shiftingStartDate': shiftingStartDate!.toIso8601String().substring(0, 10),
        if (shiftReachedDate != null)
          'shiftReachedDate': shiftReachedDate!.toIso8601String().substring(0, 10),
        'isShiftCompleted': isShiftCompleted,
        if (shiftCompletedBy != null) 'shiftCompletedBy': shiftCompletedBy,
        if (shiftCompletedById != null) 'shiftCompletedById': shiftCompletedById,
        'tokenMoney': tokenMoney,
        'chargesDTO': charges.toJson(),
      };
}

class CustomerModel {
  int? customerId;
  String firstName;
  String lastName;
  String mobileNo;
  String alternateMobileNo;
  String email;
  String workEmail;
  bool isShiftCompleted;
  String shiftFromCity;
  String shiftToCity;
  String? fromAddress;
  String? toAddress;
  String? shiftingType;
  DateTime? shiftingStartDate;
  DateTime? shiftReachedDate;
  int? companyId;
  String? uuid;
  List<Shifting> shiftings;

  CustomerModel({
    this.customerId,
    this.firstName = '',
    this.lastName = '',
    this.mobileNo = '',
    this.alternateMobileNo = '',
    this.email = '',
    this.workEmail = '',
    this.isShiftCompleted = false,
    this.shiftFromCity = '',
    this.shiftToCity = '',
    this.fromAddress,
    this.toAddress,
    this.shiftingType,
    this.shiftingStartDate,
    this.shiftReachedDate,
    this.companyId,
    this.uuid,
    List<Shifting>? shiftings,
  }) : shiftings = shiftings ?? [Shifting()];

  String get fullName => '$firstName $lastName'.trim().isNotEmpty
      ? '$firstName $lastName'.trim()
      : 'Customer #$customerId';

  String get routeSummary {
    if (shiftings.isNotEmpty) {
      final s = shiftings.first;
      if (s.shiftFromCity.isNotEmpty && s.shiftToCity.isNotEmpty) {
        if (shiftings.length > 1) {
          return '${s.shiftFromCity} → ${s.shiftToCity} (+${shiftings.length - 1} more)';
        }
        return '${s.shiftFromCity} → ${s.shiftToCity}';
      }
    }
    if (shiftFromCity.isNotEmpty && shiftToCity.isNotEmpty) {
      return '$shiftFromCity → $shiftToCity';
    }
    return 'Location not specified';
  }

  bool get shiftActive {
    if (shiftings.isNotEmpty) {
      return !shiftings.first.isShiftCompleted;
    }
    return !isShiftCompleted;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    List<Shifting> parsedShiftings = [];
    if (json['shiftings'] is List) {
      parsedShiftings = (json['shiftings'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => Shifting.fromJson(s))
          .toList();
    }

    DateTime? startDate;
    if (json['shiftingStartDate'] != null) {
      startDate = DateTime.tryParse(json['shiftingStartDate'].toString());
    }

    DateTime? reachedDate;
    if (json['shiftReachedDate'] != null) {
      reachedDate = DateTime.tryParse(json['shiftReachedDate'].toString());
    }

    return CustomerModel(
      customerId: json['customerId'] as int?,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      alternateMobileNo: json['alternateMobileNo']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      workEmail: json['workEmail']?.toString() ?? '',
      isShiftCompleted: json['isShiftCompleted'] == true,
      shiftFromCity: json['shiftFromCity']?.toString() ?? '',
      shiftToCity: json['shiftToCity']?.toString() ?? '',
      fromAddress: json['fromAddress']?.toString(),
      toAddress: json['toAddress']?.toString(),
      shiftingType: json['shiftingType']?.toString(),
      shiftingStartDate: startDate,
      shiftReachedDate: reachedDate,
      companyId: json['companyId'] as int?,
      uuid: json['uuid']?.toString(),
      shiftings: parsedShiftings.isNotEmpty ? parsedShiftings : [Shifting()],
    );
  }

  Map<String, dynamic> toJson() => {
        if (customerId != null) 'customerId': customerId,
        'firstName': firstName,
        'lastName': lastName,
        'mobileNo': mobileNo,
        'alternateMobileNo': alternateMobileNo,
        'email': email,
        'workEmail': workEmail,
        if (uuid != null) 'uuid': uuid,
        'isShiftCompleted': isShiftCompleted,
        'shiftings': shiftings.map((s) => s.toJson()).toList(),
      };

  Map<String, dynamic> toDeletePayload() => {
        'customerId': customerId ?? 0,
        'firstName': firstName,
        'lastName': lastName,
        'mobileNo': mobileNo,
        'alternateMobileNo': alternateMobileNo,
        'email': email,
        'workEmail': workEmail,
        'uuid': uuid ?? '',
      };
}

/// Helper for safely managing and normalizing shifting categories and types
class ShiftingTypeHelper {
  ShiftingTypeHelper._();

  static const Map<String, String> typeMap = {
    'medical': 'Medical Item Shifting',
    'household': 'Household Relocation',
    'office': 'Corporate & Office Shifting',
    'vehicle': 'Automobile & Heavy Haulage',
  };

  /// Normalizes any incoming string (key, full label, uppercase, or fuzzy) to a canonical key
  static String normalize(String? value) {
    if (value == null || value.trim().isEmpty) return 'household';
    final v = value.trim();
    final lower = v.toLowerCase();

    // 1. Direct key match
    if (typeMap.containsKey(lower)) return lower;

    // 2. Direct label match (case insensitive)
    for (var entry in typeMap.entries) {
      if (entry.value.toLowerCase() == lower) return entry.key;
    }

    // 3. Fuzzy matching
    if (lower.contains('medic')) return 'medical';
    if (lower.contains('house')) return 'household';
    if (lower.contains('office') || lower.contains('corp')) return 'office';
    if (lower.contains('vehic') || lower.contains('auto') || lower.contains('haul') || lower.contains('heavy')) {
      return 'vehicle';
    }

    return 'household';
  }

  /// Gets the human-readable label
  static String getLabel(String? key) {
    return typeMap[normalize(key)] ?? 'Household Relocation';
  }
}

/// Structured state & controller manager for an individual shifting leg.
/// Used by CreateCustomerController and EditCustomerController for multiple shiftings.
class CustomerShiftingItem {
  int? shiftingId;
  final TextEditingController shiftFromCityCtrl;
  final TextEditingController shiftToCityCtrl;
  final TextEditingController fromAddressCtrl;
  final TextEditingController toAddressCtrl;
  final RxString shiftingType;
  final RxBool isShiftCompleted;
  final Rx<DateTime?> shiftingStartDate;
  final Rx<DateTime?> expectedDeliveryDate;

  // Controllers for charges
  final TextEditingController advancePaidCtrl;
  final TextEditingController transportChargeCtrl;
  final TextEditingController packingChargeCtrl;
  final TextEditingController loadingChargeCtrl;
  final TextEditingController unloadingChargeCtrl;
  final TextEditingController unpackingChargeCtrl;
  final TextEditingController carTransportChargeCtrl;
  final TextEditingController riskInsureChargeCtrl;
  final TextEditingController storageChargeCtrl;
  final TextEditingController statisticalChargeCtrl;
  final TextEditingController serviceChargeCtrl;

  // Calculated observables
  final RxDouble subtotal = 0.0.obs;
  final RxDouble gstAmount = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble netPayable = 0.0.obs;
  final RxDouble gstApplicable = 18.0.obs;

  // Field validation observables
  final RxString fromCityError = ''.obs;
  final RxString toCityError = ''.obs;

  CustomerShiftingItem({
    this.shiftingId,
    String fromCity = '',
    String toCity = '',
    String fromAddr = '',
    String toAddr = '',
    String type = 'household',
    bool isCompleted = false,
    DateTime? startDate,
    DateTime? deliveryDate,
    Charges? charges,
    double tokenMoney = 0.0,
  })  : shiftFromCityCtrl = TextEditingController(text: fromCity),
        shiftToCityCtrl = TextEditingController(text: toCity),
        fromAddressCtrl = TextEditingController(text: fromAddr),
        toAddressCtrl = TextEditingController(text: toAddr),
        shiftingType = ShiftingTypeHelper.normalize(type).obs,
        isShiftCompleted = isCompleted.obs,
        shiftingStartDate = Rx<DateTime?>(startDate),
        expectedDeliveryDate = Rx<DateTime?>(deliveryDate),
        advancePaidCtrl = TextEditingController(
          text: (charges?.advancePaid != null && charges!.advancePaid > 0)
              ? charges.advancePaid.toStringAsFixed(0)
              : (tokenMoney > 0 ? tokenMoney.toStringAsFixed(0) : ''),
        ),
        transportChargeCtrl = TextEditingController(
          text: (charges?.transportCharge != null && charges!.transportCharge > 0)
              ? charges.transportCharge.toStringAsFixed(0)
              : '',
        ),
        packingChargeCtrl = TextEditingController(
          text: (charges?.packingCharge != null && charges!.packingCharge > 0)
              ? charges.packingCharge.toStringAsFixed(0)
              : '',
        ),
        loadingChargeCtrl = TextEditingController(
          text: (charges?.loadingCharge != null && charges!.loadingCharge > 0)
              ? charges.loadingCharge.toStringAsFixed(0)
              : '',
        ),
        unloadingChargeCtrl = TextEditingController(
          text: (charges?.unloadingCharge != null && charges!.unloadingCharge > 0)
              ? charges.unloadingCharge.toStringAsFixed(0)
              : '',
        ),
        unpackingChargeCtrl = TextEditingController(
          text: (charges?.unpackingCharge != null && charges!.unpackingCharge > 0)
              ? charges.unpackingCharge.toStringAsFixed(0)
              : '',
        ),
        carTransportChargeCtrl = TextEditingController(
          text: (charges?.carTransportCharge != null && charges!.carTransportCharge > 0)
              ? charges.carTransportCharge.toStringAsFixed(0)
              : '',
        ),
        riskInsureChargeCtrl = TextEditingController(
          text: (charges?.riskInsureCharge != null && charges!.riskInsureCharge > 0)
              ? charges.riskInsureCharge.toStringAsFixed(0)
              : '',
        ),
        storageChargeCtrl = TextEditingController(
          text: (charges?.storageCharge != null && charges!.storageCharge > 0)
              ? charges.storageCharge.toStringAsFixed(0)
              : '',
        ),
        statisticalChargeCtrl = TextEditingController(
          text: (charges?.statisticalCharge != null && charges!.statisticalCharge > 0)
              ? charges.statisticalCharge.toStringAsFixed(0)
              : '',
        ),
        serviceChargeCtrl = TextEditingController(
          text: (charges?.serviceCharge != null && charges!.serviceCharge > 0)
              ? charges.serviceCharge.toStringAsFixed(0)
              : '',
        ) {
    if (charges?.gstRate != null && charges!.gstRate > 0) {
      gstApplicable.value = charges.gstRate;
    }
    _setupListeners();
    calculateTotals();
  }

  factory CustomerShiftingItem.fromShifting(Shifting s) {
    return CustomerShiftingItem(
      shiftingId: s.shiftingId,
      fromCity: s.shiftFromCity,
      toCity: s.shiftToCity,
      fromAddr: s.fromAddress,
      toAddr: s.toAddress,
      type: s.shiftingType,
      isCompleted: s.isShiftCompleted,
      startDate: s.shiftingStartDate,
      deliveryDate: s.shiftReachedDate,
      charges: s.charges,
      tokenMoney: s.tokenMoney,
    );
  }

  void _setupListeners() {
    final chargeControllers = [
      transportChargeCtrl,
      packingChargeCtrl,
      loadingChargeCtrl,
      unloadingChargeCtrl,
      unpackingChargeCtrl,
      carTransportChargeCtrl,
      riskInsureChargeCtrl,
      storageChargeCtrl,
      statisticalChargeCtrl,
      serviceChargeCtrl,
      advancePaidCtrl,
    ];
    for (var ctrl in chargeControllers) {
      ctrl.addListener(calculateTotals);
    }
    shiftFromCityCtrl.addListener(() {
      if (shiftFromCityCtrl.text.trim().isNotEmpty) fromCityError.value = '';
    });
    shiftToCityCtrl.addListener(() {
      if (shiftToCityCtrl.text.trim().isNotEmpty) toCityError.value = '';
    });
  }

  void calculateTotals() {
    double sum = (double.tryParse(transportChargeCtrl.text) ?? 0.0) +
        (double.tryParse(packingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(loadingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(unloadingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(unpackingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(carTransportChargeCtrl.text) ?? 0.0) +
        (double.tryParse(riskInsureChargeCtrl.text) ?? 0.0) +
        (double.tryParse(storageChargeCtrl.text) ?? 0.0) +
        (double.tryParse(statisticalChargeCtrl.text) ?? 0.0) +
        (double.tryParse(serviceChargeCtrl.text) ?? 0.0);

    subtotal.value = sum;
    gstAmount.value = sum * (gstApplicable.value / 100);
    totalAmount.value = sum + gstAmount.value;
    double advance = double.tryParse(advancePaidCtrl.text) ?? 0.0;
    netPayable.value = totalAmount.value - advance;
  }

  Shifting toShiftingModel() {
    final charges = Charges(
      transportCharge: double.tryParse(transportChargeCtrl.text) ?? 0.0,
      packingCharge: double.tryParse(packingChargeCtrl.text) ?? 0.0,
      loadingCharge: double.tryParse(loadingChargeCtrl.text) ?? 0.0,
      unloadingCharge: double.tryParse(unloadingChargeCtrl.text) ?? 0.0,
      unpackingCharge: double.tryParse(unpackingChargeCtrl.text) ?? 0.0,
      carTransportCharge: double.tryParse(carTransportChargeCtrl.text) ?? 0.0,
      riskInsureCharge: double.tryParse(riskInsureChargeCtrl.text) ?? 0.0,
      storageCharge: double.tryParse(storageChargeCtrl.text) ?? 0.0,
      statisticalCharge: double.tryParse(statisticalChargeCtrl.text) ?? 0.0,
      serviceCharge: double.tryParse(serviceChargeCtrl.text) ?? 0.0,
      gstRate: gstApplicable.value,
      gstCharge: gstAmount.value,
      advancePaid: double.tryParse(advancePaidCtrl.text) ?? 0.0,
    );

    return Shifting(
      shiftingId: shiftingId,
      shiftFromCity: shiftFromCityCtrl.text.trim(),
      shiftToCity: shiftToCityCtrl.text.trim(),
      fromAddress: fromAddressCtrl.text.trim(),
      toAddress: toAddressCtrl.text.trim(),
      shiftingType: ShiftingTypeHelper.normalize(shiftingType.value),
      shiftingStartDate: shiftingStartDate.value,
      shiftReachedDate: expectedDeliveryDate.value,
      isShiftCompleted: isShiftCompleted.value,
      tokenMoney: double.tryParse(advancePaidCtrl.text) ?? 0.0,
      charges: charges,
    );
  }

  void dispose() {
    shiftFromCityCtrl.dispose();
    shiftToCityCtrl.dispose();
    fromAddressCtrl.dispose();
    toAddressCtrl.dispose();
    advancePaidCtrl.dispose();
    transportChargeCtrl.dispose();
    packingChargeCtrl.dispose();
    loadingChargeCtrl.dispose();
    unloadingChargeCtrl.dispose();
    unpackingChargeCtrl.dispose();
    carTransportChargeCtrl.dispose();
    riskInsureChargeCtrl.dispose();
    storageChargeCtrl.dispose();
    statisticalChargeCtrl.dispose();
    serviceChargeCtrl.dispose();
  }
}

