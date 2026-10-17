import 'dart:developer';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import '../models/load_post_model.dart';
import '../models/truck_post_model.dart';
import '../models/marketplace_offer_model.dart';
import '../models/marketplace_booking_model.dart';
import '../models/marketplace_trip_model.dart';
import '../models/marketplace_payment_model.dart';
import '../models/marketplace_chat_model.dart';
import '../models/dispute_rating_model.dart';
import '../models/marketplace_enums.dart';

class MarketplaceService {
  final ApiRequest? _injectedApi;
  late final ApiRequest _api = _injectedApi ?? ApiRequest();

  MarketplaceService({ApiRequest? api}) : _injectedApi = api;

  // ─── LOADS ──────────────────────────────────────────────────

  Future<List<LoadPostModel>> searchLoads({
    String? originCity,
    String? destinationCity,
    String? cargoType,
    DateTime? pickupDate,
    DateTime? pickupFrom,
    DateTime? pickupTo,
    double? minWeight,
    double? maxWeight,
    String? requiredTruckType,
    int? page,
    int? size,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (originCity != null && originCity.trim().isNotEmpty) query['originCity'] = originCity.trim();
      if (destinationCity != null && destinationCity.trim().isNotEmpty) query['destinationCity'] = destinationCity.trim();
      if (cargoType != null && cargoType.isNotEmpty) query['cargoType'] = cargoType;
      if (pickupDate != null) query['pickupDate'] = pickupDate.toIso8601String();
      if (pickupFrom != null) query['pickupFrom'] = pickupFrom.toIso8601String();
      if (pickupTo != null) query['pickupTo'] = pickupTo.toIso8601String();
      if (minWeight != null) query['minWeight'] = minWeight;
      if (maxWeight != null) query['maxWeight'] = maxWeight;
      if (requiredTruckType != null && requiredTruckType.isNotEmpty) query['requiredTruckType'] = requiredTruckType;
      if (page != null) query['page'] = page;
      if (size != null) query['size'] = size;

      final response = await _api.get(
        url: Urls.marketplaceLoads,
        queryParams: query.isNotEmpty ? query : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => LoadPostModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ searchLoads error: $e');
      return [];
    }
  }

  Future<LoadPostModel?> getLoadDetails(int id) async {
    try {
      final response = await _api.get(url: Urls.marketplaceLoadById(id));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return LoadPostModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getLoadDetails error: $e');
      return null;
    }
  }

  Future<bool> createLoadPost(LoadPostModel model) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceLoads,
        data: model.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ createLoadPost error: $e');
      return false;
    }
  }

  Future<bool> publishLoad(int id) async {
    try {
      final response = await _api.post(url: Urls.marketplaceLoadPublish(id));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ publishLoad error: $e');
      return false;
    }
  }

  Future<bool> closeLoad(int id) async {
    try {
      final response = await _api.post(url: Urls.marketplaceLoadClose(id));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ closeLoad error: $e');
      return false;
    }
  }

  // ─── TRUCKS ─────────────────────────────────────────────────

  Future<List<TruckPostModel>> searchTrucks({
    String? currentCity,
    String? routeTo,
    String? originCity,
    String? destinationCity,
    String? truckType,
    double? minCapacity,
    int? page,
    int? size,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (currentCity != null && currentCity.trim().isNotEmpty) query['currentCity'] = currentCity.trim();
      if (routeTo != null && routeTo.trim().isNotEmpty) query['routeTo'] = routeTo.trim();
      if (originCity != null && originCity.trim().isNotEmpty) query['originCity'] = originCity.trim();
      if (destinationCity != null && destinationCity.trim().isNotEmpty) query['destinationCity'] = destinationCity.trim();
      if (truckType != null && truckType.isNotEmpty) query['truckType'] = truckType;
      if (minCapacity != null) query['minCapacity'] = minCapacity;
      if (page != null) query['page'] = page;
      if (size != null) query['size'] = size;

      final response = await _api.get(
        url: Urls.marketplaceTrucks,
        queryParams: query.isNotEmpty ? query : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => TruckPostModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ searchTrucks error: $e');
      return [];
    }
  }

  Future<TruckPostModel?> getTruckDetails(int id) async {
    try {
      final response = await _api.get(url: Urls.marketplaceTruckById(id));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return TruckPostModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getTruckDetails error: $e');
      return null;
    }
  }

  Future<bool> createTruckPost(TruckPostModel model) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceTrucks,
        data: model.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ createTruckPost error: $e');
      return false;
    }
  }

  Future<bool> publishTruck(int id) async {
    try {
      final response = await _api.post(url: Urls.marketplaceTruckPublish(id));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ publishTruck error: $e');
      return false;
    }
  }

  Future<bool> closeTruck(int id) async {
    try {
      final response = await _api.post(url: Urls.marketplaceTruckClose(id));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ closeTruck error: $e');
      return false;
    }
  }

  // ─── OFFERS & NEGOTIATION ───────────────────────────────────

  Future<List<MarketplaceOfferModel>> getOffersForListing(int listingId) async {
    try {
      final response = await _api.get(url: Urls.marketplaceOffersForListing(listingId));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => MarketplaceOfferModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getOffersForListing error: $e');
      return [];
    }
  }

  Future<bool> submitOffer(MarketplaceOfferModel offer) async {
    final listingId = offer.listingId;
    if (listingId == null || listingId <= 0) {
      log('❌ submitOffer error: valid listingId is required');
      return false;
    }
    try {
      final response = await _api.post(
        url: Urls.marketplaceOffersForListing(listingId),
        data: offer.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ submitOffer error: $e');
      return false;
    }
  }

  Future<bool> acceptOffer(int offerId) async {
    try {
      final response = await _api.post(url: Urls.marketplaceOfferAccept(offerId));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ acceptOffer error: $e');
      return false;
    }
  }

  Future<bool> rejectOffer(int offerId) async {
    try {
      final response = await _api.post(url: Urls.marketplaceOfferReject(offerId));
      return response.statusCode == 200;
    } catch (e) {
      log('❌ rejectOffer error: $e');
      return false;
    }
  }

  Future<bool> counterOffer(
    int offerId,
    double counterAmount, {
    PaymentTermType? paymentTerms,
    String? remarks,
  }) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceOfferCounter(offerId),
        data: {
          'amount': counterAmount,
          if (paymentTerms != null) 'paymentTerms': paymentTerms.name,
          'message': ?remarks,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ counterOffer error: $e');
      return false;
    }
  }

  // ─── BOOKINGS ───────────────────────────────────────────────

  Future<List<MarketplaceBookingModel>> getMyBookings({String? role, String? status}) async {
    try {
      final query = <String, dynamic>{};
      if (role != null) query['role'] = role;
      if (status != null) query['status'] = status;

      final response = await _api.get(
        url: Urls.marketplaceBookings,
        queryParams: query.isNotEmpty ? query : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => MarketplaceBookingModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getMyBookings error: $e');
      return [];
    }
  }

  Future<MarketplaceBookingModel?> getBookingDetails(int bookingId) async {
    try {
      final response = await _api.get(url: Urls.marketplaceBookingById(bookingId));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return MarketplaceBookingModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getBookingDetails error: $e');
      return null;
    }
  }

  Future<bool> createBooking(MarketplaceBookingModel booking) async {
    try {
      final url = booking.listingId != null
          ? Urls.marketplaceBookListing(booking.listingId!)
          : Urls.marketplaceBookings;
      final response = await _api.post(
        url: url,
        data: booking.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ createBooking error: $e');
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId, String reasonCode, String reasonText) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceBookingCancel(bookingId),
        data: {
          'reasonCode': reasonCode,
          'reasonText': reasonText,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      log('❌ cancelBooking error: $e');
      return false;
    }
  }

  // ─── TRIPS ──────────────────────────────────────────────────

  Future<MarketplaceTripModel?> getTrip(int tripId) async {
    try {
      final response = await _api.get(url: Urls.marketplaceTripById(tripId));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return MarketplaceTripModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getTrip error: $e');
      return null;
    }
  }

  Future<List<MarketplaceTripModel>> getActiveTrips() async {
    try {
      final response = await _api.get(url: Urls.marketplaceActiveTrips);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => MarketplaceTripModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getActiveTrips error: $e');
      return [];
    }
  }

  Future<List<TripEventModel>> getTripTimeline(int tripId) async {
    try {
      final response = await _api.get(url: Urls.marketplaceTripTimeline(tripId));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => TripEventModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getTripTimeline error: $e');
      return [];
    }
  }

  Future<bool> addTripEvent(int tripId, TripEventModel event) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceTripEvents(tripId),
        data: event.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('❌ addTripEvent error: $e');
      return false;
    }
  }

  Future<bool> updateLocation(int tripId, double lat, double lng, {String? source}) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceTripLocation(tripId),
        data: {
          'lat': lat,
          'lng': lng,
          'source': ?source,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      log('❌ updateLocation error: $e');
      return false;
    }
  }

  // ─── WALLET & PAYMENTS ──────────────────────────────────────

  Future<WalletStatementModel?> getWalletStatement() async {
    try {
      final response = await _api.get(url: Urls.marketplaceWalletStatement);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return WalletStatementModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ getWalletStatement error: $e');
      return null;
    }
  }

  // ─── CHAT & MESSAGES ────────────────────────────────────────

  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await _api.get(url: Urls.marketplaceConversations);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => ChatConversationModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getConversations error: $e');
      return [];
    }
  }

  Future<List<ChatMessageModel>> getMessages(int conversationId, {int? currentStaffId}) async {
    try {
      final response = await _api.get(url: Urls.marketplaceMessages(conversationId));
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawList = body is Map ? (body['dataList'] ?? body['data']) : body;
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => ChatMessageModel.fromJson(e, currentStaffId: currentStaffId))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ getMessages error: $e');
      return [];
    }
  }

  Future<ChatConversationModel?> startConversation({
    int? listingId,
    int? bookingId,
    required int participantCompanyId,
    required int participantStaffId,
    String? initialMessage,
  }) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceConversations,
        data: {
          'listingId': ?listingId,
          'bookingId': ?bookingId,
          'participantCompanyId': participantCompanyId,
          'participantStaffId': participantStaffId,
          if (initialMessage != null && initialMessage.trim().isNotEmpty)
            'initialMessage': initialMessage.trim(),
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map<String, dynamic>) {
          return ChatConversationModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      log('❌ startConversation error: $e');
      return null;
    }
  }

  Future<bool> sendMessage(int conversationId, String message) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceMessages(conversationId),
        data: {'message': message, 'messageType': 'TEXT'},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ sendMessage error: $e');
      return false;
    }
  }

  Future<bool> markMessagesAsRead(int conversationId) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceConversationRead(conversationId),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('❌ markMessagesAsRead error: $e');
      return false;
    }
  }

  // ─── DISPUTES & RATINGS ─────────────────────────────────────

  Future<bool> raiseDispute(DisputeModel dispute) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceDisputes,
        data: dispute.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ raiseDispute error: $e');
      return false;
    }
  }

  Future<bool> submitRating(RatingReviewModel rating) async {
    try {
      final response = await _api.post(
        url: Urls.marketplaceRatings,
        data: rating.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('❌ submitRating error: $e');
      return false;
    }
  }
}
