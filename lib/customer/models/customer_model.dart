import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExtraCharge {
  int? extraChargesId;
  String chargeName;
  double chargeValue;
  double chargeRate;

  ExtraCharge({
    this.extraChargesId,
    this.chargeName = '',
    this.chargeValue = 0.0,
    this.chargeRate = 0.0,
  });

  factory ExtraCharge.fromJson(Map<String, dynamic> json) {
    return ExtraCharge(
      extraChargesId: json['extraChargesId'] as int?,
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
        if (extraChargesId != null) 'extraChargesId': extraChargesId,
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
    final chargesJson = json['charges'] ?? json['chargesDTO'] ?? json['chargesDto'] ?? json['charge'] ?? {};
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
      isShiftCompleted: json['isShiftCompleted'] == true ||
          json['shiftCompleted'] == true ||
          json['is_shift_completed'] == true ||
          json['isShiftCompleted']?.toString() == 'true' ||
          json['shiftCompleted']?.toString() == 'true',
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
        'shiftCompleted': isShiftCompleted,
        if (shiftCompletedBy != null) 'shiftCompletedBy': shiftCompletedBy,
        if (shiftCompletedById != null) 'shiftCompletedById': shiftCompletedById,
        'tokenMoney': tokenMoney,
        'charges': charges.toJson(),
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
      : 'Customer --';

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

  bool get isCustomerCompleted {
    if (shiftings.isNotEmpty) {
      return shiftings.every((s) => s.isShiftCompleted);
    }
    return isShiftCompleted;
  }

  bool get shiftActive => !isCustomerCompleted;

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
      isShiftCompleted: json['isShiftCompleted'] == true ||
          json['shiftCompleted'] == true ||
          json['is_shift_completed'] == true ||
          json['isShiftCompleted']?.toString() == 'true' ||
          json['shiftCompleted']?.toString() == 'true',
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
        'isShiftCompleted': isCustomerCompleted,
        'shiftCompleted': isCustomerCompleted,
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

  static const List<String> defaultTypes = [
    'House Shifting',
    'Office Shifting',
    'Factory Shifting',
    'Mall Shifting',
    'Shop Shifting',
    'Warehouse Shifting',
    'Goods Shifting',
    'Govt. Related Shifting',
    'Medical Item Shifting',
    'Electronic Item Shift',
    'Liquid Items Shift',
    'Industrial Items Shift',
    'Others',
  ];

  static const Map<String, String> legacyMap = {
    'medical': 'Medical Item Shifting',
    'household': 'House Shifting',
    'office': 'Office Shifting',
    'vehicle': 'Goods Shifting',
  };

  /// Normalizes any incoming string (key, full label, uppercase, or fuzzy) to the official title string
  static String normalize(String? value, [List<String>? availableTypes]) {
    if (value == null || value.trim().isEmpty) return defaultTypes.first;
    final v = value.trim();
    final lower = v.toLowerCase();

    final typeList = (availableTypes != null && availableTypes.isNotEmpty) ? availableTypes : defaultTypes;

    // 1. Exact case-insensitive match against availableTypes or defaultTypes
    for (var type in typeList) {
      if (type.toLowerCase() == lower) return type;
    }

    // 2. Legacy key match
    if (legacyMap.containsKey(lower)) {
      final mapped = legacyMap[lower]!;
      for (var type in typeList) {
        if (type.toLowerCase() == mapped.toLowerCase()) return type;
      }
      return mapped;
    }

    // 3. Fuzzy matching
    if (lower.contains('medic')) return 'Medical Item Shifting';
    if (lower.contains('house')) return 'House Shifting';
    if (lower.contains('office') || lower.contains('corp')) return 'Office Shifting';
    if (lower.contains('vehic') || lower.contains('auto') || lower.contains('good') || lower.contains('haul')) {
      return 'Goods Shifting';
    }
    if (lower.contains('factor')) return 'Factory Shifting';
    if (lower.contains('mall')) return 'Mall Shifting';
    if (lower.contains('shop')) return 'Shop Shifting';
    if (lower.contains('warehous')) return 'Warehouse Shifting';
    if (lower.contains('govt')) return 'Govt. Related Shifting';
    if (lower.contains('electr')) return 'Electronic Item Shift';
    if (lower.contains('liquid')) return 'Liquid Items Shift';
    if (lower.contains('industr')) return 'Industrial Items Shift';

    for (var type in typeList) {
      if (lower.contains(type.toLowerCase())) return type;
    }

    return typeList.first;
  }

  /// Gets the human-readable label
  static String getLabel(String? key, [List<String>? availableTypes]) {
    return normalize(key, availableTypes);
  }

  /// Gets the matching Material Icon for a shifting type
  static IconData getIcon(String? type) {
    if (type == null) return Icons.local_shipping_outlined;
    final lower = type.toLowerCase();
    if (lower.contains('medic')) return Icons.medical_services_outlined;
    if (lower.contains('house') || lower.contains('home')) return Icons.home_work_outlined;
    if (lower.contains('office') || lower.contains('corp')) return Icons.business_outlined;
    if (lower.contains('factor') || lower.contains('industr')) return Icons.factory_outlined;
    if (lower.contains('mall') || lower.contains('shop')) return Icons.storefront_outlined;
    if (lower.contains('warehous') || lower.contains('storage')) return Icons.warehouse_outlined;
    if (lower.contains('vehic') || lower.contains('car') || lower.contains('auto')) return Icons.directions_car_outlined;
    if (lower.contains('electr')) return Icons.devices_outlined;
    if (lower.contains('liquid')) return Icons.water_drop_outlined;
    if (lower.contains('govt')) return Icons.account_balance_outlined;
    if (lower.contains('good')) return Icons.inventory_2_outlined;
    return Icons.local_shipping_outlined;
  }
}

/// State and controller manager for an individual extra charge item
class ExtraChargeItem {
  int? extraChargesId;
  final TextEditingController nameCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController valueCtrl;

  ExtraChargeItem({
    this.extraChargesId,
    String name = '',
    double rate = 0.0,
    double value = 0.0,
    VoidCallback? onChanged,
  })  : nameCtrl = TextEditingController(text: name),
        rateCtrl = TextEditingController(
          text: rate > 0 ? (rate % 1 == 0 ? rate.toInt().toString() : rate.toString()) : '',
        ),
        valueCtrl = TextEditingController(
          text: value > 0 ? (value % 1 == 0 ? value.toInt().toString() : value.toString()) : '',
        ) {
    if (onChanged != null) {
      nameCtrl.addListener(onChanged);
      rateCtrl.addListener(onChanged);
      valueCtrl.addListener(onChanged);
    }
  }

  void dispose() {
    nameCtrl.dispose();
    rateCtrl.dispose();
    valueCtrl.dispose();
  }
}

/// Structured state & controller manager for an individual shifting leg.
/// Used by CreateCustomerController and EditCustomerController for multiple shiftings.
class CustomerShiftingItem {
  int? shiftingId;
  int? chargeId;
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
  final TextEditingController serviceRateCtrl;
  final TextEditingController gstRateCtrl;

  // Extra charges list
  final RxList<ExtraChargeItem> extraCharges = <ExtraChargeItem>[].obs;

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
    this.chargeId,
    String fromCity = '',
    String toCity = '',
    String fromAddr = '',
    String toAddr = '',
    String type = 'House Shifting',
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
        ),
        serviceRateCtrl = TextEditingController(
          text: (charges?.serviceRate != null && charges!.serviceRate > 0)
              ? (charges.serviceRate % 1 == 0 ? charges.serviceRate.toInt().toString() : charges.serviceRate.toString())
              : '1',
        ),
        gstRateCtrl = TextEditingController(
          text: (charges?.gstRate != null && charges!.gstRate > 0)
              ? (charges.gstRate % 1 == 0 ? charges.gstRate.toInt().toString() : charges.gstRate.toString())
              : '18',
        ) {
    chargeId ??= charges?.chargeId;
    if (charges?.extraCharges != null && charges!.extraCharges.isNotEmpty) {
      final seen = <String>{};
      for (var ec in charges.extraCharges) {
        final key = '${ec.extraChargesId ?? ec.chargeName.trim().toLowerCase()}_${ec.chargeValue}_${ec.chargeRate}';
        if (seen.add(key)) {
          extraCharges.add(ExtraChargeItem(
            extraChargesId: ec.extraChargesId,
            name: ec.chargeName,
            rate: ec.chargeRate,
            value: ec.chargeValue,
            onChanged: calculateTotals,
          ));
        }
      }
    }
    double initialGst = double.tryParse(gstRateCtrl.text) ?? 18.0;
    gstApplicable.value = initialGst;
    _setupListeners();
    calculateTotals();
  }

  factory CustomerShiftingItem.fromShifting(Shifting s) {
    return CustomerShiftingItem(
      shiftingId: s.shiftingId,
      chargeId: s.charges.chargeId,
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

  void addExtraCharge([ExtraCharge? ec]) {
    extraCharges.add(ExtraChargeItem(
      extraChargesId: ec?.extraChargesId,
      name: ec?.chargeName ?? '',
      rate: ec?.chargeRate ?? 0.0,
      value: ec?.chargeValue ?? 0.0,
      onChanged: calculateTotals,
    ));
    calculateTotals();
  }

  void removeExtraCharge(int index) {
    if (index >= 0 && index < extraCharges.length) {
      extraCharges[index].dispose();
      extraCharges.removeAt(index);
      calculateTotals();
    }
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
      serviceRateCtrl,
      gstRateCtrl,
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
    double baseCharges = (double.tryParse(transportChargeCtrl.text) ?? 0.0) +
        (double.tryParse(packingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(loadingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(unloadingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(unpackingChargeCtrl.text) ?? 0.0) +
        (double.tryParse(carTransportChargeCtrl.text) ?? 0.0) +
        (double.tryParse(riskInsureChargeCtrl.text) ?? 0.0) +
        (double.tryParse(storageChargeCtrl.text) ?? 0.0) +
        (double.tryParse(statisticalChargeCtrl.text) ?? 0.0);

    double extraSum = 0.0;
    for (var ec in extraCharges) {
      double val = double.tryParse(ec.valueCtrl.text) ?? 0.0;
      if (val == 0.0) {
        double r = double.tryParse(ec.rateCtrl.text) ?? 0.0;
        if (r > 0 && baseCharges > 0) {
          val = baseCharges * (r / 100);
        }
      }
      extraSum += val;
    }

    double sRate = double.tryParse(serviceRateCtrl.text) ?? 1.0;
    double sCharge = double.tryParse(serviceChargeCtrl.text) ?? 0.0;
    // If service charge is not manually set but service rate > 0 and base charges exist
    if (sCharge == 0.0 && sRate > 0 && (baseCharges + extraSum) > 0) {
      sCharge = (baseCharges + extraSum) * (sRate / 100);
    }

    double sum = baseCharges + extraSum + sCharge;
    subtotal.value = sum;

    double gRate = double.tryParse(gstRateCtrl.text) ?? 18.0;
    gstApplicable.value = gRate;
    gstAmount.value = sum * (gRate / 100);
    totalAmount.value = sum + gstAmount.value;
    double advance = double.tryParse(advancePaidCtrl.text) ?? 0.0;
    netPayable.value = totalAmount.value - advance;
  }

  Shifting toShiftingModel() {
    final charges = Charges(
      chargeId: chargeId,
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
      serviceRate: double.tryParse(serviceRateCtrl.text) ?? 1.0,
      gstRate: double.tryParse(gstRateCtrl.text) ?? 18.0,
      gstCharge: gstAmount.value,
      extraCharges: () {
        final seen = <String>{};
        final uniqueExtras = <ExtraCharge>[];
        for (var e in extraCharges) {
          final name = e.nameCtrl.text.trim();
          final rate = double.tryParse(e.rateCtrl.text) ?? 0.0;
          final val = double.tryParse(e.valueCtrl.text) ?? 0.0;
          if (name.isNotEmpty || val > 0) {
            final key = '${e.extraChargesId ?? name.toLowerCase()}_${val}_${rate}';
            if (seen.add(key)) {
              uniqueExtras.add(ExtraCharge(
                extraChargesId: e.extraChargesId,
                chargeName: name,
                chargeRate: rate,
                chargeValue: val,
              ));
            }
          }
        }
        return uniqueExtras;
      }(),
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
    serviceRateCtrl.dispose();
    gstRateCtrl.dispose();
    for (var ec in extraCharges) {
      ec.dispose();
    }
  }
}

