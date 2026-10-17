import 'package:cargo_setu/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/load_post_model.dart';
import '../models/truck_post_model.dart';
import '../models/marketplace_offer_model.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_enums.dart';
import '../services/marketplace_service.dart';

class MarketplaceHubController extends GetxController {
  final MarketplaceService _service;

  MarketplaceHubController({MarketplaceService? service})
    : _service = service ?? MarketplaceService();

  MarketplaceService get service => _service;

  // Main Tab State: 0 = Find Loads, 1 = Find Trucks, 2 = My Activity
  final RxInt currentTabIndex = 0.obs;

  // Sub-Tab inside My Activity:
  // 0 = My Bids, 1 = My Booking Requests, 2 = Incoming Requests, 3 = My Listings
  final RxInt activitySubTabIndex = 0.obs;

  // Feed Data State
  final RxList<LoadPostModel> loads = <LoadPostModel>[].obs;
  final RxList<TruckPostModel> trucks = <TruckPostModel>[].obs;

  // My Activity Data State
  final RxList<LoadPostModel> myLoads = <LoadPostModel>[].obs;
  final RxList<TruckPostModel> myTrucks = <TruckPostModel>[].obs;
  final RxList<MarketplaceOfferModel> myBids = <MarketplaceOfferModel>[].obs;
  final RxList<MarketplaceBookingModel> myOutgoingBookings =
      <MarketplaceBookingModel>[].obs;
  final RxList<MarketplaceBookingModel> incomingBookings =
      <MarketplaceBookingModel>[].obs;
  final RxList<MarketplaceOfferModel> incomingOffers =
      <MarketplaceOfferModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isActivityLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Active Filter & Route Corridor State
  final Rx<String?> filterOrigin = Rx<String?>(null);
  final Rx<String?> filterDestination = Rx<String?>(null);
  final Rx<double?> filterOriginLat = Rx<double?>(null);
  final Rx<double?> filterOriginLng = Rx<double?>(null);
  final Rx<double?> filterDestLat = Rx<double?>(null);
  final Rx<double?> filterDestLng = Rx<double?>(null);
  final RxDouble filterRadiusKm = 200.0.obs;
  final Rx<CargoType?> filterCargoType = Rx<CargoType?>(null);

  double? get filterRouteDistanceKm => LocationService.estimateCityDistanceKm(
    originLat: filterOriginLat.value,
    originLng: filterOriginLng.value,
    originCity: filterOrigin.value,
    destLat: filterDestLat.value,
    destLng: filterDestLng.value,
    destCity: filterDestination.value,
  );

