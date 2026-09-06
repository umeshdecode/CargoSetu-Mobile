import 'dart:developer';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';

class CustomerService {
  final ApiRequest _api = ApiRequest();

  /// Fetch paginated list of customers
  Future<List<CustomerModel>> getCustomers({
    int pageNumber = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await _api.get(
        url: '${Urls.baseUrl}/api/v2/cargosetu/customer',
        queryParams: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body['dataList'] ?? body) : body;

        List items = [];
        if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        } else if (rawData is List) {
          items = rawData;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ Fetch customers error: $e');
      rethrow;
    }
  }

  /// Get single customer details by UUID
  Future<CustomerModel?> getCustomerByUuid(String uuid) async {
    try {
      final response = await _api.get(
        url: '${Urls.baseUrl}/api/v2/cargosetu/customer/$uuid',
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return CustomerModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ Get customer by UUID error: $e');
      rethrow;
    }
  }

  /// Create a new customer
  Future<bool> createCustomer(CustomerModel customer) async {
    try {
      final response = await _api.post(
        url: '${Urls.baseUrl}/api/v2/cargosetu/customer',
        data: customer.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map && body['responseCode'] != null) {
          return body['responseCode'] == 200 || body['responseCode'] == 201;
        }
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Create customer error: $e');
      rethrow;
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      final response = await _api.put(
        url: '${Urls.baseUrl}/api/v2/cargosetu/customer',
        data: customer.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map && body['responseCode'] != null) {
          return body['responseCode'] == 200 || body['responseCode'] == 201;
        }
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Update customer error: $e');
      rethrow;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(CustomerModel customer) async {
    try {
      final response = await _api.delete(
        url: '${Urls.baseUrl}/api/v2/cargosetu/customer',
        data: customer.toDeletePayload(),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map && body['responseCode'] != null) {
          return body['responseCode'] == 200;
        }
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Delete customer error: $e');
      rethrow;
    }
  }

  /// Fetch shifting types
  Future<List<String>> getShiftingTypes() async {
    try {
      final response = await _api.get(
        url: '${Urls.baseUrl}/api/v2/cargosetu/shifts/shifting-types',
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final list = body is Map ? (body['data'] ?? body['dataList'] ?? []) : body;
        if (list is List) {
          return list.map((e) => e.toString()).toList();
        }
      }
      return const [
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
    } catch (e) {
      log('⚠️ Get shifting types fallback: $e');
      return const [
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
    }
  }
}
