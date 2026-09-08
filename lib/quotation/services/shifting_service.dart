import 'dart:developer';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import '../models/shifting_list_model.dart';

class ShiftingApiService {
  final ApiRequest _api = ApiRequest();

  Future<List<ShiftingListItem>> getShiftings({int pageNumber = 0, int pageSize = 15}) async {
    try {
      final response = await _api.get(
        url: Urls.shifts,
        queryParams: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;

        List items = [];
        if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        } else if (rawData is List) {
          items = rawData;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => ShiftingListItem.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error fetching shiftings: $e');
      rethrow;
    }
  }

  Future<List<ShiftingListItem>> searchShiftings({required String query, int pageNumber = 0, int pageSize = 15}) async {
    try {
      final response = await _api.get(
        url: Urls.shiftsSearch,
        queryParams: {
          'query': query,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;

        List items = [];
        if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        } else if (rawData is List) {
          items = rawData;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => ShiftingListItem.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error searching shiftings: $e');
      rethrow;
    }
  }
}