  int get pendingIncomingCount {
    final pendingB = incomingBookings
        .where(
          (b) =>
              b.status == BookingStatus.PENDING_APPROVAL ||
              b.status == BookingStatus.REQUESTED,
        )
        .length;
    final pendingO = incomingOffers
        .where(
          (o) =>
              o.status == OfferStatus.PENDING ||
              o.status == OfferStatus.COUNTERED,
        )
        .length;
    return pendingB + pendingO;
  }

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
    } else if (index == 2) {
      fetchMyActivity();
    }
  }

  void setActivitySubTab(int subIndex) {
    activitySubTabIndex.value = subIndex;
  }

  Future<void> fetchMarketplaceFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([fetchLoads(), fetchTrucks()]);
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
      final orig = filterOrigin.value;
      final dest = filterDestination.value;
      final (double, double)? oCoords =
          (filterOriginLat.value != null && filterOriginLng.value != null)
          ? (filterOriginLat.value!, filterOriginLng.value!)
          : LocationService.lookupCityCoordinates(orig);
      final (double, double)? dCoords =
          (filterDestLat.value != null && filterDestLng.value != null)
          ? (filterDestLat.value!, filterDestLng.value!)
          : LocationService.lookupCityCoordinates(dest);

      final results = await _service.searchTrucks(
        currentCity: orig,
        routeTo: dest,
        originLat: oCoords?.$1,
        originLng: oCoords?.$2,
        destinationLat: dCoords?.$1,
        destinationLng: dCoords?.$2,
        radiusKm: filterRadiusKm.value,
      );
      trucks.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Failed to load trucks feed.';
    }
  }

  Future<void> fetchMyListings() async {
    await fetchMyActivity();
  }

  Future<void> fetchMyActivity() async {
    isActivityLoading.value = true;
    try {
      final results = await Future.wait([
        _service.getMyLoads(),
        _service.getMyTrucks(),
        _service.getMyOffers(),
        _service.getMyBookings(role: 'OUTGOING'),
        _service.getMyBookings(role: 'INCOMING'),
      ]);

      final loadedMyLoads = results[0] as List<LoadPostModel>;
      final loadedMyTrucks = results[1] as List<TruckPostModel>;
      myLoads.assignAll(loadedMyLoads);
      myTrucks.assignAll(loadedMyTrucks);
      myBids.assignAll(results[2] as List<MarketplaceOfferModel>);
      myOutgoingBookings.assignAll(results[3] as List<MarketplaceBookingModel>);
      incomingBookings.assignAll(results[4] as List<MarketplaceBookingModel>);

      // Fetch incoming offers for the user's own listings
      final listingIds = <int>{
        ...loadedMyLoads.map((l) => l.listingId).whereType<int>(),
        ...loadedMyTrucks.map((t) => t.listingId).whereType<int>(),
      };

      final collectedOffers = <MarketplaceOfferModel>[];
      for (final listingId in listingIds) {
        final offers = await _service.getOffersForListing(listingId);
        collectedOffers.addAll(offers);
      }
      incomingOffers.assignAll(collectedOffers);
    } catch (e) {
      // Preserve existing lists on partial error
    } finally {
      isActivityLoading.value = false;
    }
  }

  void applyFilters(
    String? origin,
    String? destination,
    CargoType? cargoType, {
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    double? radiusKm,
  }) {
    filterOrigin.value = origin;
    filterDestination.value = destination;
    filterCargoType.value = cargoType;
    filterOriginLat.value = originLat;
    filterOriginLng.value = originLng;
    filterDestLat.value = destLat;
    filterDestLng.value = destLng;
    if (radiusKm != null && radiusKm > 0) {
      filterRadiusKm.value = radiusKm;
    }
    if (currentTabIndex.value == 0) {
      fetchLoads();
    } else if (currentTabIndex.value == 1) {
      fetchTrucks();
    } else {
      fetchLoads();
      fetchTrucks();
    }
  }

  void clearFilters() {
    filterOrigin.value = null;
    filterDestination.value = null;
    filterCargoType.value = null;
    filterOriginLat.value = null;
    filterOriginLng.value = null;
    filterDestLat.value = null;
    filterDestLng.value = null;
    filterRadiusKm.value = 200.0;
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
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (success) {
      Get.snackbar(
        'Bid Submitted!',
        'Your bid of ₹${amount.toStringAsFixed(0)} on route ${load.originCity} → ${load.destinationCity} has been sent to the load owner.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFECFDF5),
        colorText: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
      );
      fetchMyActivity();
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

  Future<bool> acceptOffer(int offerId) async {
    final ok = await _service.acceptOffer(offerId);
    if (ok) {
      await fetchMyActivity();
    }
    return ok;
  }

  Future<bool> rejectOffer(int offerId) async {
    final ok = await _service.rejectOffer(offerId);
    if (ok) {
      await fetchMyActivity();
    }
    return ok;
  }

  Future<bool> sendCounterOffer({
    required int offerId,
    required double amount,
    int? advancePct,
    PaymentTermType? paymentTerms,
    String? remarks,
  }) async {
    final ok = await _service.counterOffer(
      offerId,
      MarketplaceOfferModel(
        offeredAmount: amount,
        advancePercentage: advancePct,
        paymentTerms: paymentTerms ?? PaymentTermType.ADVANCE_PERCENT,
        remarks: remarks,
      ),
    );
    if (ok) {
      await fetchMyActivity();
    }
    return ok;
  }

  Future<bool> acceptBookingRequest(
    int bookingId, {
    int? vehicleId,
    int? driverId,
  }) async {
    final res = await _service.acceptBooking(
      bookingId,
      vehicleId: vehicleId,
      driverId: driverId,
    );
    if (res != null) {
      await fetchMyActivity();
      return true;
    }
    return false;
  }

  Future<bool> rejectBookingRequest(int bookingId, String reason) async {
    final res = await _service.rejectBooking(bookingId, reason: reason);
    if (res != null) {
      await fetchMyActivity();
      return true;
    }
    return false;
  }

  Future<bool> counterBookingRequest(
    int bookingId, {
    required double counterFreight,
    String? remarks,
  }) async {
    final res = await _service.counterBooking(
      bookingId,
      counterFreight: counterFreight,
      remarks: remarks,
    );
    if (res != null) {
      await fetchMyActivity();
      return true;
    }
    return false;
  }

  Future<bool> cancelBookingRequest(int bookingId, String reason) async {
    final ok = await _service.cancelBooking(
      bookingId,
      'USER_CANCELLED',
      reason,
    );
    if (ok) {
      await fetchMyActivity();
    }
    return ok;
  }
}
