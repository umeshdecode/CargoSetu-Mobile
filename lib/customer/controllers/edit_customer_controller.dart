import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/customer/services/customer_service.dart';

class EditCustomerController extends GetxController {
  final CustomerService _service = CustomerService();
  final CustomerModel initialCustomer;

  EditCustomerController(this.initialCustomer);

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Personal details controllers
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController mobileCtrl;
  late final TextEditingController altMobileCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController workEmailCtrl;

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
    _initFromCustomer(initialCustomer);
    loadFullCustomerDetails();
  }

  void _initFromCustomer(CustomerModel c) {
    firstNameCtrl = TextEditingController(text: c.firstName);
    lastNameCtrl = TextEditingController(text: c.lastName);
    mobileCtrl = TextEditingController(text: c.mobileNo);
    altMobileCtrl = TextEditingController(text: c.alternateMobileNo);
    emailCtrl = TextEditingController(text: c.email);
    workEmailCtrl = TextEditingController(text: c.workEmail);

    shiftings.clear();
    if (c.shiftings.isNotEmpty) {
      for (var s in c.shiftings) {
        shiftings.add(CustomerShiftingItem.fromShifting(s));
      }
    } else {
      shiftings.add(CustomerShiftingItem(
        fromCity: c.shiftFromCity,
        toCity: c.shiftToCity,
        fromAddr: c.fromAddress ?? '',
        toAddr: c.toAddress ?? '',
        type: c.shiftingType ?? 'household',
        isCompleted: c.isShiftCompleted,
        startDate: c.shiftingStartDate,
        deliveryDate: c.shiftReachedDate,
      ));
    }
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

  /// If uuid is available, fetch full customer object with full charges from server
  Future<void> loadFullCustomerDetails() async {
    final uuid = initialCustomer.uuid;
    if (uuid == null || uuid.isEmpty) return;

    try {
      isLoading.value = true;
      final fullCustomer = await _service.getCustomerByUuid(uuid);
      if (fullCustomer != null && fullCustomer.shiftings.isNotEmpty) {
        for (var s in shiftings) {
          s.dispose();
        }
        shiftings.clear();
        for (var s in fullCustomer.shiftings) {
          shiftings.add(CustomerShiftingItem.fromShifting(s));
        }
        activeShiftIndex.value = 0;
      }
    } catch (e) {
      log('⚠️ Could not fetch full customer by UUID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void calculateTotals() {
    currentShifting.calculateTotals();
  }

  void _showFastTopError(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      'Validation Required',
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 12,
      isDismissible: true,
      forwardAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  Future<void> updateCustomer() async {
    if (firstNameCtrl.text.trim().isEmpty) {
      _showFastTopError('Please enter customer first name');
      return;
    }
    if (lastNameCtrl.text.trim().isEmpty) {
      _showFastTopError('Please enter customer last name');
      return;
    }
    if (mobileCtrl.text.trim().isEmpty) {
      _showFastTopError('Please enter customer mobile number');
      return;
    }

    String? firstErrorMessage;
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
      return;
    }

    isSaving.value = true;
    try {
      final shiftingModels = shiftings.map((s) => s.toShiftingModel()).toList();
      final firstShift = shiftings.first;

      final updatedCustomer = CustomerModel(
        customerId: initialCustomer.customerId,
        uuid: initialCustomer.uuid,
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

      final success = await _service.updateCustomer(updatedCustomer);
      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Customer updated successfully!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          animationDuration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: 12,
        );
      } else {
        _showFastTopError('Failed to update customer');
      }
    } catch (e) {
      _showFastTopError('Update failed: $e');
    } finally {
      isSaving.value = false;
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
