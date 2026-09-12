import 'dart:developer';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/quotation/models/shifting_list_model.dart';
import 'package:cargo_setu/quotation/services/shifting_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/packing_item_model.dart';
import '../services/packing_list_service.dart';

class PackingListController extends GetxController {
  final ShiftingApiService _shiftingApiService = ShiftingApiService();
  final PackingListService _packingListService = PackingListService();

  // ─── SHIFTINGS LIST & SEARCH ──────────────────────────────
  final RxList<ShiftingListItem> allShiftings = <ShiftingListItem>[].obs;
  final RxBool isLoadingShiftings = false.obs;
  final RxString loadError = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasMoreShiftings = true.obs;

  int _currentPage = 0;
  final int _pageSize = 15;

  // ─── SELECTED SHIFTING & PACKING ITEMS ────────────────────
  final Rxn<ShiftingListItem> selectedShifting = Rxn<ShiftingListItem>();
  final RxList<PackingItemModel> packingItems = <PackingItemModel>[].obs;
  final RxBool isLoadingItems = false.obs;
  final RxBool isSavingItem = false.obs;
  final RxString itemsError = ''.obs;

  // Search/Filter within current packing list
  final RxString itemSearchQuery = ''.obs;

  // Categories & Conditions
  final List<String> itemCategories = const [
    'Furniture',
    'Electronics',
    'Kitchenware',
    'Appliances',
    'Fragile Items',
    'Clothing & Linen',
    'Books & Documents',
    'Cartons & Boxes',
    'Miscellaneous',
  ];

  final List<String> itemConditions = const [
    'Good',
    'Minor Scratch',
    'Minor Dent',
    'Damaged',
    'Fragile',
    'New',
  ];

  final List<String> quickItemSuggestions = const [
    'Sofa Set (3+1+1)',
    'Double Bed with Mattress',
    'LED TV 55 inch',
    'Refrigerator (Double Door)',
    'Washing Machine',
    'Dining Table (6 Seater)',
    'Carton Box Heavy',
    'Microwave Oven',
    'Air Conditioner (1.5 Ton)',
    'Wardrobe / Almirah',
    'Study Table & Chair',
    'Gas Cylinder',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchShiftings(refresh: true);

    debounce(searchQuery, (_) => fetchShiftings(refresh: true),
        time: const Duration(milliseconds: 400));
  }

  // Filtered packaging items (for local search within a shifting's packing list)
  List<PackingItemModel> get filteredPackingItems {
    if (itemSearchQuery.value.trim().isEmpty) {
      return packingItems;
    }
    final q = itemSearchQuery.value.toLowerCase().trim();
    return packingItems.where((item) {
      return item.itemName.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.packageNumber.toLowerCase().contains(q) ||
          item.conditionStatus.toLowerCase().contains(q) ||
          item.remarks.toLowerCase().contains(q);
    }).toList();
  }

  // Computed next Auto Sr. No
  int get nextSrNo => packingItems.length + 1;

  // Auto generated Box/Packaging Number with shiftId scope to prevent collisions
  String generateNextBoxNo() {
    final shifting = selectedShifting.value;
    final shiftId = shifting?.shiftingId ?? 0;

    int maxNum = 0;
    final regExp = RegExp(r'\d+');
    for (var item in packingItems) {
      final matches = regExp.allMatches(item.packageNumber);
      for (var match in matches) {
        final val = int.tryParse(match.group(0) ?? '');
        if (val != null && val > maxNum) {
          maxNum = val;
        }
      }
    }

    final nextNum = (maxNum >= packingItems.length ? maxNum : packingItems.length) + 1;

    if (shiftId > 0) {
      return 'BOX-S$shiftId-${nextNum.toString().padLeft(3, '0')}';
    }
    return 'BOX-${nextNum.toString().padLeft(3, '0')}';
  }

  // Helper to construct fallback incremented package number
  String _incrementPkgNo(String originalPkgNo, int attempt) {
    if (originalPkgNo.isEmpty) {
      return generateNextBoxNo();
    }
    final regExp = RegExp(r'^(.*?)(?:-(\d+))?$');
    final match = regExp.firstMatch(originalPkgNo);
    if (match != null) {
      final base = match.group(1) ?? originalPkgNo;
      final numStr = match.group(2);
      if (numStr != null) {
        final val = int.tryParse(numStr) ?? 0;
        return '$base-${val + attempt}';
      }
    }
    return '$originalPkgNo-$attempt';
  }

