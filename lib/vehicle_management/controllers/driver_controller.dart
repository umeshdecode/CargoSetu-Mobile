import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import '../services/vehicle_service.dart';

class DriverController extends GetxController {
  final VehicleService _service = VehicleService();

  final RxList<DriverModel> drivers = <DriverModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString error = ''.obs;

  final RxString searchText = ''.obs;
  final RxString statusFilter = 'ALL'.obs; // ALL, ACTIVE, INACTIVE, SUSPENDED

  @override
  void onInit() {
    super.onInit();
    loadDrivers();
  }

  Future<void> loadDrivers() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await _service.getDrivers();
      drivers.value = list;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to load drivers');
      error.value = msg;
      AppSnackbar.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  List<DriverModel> get filteredDrivers {
    final query = searchText.value.trim().toLowerCase();
    final filter = statusFilter.value;

    return drivers.where((d) {
      final matchesSearch = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.phoneNumber.toLowerCase().contains(query) ||
          d.email.toLowerCase().contains(query) ||
          d.licenseNumber.toLowerCase().contains(query);

      final matchesStatus = filter == 'ALL' || d.status.toUpperCase() == filter.toUpperCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<bool> saveDriver({
    int? id,
    required String name,
    required String phoneNumber,
    required String email,
    required String licenseNumber,
    required String licenseExpiryDate,
    int? experienceYears,
    String? address,
    String status = 'ACTIVE',
    String? joiningDate,
  }) async {
    isSaving.value = true;
    try {
      final payload = {
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email.trim(),
        'licenseNumber': licenseNumber.trim().toUpperCase(),
        'licenseExpiryDate': licenseExpiryDate,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
        'status': status,
        if (joiningDate != null) 'joiningDate': joiningDate,
      };

      if (id != null) {
        payload['id'] = id;
        final res = await _service.updateDriver(id, payload);
        if (res != null) {
          await loadDrivers();
          return true;
        }
      } else {
        final res = await _service.createDriver(payload);
        if (res != null) {
          await loadDrivers();
          return true;
        }
      }
      AppSnackbar.error('Failed to save driver');
      return false;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to save driver');
      AppSnackbar.error(msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDriver(int id) async {
    isDeleting.value = true;
    try {
      final success = await _service.deleteDriver(id);
      if (success) {
        AppSnackbar.success('Driver deleted successfully');
        await loadDrivers();
        return true;
      } else {
        AppSnackbar.error('Failed to delete driver');
        return false;
      }
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to delete driver');
      AppSnackbar.error(msg);
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
