import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/load_post_model.dart';
import '../models/truck_post_model.dart';
import '../models/marketplace_offer_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';

class MarketplaceHubController extends GetxController {
  final MarketplaceService _service = MarketplaceService();

  // Tab State: 0 = Loads, 1 = Trucks, 2 = My Posts
  final RxInt currentTabIndex = 0.obs;

  // Data State
  final RxList<LoadPostModel> loads = <LoadPostModel>[].obs;
  final RxList<TruckPostModel> trucks = <TruckPostModel>[].obs;
  final RxList<LoadPostModel> myLoads = <LoadPostModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Active Filter state
  final Rx<String?> filterOrigin = Rx<String?>(null);
  final Rx<String?> filterDestination = Rx<String?>(null);
  final Rx<CargoType?> filterCargoType = Rx<CargoType?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchMarketplaceFeed();
  }

  void setTab(int index) {
    currentTabIndex.value = index;
    if (index == 0 && loads.isEmpty) {
      fetchLoads();
    } else if (index == 1 && trucks.isEmpty) {
      fetchTrucks();
    } else if (index == 2 && myLoads.isEmpty) {
      fetchMyListings();
    }
  }

  Future<void> fetchMarketplaceFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        fetchLoads(),
        fetchTrucks(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load marketplace listings.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLoads() async {
    try {
      final results = await _service.searchLoads(
        originCity: filterOrigin.value,
        destinationCity: filterDestination.value,
        cargoType: filterCargoType.value?.name,
      );
      loads.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Failed to load loads feed.';
    }
  }

  Future<void> fetchTrucks() async {
    try {
      final results = await _service.searchTrucks(
        currentCity: filterOrigin.value,
        routeTo: filterDestination.value,
      );
      trucks.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Failed to load trucks feed.';
    }
  }

  Future<void> fetchMyListings() async {
    try {
      // Load user's own load posts
      final results = await _service.searchLoads();
      myLoads.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Failed to load your postings.';
    }
  }

  void applyFilters(String? origin, String? destination, CargoType? cargoType) {
    filterOrigin.value = origin;
    filterDestination.value = destination;
    filterCargoType.value = cargoType;
    if (currentTabIndex.value == 0) {
      fetchLoads();
    } else {
      fetchTrucks();
    }
  }

  void clearFilters() {
    filterOrigin.value = null;
    filterDestination.value = null;
    filterCargoType.value = null;
    fetchMarketplaceFeed();
  }

  Future<void> submitBidOnLoad({
    required LoadPostModel load,
    required double amount,
    required int advancePct,
    required PaymentTermType terms,
    String? remarks,
  }) async {
    if (load.listingId == null) return;
    
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final offer = MarketplaceOfferModel(
      listingId: load.listingId,
      offeredAmount: amount,
      advancePercentage: advancePct,
      paymentTerms: terms,
      remarks: remarks,
    );

    final success = await _service.submitOffer(offer);
    Get.back(); // close loading dialog

    if (success) {
      Get.snackbar(
        'Bid Submitted!',
        'Your bid of ₹${amount.toStringAsFixed(0)} on route ${load.originCity} → ${load.destinationCity} has been sent to the load owner.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFECFDF5),
        colorText: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Submission Failed',
        'Could not submit bid. Please check your network and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFDC2626),
      );
    }
  }
}
