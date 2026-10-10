import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import '../models/vehicle_model.dart';
import '../models/truck_option_model.dart';
import '../models/vehicle_catalogue_models.dart';
import '../services/vehicle_service.dart';

class VehicleController extends GetxController {
  final VehicleService _service = VehicleService();

  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<TruckOptionModel> truckOptions = <TruckOptionModel>[].obs;

  // Catalogue Reactive State
  final RxList<CatalogueBrandModel> catalogueBrands = <CatalogueBrandModel>[].obs;
  final RxList<CatalogueModelItem> catalogueModels = <CatalogueModelItem>[].obs;
  final RxBool isCatalogueLoading = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString error = ''.obs;

  final RxString searchText = ''.obs;
  final RxString statusFilter = 'ALL'.obs; // ALL, AVAILABLE, ON_TRIP, MAINTENANCE, OUT_OF_SERVICE

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
    loadTruckOptions();
    loadCatalogueBrands();
    loadCatalogueModels();
  }

  Future<void> loadCatalogueBrands() async {
    try {
      final list = await _service.getCatalogueBrands();
      catalogueBrands.value = list;
    } catch (_) {}
  }

  Future<void> loadCatalogueModels([String? brandSlug]) async {
    isCatalogueLoading.value = true;
    try {
      final list = await _service.getCatalogueModels(brandSlug: brandSlug);
      catalogueModels.value = list;
    } catch (_) {
    } finally {
      isCatalogueLoading.value = false;
    }
  }

  Future<void> searchCatalogue(String keyword) async {
    if (keyword.trim().isEmpty) {
      return loadCatalogueModels();
    }
    isCatalogueLoading.value = true;
    try {
      final list = await _service.searchCatalogueModels(keyword.trim());
      catalogueModels.value = list;
    } catch (_) {
    } finally {
      isCatalogueLoading.value = false;
    }
  }

  Future<CatalogueDetailModel?> fetchCatalogueDetail(int id) async {
    try {
      return await _service.getCatalogueModelDetails(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadTruckOptions() async {
    try {
      final list = await _service.getTruckOptions();
      truckOptions.value = list;
    } catch (e) {
      // Non-blocking log
    }
  }

  Future<void> loadVehicles() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await _service.getVehicles();
      vehicles.value = list;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to load vehicles');
      error.value = msg;
      AppSnackbar.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  List<VehicleModel> get filteredVehicles {
    final query = searchText.value.trim().toLowerCase();
    final filter = statusFilter.value;

    return vehicles.where((v) {
      final matchesSearch = query.isEmpty ||
          v.registrationNumber.toLowerCase().contains(query) ||
          v.vehicleType.toLowerCase().contains(query) ||
          (v.truckType?.toLowerCase().contains(query) ?? false) ||
          (v.bodyType?.toLowerCase().contains(query) ?? false) ||
          v.model.toLowerCase().contains(query) ||
          v.manufacturer.toLowerCase().contains(query) ||
          (v.currentLocation?.toLowerCase().contains(query) ?? false);

      final matchesStatus = filter == 'ALL' || v.status.toUpperCase() == filter.toUpperCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<bool> saveVehicle({
    int? id,
    required String registrationNumber,
    required String vehicleType,
    required String model,
    required String manufacturer,
    required int capacityKg,
    required String chassisNumber,
    required String engineNumber,
    double? mileage,
    String status = 'AVAILABLE',
    String fuelType = 'DIESEL',
    String? registrationDate,
    String? insuranceExpiryDate,
    String? pollutionExpiryDate,
    String? currentLocation,

    String? truckType,
    String? bodyType,
    double? truckLengthFeet,
    String? lengthOption,
    int? wheelerCount,
    String? wheelerOption,
    double? passingCapacityTons,
    String? passingCapacityOption,
  }) async {
    isSaving.value = true;
    try {
      final payload = {
        'registrationNumber': registrationNumber.trim().toUpperCase(),
        'vehicleType': vehicleType,
        'model': model.trim(),
        'manufacturer': manufacturer.trim(),
        'capacityKg': capacityKg,
        'chassisNumber': chassisNumber.trim().toUpperCase(),
        'engineNumber': engineNumber.trim().toUpperCase(),
        if (mileage != null) 'mileage': mileage,
        'status': status,
        'fuelType': fuelType,
        if (registrationDate != null) 'registrationDate': registrationDate,
        if (insuranceExpiryDate != null) 'insuranceExpiryDate': insuranceExpiryDate,
        if (pollutionExpiryDate != null) 'pollutionExpiryDate': pollutionExpiryDate,
        if (currentLocation != null && currentLocation.trim().isNotEmpty)
          'currentLocation': currentLocation.trim(),

        if (truckType != null && truckType.isNotEmpty) 'truckType': truckType,
        if (bodyType != null && bodyType.isNotEmpty) 'bodyType': bodyType,
        if (truckLengthFeet != null) 'truckLengthFeet': truckLengthFeet,
        if (lengthOption != null && lengthOption.isNotEmpty) 'lengthOption': lengthOption,
        if (wheelerCount != null) 'wheelerCount': wheelerCount,
        if (wheelerOption != null && wheelerOption.isNotEmpty) 'wheelerOption': wheelerOption,
        if (passingCapacityTons != null) 'passingCapacityTons': passingCapacityTons,
        if (passingCapacityOption != null && passingCapacityOption.isNotEmpty) 'passingCapacityOption': passingCapacityOption,
      };

      if (id != null) {
        payload['id'] = id;
        final res = await _service.updateVehicle(id, payload);
        if (res != null) {
          await loadVehicles();
          return true;
        }
      } else {
        final res = await _service.createVehicle(payload);
        if (res != null) {
          await loadVehicles();
          return true;
        }
      }
      AppSnackbar.error('Failed to save vehicle');
      return false;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to save vehicle');
      AppSnackbar.error(msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    isDeleting.value = true;
    try {
      final success = await _service.deleteVehicle(id);
      if (success) {
        AppSnackbar.success('Vehicle deleted successfully');
        await loadVehicles();
        return true;
      } else {
        AppSnackbar.error('Failed to delete vehicle');
        return false;
      }
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to delete vehicle');
      AppSnackbar.error(msg);
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
