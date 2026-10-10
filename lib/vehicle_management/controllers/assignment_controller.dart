import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class AssignmentController extends GetxController {
  final VehicleService _service = VehicleService();

  final RxList<DriverModel> drivers = <DriverModel>[].obs;
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;

  final Rx<DriverModel?> selectedDriver = Rx<DriverModel?>(null);
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);

  final RxString driverSearch = ''.obs;
  final RxString vehicleSearch = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isAssigning = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssignmentData();
  }

  Future<void> loadAssignmentData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.getDrivers(),
        _service.getVehicles(),
      ]);

      drivers.value = results[0] as List<DriverModel>;
      vehicles.value = results[1] as List<VehicleModel>;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to load drivers and vehicles');
      AppSnackbar.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  List<DriverModel> get filteredDrivers {
    final query = driverSearch.value.trim().toLowerCase();
    return drivers.where((d) {
      return query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.phoneNumber.toLowerCase().contains(query) ||
          d.licenseNumber.toLowerCase().contains(query);
    }).toList();
  }

  List<VehicleModel> get filteredVehicles {
    final query = vehicleSearch.value.trim().toLowerCase();
    return vehicles.where((v) {
      return query.isEmpty ||
          v.registrationNumber.toLowerCase().contains(query) ||
          v.manufacturer.toLowerCase().contains(query) ||
          v.model.toLowerCase().contains(query) ||
          v.vehicleType.toLowerCase().contains(query);
    }).toList();
  }

  bool get canAssign => selectedDriver.value != null && selectedVehicle.value != null;

  void selectDriver(DriverModel driver) {
    if (selectedDriver.value?.id == driver.id) {
      selectedDriver.value = null;
    } else {
      selectedDriver.value = driver;
    }
  }

  void selectVehicle(VehicleModel vehicle) {
    if (selectedVehicle.value?.id == vehicle.id) {
      selectedVehicle.value = null;
    } else {
      selectedVehicle.value = vehicle;
    }
  }

  Future<bool> assignDriverToVehicle() async {
    if (!canAssign) {
      AppSnackbar.error('Please select both a driver and a vehicle');
      return false;
    }

    final driver = selectedDriver.value!;
    final vehicle = selectedVehicle.value!;

    if (driver.id == null || vehicle.id == null) {
      AppSnackbar.error('Invalid driver or vehicle selection');
      return false;
    }

    isAssigning.value = true;
    try {
      final success = await _service.assignDriver(driver.id!, vehicle.id!);
      if (success) {
        selectedDriver.value = null;
        selectedVehicle.value = null;
        return true;
      } else {
        AppSnackbar.error('Failed to assign driver to vehicle');
        return false;
      }
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to assign driver');
      AppSnackbar.error(msg);
      return false;
    } finally {
      isAssigning.value = false;
    }
  }
}
