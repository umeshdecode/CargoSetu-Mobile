import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/customer/services/customer_service.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';

class CreateCustomerController extends GetxController {
  final CustomerService _service = CustomerService();

  final isLoading = false.obs;

  // Shifting types observable (initialized with default 13 types, updated from API)
  final shiftingTypesList = <String>[...ShiftingTypeHelper.defaultTypes].obs;

  // Controllers for personal details
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final altMobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final workEmailCtrl = TextEditingController();

  // Personal details error observables
  final firstNameError = ''.obs;
  final lastNameError = ''.obs;
  final mobileError = ''.obs;

  // Multiple shiftings list & active tab
  final shiftings = <CustomerShiftingItem>[].obs;
  final activeShiftIndex = 0.obs;

  CustomerShiftingItem get currentShifting =>
      shiftings.isNotEmpty ? shiftings[activeShiftIndex.value] : shiftings.first;

  // Convenience getters forwarding to current active shifting
  TextEditingController get shiftFromCityCtrl => currentShifting.shiftFromCityCtrl;
  TextEditingController get shiftToCityCtrl => currentShifting.shiftToCityCtrl;
  TextEditingController get fromAddressCtrl => currentShifting.fromAddressCtrl;
  TextEditingController get toAddressCtrl => currentShifting.toAddressCtrl;
  RxString get shiftingType => currentShifting.shiftingType;
  RxBool get isShiftCompleted => currentShifting.isShiftCompleted;
  Rx<DateTime?> get shiftingStartDate => currentShifting.shiftingStartDate;
  Rx<DateTime?> get expectedDeliveryDate => currentShifting.expectedDeliveryDate;
  TextEditingController get advancePaidCtrl => currentShifting.advancePaidCtrl;
  TextEditingController get transportChargeCtrl => currentShifting.transportChargeCtrl;
  TextEditingController get packingChargeCtrl => currentShifting.packingChargeCtrl;
  TextEditingController get loadingChargeCtrl => currentShifting.loadingChargeCtrl;
  TextEditingController get unloadingChargeCtrl => currentShifting.unloadingChargeCtrl;
  TextEditingController get unpackingChargeCtrl => currentShifting.unpackingChargeCtrl;
  TextEditingController get carTransportChargeCtrl => currentShifting.carTransportChargeCtrl;
  TextEditingController get riskInsureChargeCtrl => currentShifting.riskInsureChargeCtrl;
  TextEditingController get storageChargeCtrl => currentShifting.storageChargeCtrl;
  TextEditingController get statisticalChargeCtrl => currentShifting.statisticalChargeCtrl;
  TextEditingController get serviceChargeCtrl => currentShifting.serviceChargeCtrl;
  TextEditingController get serviceRateCtrl => currentShifting.serviceRateCtrl;
  TextEditingController get gstRateCtrl => currentShifting.gstRateCtrl;
  RxList<ExtraChargeItem> get extraCharges => currentShifting.extraCharges;
  void addExtraCharge([ExtraCharge? ec]) => currentShifting.addExtraCharge(ec);
  void removeExtraCharge(int index) => currentShifting.removeExtraCharge(index);

  RxDouble get subtotal => currentShifting.subtotal;
  RxDouble get gstAmount => currentShifting.gstAmount;
  RxDouble get totalAmount => currentShifting.totalAmount;
  RxDouble get netPayable => currentShifting.netPayable;
  RxDouble get gstApplicable => currentShifting.gstApplicable;
  RxString get fromCityError => currentShifting.fromCityError;
  RxString get toCityError => currentShifting.toCityError;

  @override
  void onInit() {
    super.onInit();
    shiftings.add(CustomerShiftingItem());
    _setupPersonalFieldListeners();
    loadShiftingTypes();
  }

  Future<void> loadShiftingTypes() async {
    try {
      final types = await _service.getShiftingTypes();
      if (types.isNotEmpty) {
        shiftingTypesList.assignAll(types.toSet().toList());
        for (var s in shiftings) {
          s.shiftingType.value = ShiftingTypeHelper.normalize(s.shiftingType.value, shiftingTypesList);
        }
      }
    } catch (e) {
      log('⚠️ Error loading shifting types: $e');
    }
  }

  void _setupPersonalFieldListeners() {
    firstNameCtrl.addListener(() {
      if (firstNameCtrl.text.trim().isNotEmpty) firstNameError.value = '';
    });
    lastNameCtrl.addListener(() {
      if (lastNameCtrl.text.trim().isNotEmpty) lastNameError.value = '';
    });
    mobileCtrl.addListener(() {
      if (mobileCtrl.text.trim().isNotEmpty) mobileError.value = '';
    });
  }