  // ─── FETCH SHIFTINGS ──────────────────────────────────────
  Future<void> fetchShiftings({bool refresh = false}) async {
    if (isLoadingShiftings.value || (!hasMoreShiftings.value && !refresh)) return;

    if (refresh) {
      _currentPage = 0;
      allShiftings.clear();
      hasMoreShiftings.value = true;
      loadError.value = '';
    }

    isLoadingShiftings.value = true;

    try {
      List<ShiftingListItem> result;
      if (searchQuery.value.trim().isNotEmpty) {
        result = await _shiftingApiService.searchShiftings(
          query: searchQuery.value.trim(),
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
      } else {
        result = await _shiftingApiService.getShiftings(
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
      }

      if (result.length < _pageSize) {
        hasMoreShiftings.value = false;
      }

      if (refresh) {
        allShiftings.assignAll(result);
      } else {
        allShiftings.addAll(result);
      }
      _currentPage++;
    } catch (e) {
      log('Error fetching shiftings in PackingListController: $e');
      loadError.value = ApiRequest.formatErrorMessage(e);
    } finally {
      isLoadingShiftings.value = false;
    }
  }

  // ─── SELECT SHIFTING & FETCH PACKING ITEMS ───────────────
  void selectShifting(ShiftingListItem shifting) {
    selectedShifting.value = shifting;
    itemSearchQuery.value = '';
    fetchPackingItems(shifting.shiftingId);
  }

  Future<void> fetchPackingItems(int shiftId) async {
    isLoadingItems.value = true;
    itemsError.value = '';
    try {
      final items = await _packingListService.getPackingItems(shiftId);
      packingItems.assignAll(items);
    } catch (e) {
      log('Error fetching packing items: $e');
      itemsError.value = ApiRequest.formatErrorMessage(e);
    } finally {
      isLoadingItems.value = false;
    }
  }

  // ─── ADD PACKING ITEM ────────────────────────────────────
  Future<bool> addPackingItem({
    required String itemName,
    required String category,
    required String packageNumber,
    required String conditionStatus,
    String roomName = 'General',
    String remarks = '',
  }) async {
    final shifting = selectedShifting.value;
    if (shifting == null) return false;

    isSavingItem.value = true;
    try {
      String finalPkgNo = packageNumber.trim().isEmpty
          ? generateNextBoxNo()
          : packageNumber.trim();

      PackingItemModel newItem = PackingItemModel(
        shiftId: shifting.shiftingId,
        roomName: roomName.trim().isEmpty ? 'General' : roomName.trim(),
        itemName: itemName.trim(),
        category: category.trim().isEmpty ? 'Miscellaneous' : category.trim(),
        packageNumber: finalPkgNo,
        conditionStatus: conditionStatus.trim().isEmpty ? 'Good' : conditionStatus.trim(),
        remarks: remarks.trim(),
      );

      PackingItemModel? created;
      int retryAttempts = 0;
      while (retryAttempts < 3) {
        try {
          created = await _packingListService.createPackingItem(newItem);
          break; // Success!
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('duplicate') ||
              errStr.contains('uk2f4p96q0yokroa6y7g6xqs3qe') ||
              errStr.contains('500')) {
            retryAttempts++;
            finalPkgNo = _incrementPkgNo(finalPkgNo, retryAttempts);
            newItem = newItem.copyWith(packageNumber: finalPkgNo);
            log('⚠️ Duplicate packaging number detected. Auto incrementing to: $finalPkgNo (Attempt $retryAttempts)');
          } else {
            rethrow;
          }
        }
      }

      if (created != null) {
        packingItems.add(created);
      } else {
        packingItems.add(newItem);
      }

      Get.snackbar(
        'Item Added Successfully!',
        '${itemName.trim()} (Packaging No: $finalPkgNo) added to list.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      log('Error adding packing item: $e');
      Get.snackbar(
        'Failed to Add',
        ApiRequest.formatErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSavingItem.value = false;
    }
  }

  // ─── UPDATE PACKING ITEM ─────────────────────────────────
  Future<bool> updatePackingItem({
    required int index,
    required PackingItemModel updatedItem,
  }) async {
    if (updatedItem.id == null) {
      packingItems[index] = updatedItem;
      return true;
    }

    isSavingItem.value = true;
    try {
      final res = await _packingListService.updatePackingItem(
        updatedItem.id!,
        updatedItem,
      );

      if (res != null) {
        packingItems[index] = res;
      } else {
        packingItems[index] = updatedItem;
      }

      Get.snackbar(
        'Item Updated',
        'Packaging item updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      log('Error updating packing item: $e');
      Get.snackbar(
        'Failed to Update',
        ApiRequest.formatErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSavingItem.value = false;
    }
  }

  // ─── DELETE PACKING ITEM ─────────────────────────────────
  Future<void> deletePackingItem(int index) async {
    final item = packingItems[index];
    if (item.id != null) {
      final success = await _packingListService.deletePackingItem(item.id!);
      if (!success) {
        Get.snackbar(
          'Delete Failed',
          'Could not delete item from server.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return;
      }
    }
    packingItems.removeAt(index);
    Get.snackbar(
      'Item Removed',
      'Item removed from packaging list.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF64748B),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
