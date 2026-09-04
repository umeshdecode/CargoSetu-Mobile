import 'dart:developer';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/customer/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerManagementController extends GetxController {
  final CustomerService _service = CustomerService();

  final RxList<CustomerModel> allCustomers = <CustomerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString loadError = ''.obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // 'All', 'In Progress', 'Completed'

  final int _pageSize = 15;
  int _currentPage = 0;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers(refresh: true);
  }

  /// Filtered customers list based on search and status
  List<CustomerModel> get filteredCustomers {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return allCustomers.where((customer) {
      // Status filter
      if (filter == 'In Progress' && !customer.shiftActive) return false;
      if (filter == 'Completed' && customer.shiftActive) return false;

      // Search query
      if (query.isEmpty) return true;

      final searchable = [
        customer.fullName,
        customer.mobileNo,
        customer.alternateMobileNo,
        customer.email,
        customer.workEmail,
        customer.uuid ?? '',
        customer.routeSummary,
        customer.shiftingType ?? '',
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  int get totalCount => allCustomers.length;
  int get activeShiftCount => allCustomers.where((c) => c.shiftActive).length;
  int get completedShiftCount => allCustomers.where((c) => !c.shiftActive).length;

  /// Fetch customers from API
  Future<void> fetchCustomers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      hasMore.value = true;
      isLoading.value = true;
      loadError.value = '';
    }

    try {
      final list = await _service.getCustomers(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        allCustomers.assignAll(list);
      } else {
        allCustomers.addAll(list);
      }

      if (list.length < _pageSize) {
        hasMore.value = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      log('⚠️ Error fetching customers: $e');
      loadError.value = 'Failed to load customers. Pull to try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a customer with confirmation
  Future<void> confirmDeleteCustomer(BuildContext context, CustomerModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 8),
            Text('Delete Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${customer.fullName}? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      isDeleting.value = true;
      try {
        final success = await _service.deleteCustomer(customer);
        if (success) {
          allCustomers.removeWhere((c) =>
              (c.customerId != null && c.customerId == customer.customerId) ||
              (c.uuid != null && c.uuid == customer.uuid));
          Get.snackbar(
            'Deleted',
            'Customer ${customer.fullName} deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
          );
        } else {
          Get.snackbar('Error', 'Unable to delete customer');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete customer: $e');
      } finally {
        isDeleting.value = false;
      }
    }
  }
}