  void addShifting() {
    shiftings.add(CustomerShiftingItem());
    activeShiftIndex.value = shiftings.length - 1;
  }

  void removeShifting(int index) {
    if (shiftings.length <= 1) return;
    shiftings[index].dispose();
    shiftings.removeAt(index);
    if (activeShiftIndex.value >= shiftings.length) {
      activeShiftIndex.value = shiftings.length - 1;
    }
  }

  void setActiveShift(int index) {
    if (index >= 0 && index < shiftings.length) {
      activeShiftIndex.value = index;
    }
  }

  void calculateTotals() {
    currentShifting.calculateTotals();
  }

  void _showFastTopError(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    AppSnackbar.warning(message);
  }

  bool validateInputs() {
    firstNameError.value = '';
    lastNameError.value = '';
    mobileError.value = '';

    String? firstErrorMessage;

    if (firstNameCtrl.text.trim().isEmpty) {
      firstNameError.value = 'First name is required';
      firstErrorMessage ??= 'Please enter customer first name';
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      lastNameError.value = 'Last name is required';
      firstErrorMessage ??= 'Please enter customer last name';
    }

    final mobile = mobileCtrl.text.trim();
    if (mobile.isEmpty) {
      mobileError.value = 'Mobile number is required';
      firstErrorMessage ??= 'Please enter primary mobile number';
    } else if (mobile.replaceAll(RegExp(r'\D'), '').length < 10) {
      mobileError.value = 'Enter valid 10-digit mobile number';
      firstErrorMessage ??= 'Mobile number must be at least 10 digits';
    }

    for (int i = 0; i < shiftings.length; i++) {
      final s = shiftings[i];
      s.fromCityError.value = '';
      s.toCityError.value = '';
      if (s.shiftFromCityCtrl.text.trim().isEmpty) {
        s.fromCityError.value = 'Origin city is required';
        if (firstErrorMessage == null) {
          activeShiftIndex.value = i;
          firstErrorMessage = shiftings.length > 1
              ? 'Please enter Pickup Origin City (From) for Shifting ${i + 1}'
              : 'Please enter Pickup Origin City (From)';
        }
      }
      if (s.shiftToCityCtrl.text.trim().isEmpty) {
        s.toCityError.value = 'Destination city is required';
        if (firstErrorMessage == null) {
          activeShiftIndex.value = i;
          firstErrorMessage = shiftings.length > 1
              ? 'Please enter Destination City (To) for Shifting ${i + 1}'
              : 'Please enter Destination City (To)';
        }
      }
    }

    if (firstErrorMessage != null) {
      _showFastTopError(firstErrorMessage);
      return false;
    }

    return true;
  }

  Future<void> createCustomer() async {
    if (!validateInputs()) return;

    isLoading.value = true;

    try {
      final shiftingModels = shiftings.map((s) => s.toShiftingModel()).toList();
      final firstShift = shiftings.first;

      final newCustomer = CustomerModel(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        mobileNo: mobileCtrl.text.trim(),
        alternateMobileNo: altMobileCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        workEmail: workEmailCtrl.text.trim(),
        isShiftCompleted: shiftings.every((s) => s.isShiftCompleted.value),
        shiftFromCity: firstShift.shiftFromCityCtrl.text.trim(),
        shiftToCity: firstShift.shiftToCityCtrl.text.trim(),
        fromAddress: firstShift.fromAddressCtrl.text.trim(),
        toAddress: firstShift.toAddressCtrl.text.trim(),
        shiftingType: firstShift.shiftingType.value,
        shiftingStartDate: firstShift.shiftingStartDate.value,
        shiftReachedDate: firstShift.expectedDeliveryDate.value,
        shiftings: shiftingModels,
      );

      bool success = await _service.createCustomer(newCustomer);
      if (success) {
        Get.back(result: true);
        AppSnackbar.success('Customer created successfully!');
      } else {
        _showFastTopError('Failed to create customer. Please check input values.');
      }
    } catch (e) {
      _showFastTopError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    mobileCtrl.dispose();
    altMobileCtrl.dispose();
    emailCtrl.dispose();
    workEmailCtrl.dispose();
    for (var s in shiftings) {
      s.dispose();
    }
    super.onClose();
  }
}
