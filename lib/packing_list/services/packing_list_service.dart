import 'dart:developer';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import '../models/packing_item_model.dart';

class PackingListService {
  final ApiRequest _api = ApiRequest();

  /// Fetch all packing list items for a specific shift ID
  Future<List<PackingItemModel>> getPackingItems(int shiftId) async {
    try {
      final response = await _api.get(
        url: Urls.shiftInventoryByShiftId(shiftId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => PackingItemModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error fetching packing items for shift $shiftId: $e');
      rethrow;
    }
  }

  /// Create a single packing item
  Future<PackingItemModel?> createPackingItem(PackingItemModel item) async {
    try {
      final response = await _api.post(
        url: Urls.shiftInventory,
        data: item.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;
        if (rawData is Map<String, dynamic>) {
          return PackingItemModel.fromJson(rawData);
        }
      }
      return null;
    } catch (e) {
      log('Error creating packing item: $e');
      rethrow;
    }
  }

  /// Update an existing packing item
  Future<PackingItemModel?> updatePackingItem(int itemId, PackingItemModel item) async {
    try {
      final response = await _api.put(
        url: Urls.shiftInventoryItem(itemId),
        data: item.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;
        if (rawData is Map<String, dynamic>) {
          return PackingItemModel.fromJson(rawData);
        }
      }
      return null;
    } catch (e) {
      log('Error updating packing item $itemId: $e');
      rethrow;
    }
  }

  /// Delete a packing item by ID
  Future<bool> deletePackingItem(int itemId) async {
    try {
      final response = await _api.delete(
        url: Urls.shiftInventoryItem(itemId),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Error deleting packing item $itemId: $e');
      return false;
    }
  }
}
