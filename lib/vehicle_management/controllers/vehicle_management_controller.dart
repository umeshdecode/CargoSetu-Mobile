import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import '../models/vehicle_model.dart';
import '../models/driver_model.dart';
import '../models/vehicle_assignment_model.dart';
import '../services/vehicle_service.dart';

class VehicleManagementController extends GetxController {
  final VehicleService _service = VehicleService();

  final RxBool isLoading = false.obs;
  final RxBool isUnassigning = false.obs;
  final RxString error = ''.obs;

  // Counts for hub stat cards
  final RxInt vehicleCount = 0.obs;
  final RxInt driverCount = 0.obs;
  final RxInt activeAssignmentCount = 0.obs;

  // Assignments
  final RxList<VehicleAssignmentModel> allAssignments = <VehicleAssignmentModel>[].obs;
  final RxString searchText = ''.obs;
  final RxString statusFilter = 'All'.obs; // All, Active, Inactive

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    error.value = '';

    try {
      // Fetch vehicles, drivers, and assignments in parallel
      final results = await Future.wait([
        _service.getVehicles().catchError((_) => <VehicleModel>[]),
        _service.getDrivers().catchError((_) => <DriverModel>[]),
        _service.getAssignments().catchError((_) => <VehicleAssignmentModel>[]),
      ]);

      final vehicles = results[0] as List;
      final drivers = results[1] as List;
      final assignments = results[2] as List<VehicleAssignmentModel>;

      vehicleCount.value = vehicles.length;
      driverCount.value = drivers.length;
      allAssignments.value = assignments;
      activeAssignmentCount.value = assignments.where((a) => a.active).length;
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to load vehicle management data');
      error.value = msg;
      AppSnackbar.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  List<VehicleAssignmentModel> get filteredAssignments {
    final query = searchText.value.trim().toLowerCase();
    final filter = statusFilter.value;

    return allAssignments.where((item) {
      final matchesSearch = query.isEmpty ||
          item.driverName.toLowerCase().contains(query) ||
          item.registrationNumber.toLowerCase().contains(query) ||
          item.driverId.toString().contains(query) ||
          item.vehicleId.toString().contains(query);

      final matchesStatus = filter == 'All' ||
          (filter == 'Active' && item.active) ||
          (filter == 'Inactive' && !item.active);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> unassign(int assignmentId) async {
    isUnassigning.value = true;
    try {
      final success = await _service.unassignDriver(assignmentId);
      if (success) {
        AppSnackbar.success('Driver unassigned successfully');
        await loadDashboardData();
      } else {
        AppSnackbar.error('Failed to unassign driver');
      }
    } catch (e) {
      final msg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to unassign driver');
      AppSnackbar.error(msg);
    } finally {
      isUnassigning.value = false;
    }
  }
}
