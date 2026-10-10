import 'dart:developer';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import '../models/vehicle_model.dart';
import '../models/driver_model.dart';
import '../models/vehicle_assignment_model.dart';
import '../models/truck_option_model.dart';
import '../models/vehicle_catalogue_models.dart';

class VehicleService {
  final ApiRequest _api = ApiRequest();

  // ─── VEHICLE CATALOGUE ────────────────────────────────────

  /// Get active vehicle brands (e.g. Tata, Eicher, Ashok Leyland, Mahindra, BharatBenz)
  Future<List<CatalogueBrandModel>> getCatalogueBrands() async {
    try {
      final response = await _api.get(url: Urls.catalogueBrands);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;
        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => CatalogueBrandModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getCatalogueBrands error: $e');
      return [];
    }
  }

  /// Get models by brand slug (e.g. ?brand=tata)
  Future<List<CatalogueModelItem>> getCatalogueModels({String? brandSlug}) async {
    try {
      final query = (brandSlug != null && brandSlug.isNotEmpty) ? {'brand': brandSlug} : null;
      final response = await _api.get(
        url: Urls.catalogueModels,
        queryParams: query,
      );
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;
        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => CatalogueModelItem.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getCatalogueModels error: $e');
      return [];
    }
  }

  /// Get model details by ID (specifications, payload, mileage, tyres, etc.)
  Future<CatalogueDetailModel?> getCatalogueModelDetails(int id) async {
    try {
      final response = await _api.get(url: Urls.catalogueModelById(id));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return CatalogueDetailModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getCatalogueModelDetails error: $e');
      return null;
    }
  }

  /// Search models by keyword (e.g. ?keyword=intra)
  Future<List<CatalogueModelItem>> searchCatalogueModels(String keyword) async {
    try {
      final response = await _api.get(
        url: Urls.catalogueSearch,
        queryParams: {'keyword': keyword},
      );
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;
        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => CatalogueModelItem.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ searchCatalogueModels error: $e');
      return [];
    }
  }

  // ─── VEHICLES ─────────────────────────────────────────────

  /// Fetch dynamic load options (truck types, body types, lengths, wheelers, tons)
  Future<List<TruckOptionModel>> getTruckOptions([String? truckType]) async {
    try {
      final query = truckType != null && truckType.isNotEmpty ? {'truckType': truckType} : null;
      final response = await _api.get(
        url: '${Urls.vehicle}/options',
        queryParams: query,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body['content'] ?? body) : body;

        List items = [];
        if (rawData is List) {
          items = rawData;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => TruckOptionModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ getTruckOptions error: $e');
      return [];
    }
  }

  /// Fetch all vehicles
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _api.get(url: Urls.vehicle);

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body['content'] ?? body) : body;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => VehicleModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ getVehicles error: $e');
      rethrow;
    }
  }

  /// Get single vehicle by ID
  Future<VehicleModel?> getVehicle(int id) async {
    try {
      final response = await _api.get(url: Urls.vehicleById(id));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return VehicleModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getVehicle error: $e');
      rethrow;
    }
  }

  /// Create a new vehicle
  Future<VehicleModel?> createVehicle(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(
        url: Urls.vehicle,
        data: payload,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return VehicleModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ createVehicle error: $e');
      rethrow;
    }
  }

  /// Update an existing vehicle
  Future<VehicleModel?> updateVehicle(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.put(
        url: Urls.vehicleById(id),
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return VehicleModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ updateVehicle error: $e');
      rethrow;
    }
  }

  /// Delete a vehicle by ID
  Future<bool> deleteVehicle(int id) async {
    try {
      final response = await _api.delete(url: Urls.vehicleById(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('❌ deleteVehicle error: $e');
      rethrow;
    }
  }

  // ─── DRIVERS ──────────────────────────────────────────────

  /// Fetch all drivers
  Future<List<DriverModel>> getDrivers() async {
    try {
      final response = await _api.get(url: Urls.drivers);

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body['content'] ?? body) : body;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => DriverModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ getDrivers error: $e');
      rethrow;
    }
  }

  /// Get single driver by ID
  Future<DriverModel?> getDriver(int id) async {
    try {
      final response = await _api.get(url: Urls.driverById(id));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return DriverModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getDriver error: $e');
      rethrow;
    }
  }

  /// Create a new driver
  Future<DriverModel?> createDriver(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(
        url: Urls.drivers,
        data: payload,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return DriverModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ createDriver error: $e');
      rethrow;
    }
  }

  /// Update an existing driver
  Future<DriverModel?> updateDriver(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.put(
        url: Urls.driverById(id),
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
        if (data is Map<String, dynamic>) {
          return DriverModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ updateDriver error: $e');
      rethrow;
    }
  }

  /// Delete a driver by ID
  Future<bool> deleteDriver(int id) async {
    try {
      final response = await _api.delete(url: Urls.driverById(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('❌ deleteDriver error: $e');
      rethrow;
    }
  }

  // ─── ASSIGNMENTS ──────────────────────────────────────────

  /// Fetch all vehicle assignments
  Future<List<VehicleAssignmentModel>> getAssignments() async {
    try {
      final response = await _api.get(url: Urls.assignments);

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body['content'] ?? body) : body;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => VehicleAssignmentModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ getAssignments error: $e');
      rethrow;
    }
  }

  /// Assign a driver to a vehicle
  Future<bool> assignDriver(int driverId, int vehicleId) async {
    try {
      final response = await _api.post(
        url: Urls.assignments,
        queryParams: {
          'driverId': driverId,
          'vehicleId': vehicleId,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ assignDriver error: $e');
      rethrow;
    }
  }

  /// Unassign an assignment by assignment ID
  Future<bool> unassignDriver(int assignmentId) async {
    try {
      final response = await _api.put(
        url: Urls.unassignDriver(assignmentId),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('❌ unassignDriver error: $e');
      rethrow;
    }
  }
}
