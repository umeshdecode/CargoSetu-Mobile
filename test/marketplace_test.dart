import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:cargo_setu/marketplace/models/load_post_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_offer_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_booking_model.dart';
import 'package:cargo_setu/marketplace/models/truck_post_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_chat_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_enums.dart';
import 'package:cargo_setu/marketplace/services/marketplace_service.dart';
import 'package:cargo_setu/marketplace/screens/load_detail_screen.dart';
import 'package:cargo_setu/marketplace/screens/truck_detail_screen.dart';
import 'package:cargo_setu/marketplace/screens/create_truck_post_screen.dart';
import 'package:cargo_setu/marketplace/screens/marketplace_chat_screen.dart';
import 'package:cargo_setu/vehicle_management/models/vehicle_model.dart';
import 'package:cargo_setu/vehicle_management/models/driver_model.dart';
import 'package:cargo_setu/vehicle_management/services/vehicle_service.dart';

class _FakeApiRequest implements ApiRequest {
  String? lastPostUrl;
  dynamic lastPostData;
  int postCallCount = 0;
  int statusCodeToReturn = 201;

  @override
  Future<Response> post({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? token,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    postCallCount++;
    lastPostUrl = url;
    lastPostData = data;
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: statusCodeToReturn,
      data: {'responseCode': statusCodeToReturn},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMarketplaceService extends MarketplaceService {
  ChatConversationModel? conversationToReturn;
  bool throwOnStartConversation = false;
  int startConversationCalls = 0;
  TruckPostModel? submittedTruckPost;

  _FakeMarketplaceService() : super(api: _FakeApiRequest());

  @override
  Future<ChatConversationModel?> startConversation({
    int? listingId,
    int? bookingId,
    required int participantCompanyId,
    required int participantStaffId,
    String? initialMessage,
  }) async {
    startConversationCalls++;
    if (throwOnStartConversation) {
      throw Exception('Network error');
    }
    return conversationToReturn;
  }

  @override
  Future<bool> createTruckPost(TruckPostModel model) async {
    submittedTruckPost = model;
    return true;
  }
}

class _FakeVehicleService implements VehicleService {
  List<VehicleModel> vehiclesToReturn;
  bool shouldThrow;
  int getVehiclesCalls = 0;

  _FakeVehicleService({
    this.vehiclesToReturn = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<VehicleModel>> getVehicles() async {
    getVehiclesCalls++;
    if (shouldThrow) {
      throw Exception('Fleet service unavailable');
    }
    return vehiclesToReturn;
  }

  @override
  Future<List<DriverModel>> getDrivers() async {
    if (shouldThrow) {
      throw Exception('Driver service unavailable');
    }
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Marketplace URL Configuration Tests', () {
    test('Base URL and marketplace root are configured properly', () {
      expect(Urls.baseUrl, startsWith('http'));
      expect(Urls.marketplace, equals('${Urls.baseUrl}/api/v2/cargosetu/marketplace'));
    });

    test('Offer URLs match backend controller mappings', () {
      expect(Urls.marketplaceOffers, equals('${Urls.marketplace}/offers'));
      expect(Urls.marketplaceOffersForListing(42), equals('${Urls.marketplace}/listings/42/offers'));
      expect(Urls.marketplaceOfferAccept(10), equals('${Urls.marketplaceOffers}/10/accept'));
      expect(Urls.marketplaceOfferReject(10), equals('${Urls.marketplaceOffers}/10/reject'));
      expect(Urls.marketplaceOfferCounter(10), equals('${Urls.marketplaceOffers}/10/counter'));
    });

    test('Booking URLs match backend controller mappings', () {
      expect(Urls.marketplaceBookings, equals('${Urls.marketplace}/bookings'));
      expect(Urls.marketplaceBookListing(99), equals('${Urls.marketplaceBookings}/listing/99'));
      expect(Urls.marketplaceBookingById(101), equals('${Urls.marketplaceBookings}/101'));
      expect(Urls.marketplaceBookingCancel(101), equals('${Urls.marketplaceBookings}/101/cancel'));
    });

    test('Chat URLs match backend controller mappings', () {
      expect(Urls.marketplaceConversations, equals('${Urls.marketplace}/conversations'));
      expect(Urls.marketplaceMessages(5), equals('${Urls.marketplaceConversations}/5/messages'));
      expect(Urls.marketplaceConversationRead(5), equals('${Urls.marketplaceConversations}/5/read'));
    });
  });

  group('Marketplace Offer DTO & Service Tests', () {
    test('toJson matches backend CreateOfferRequest exactly (amount, paymentTerms, validUntil, message)', () {
      final offer = MarketplaceOfferModel(
        id: 99,
        listingId: 100,
        offeredAmount: 25000.0,
        advancePercentage: 20,
        paymentTerms: PaymentTermType.ADVANCE_PERCENT,
        validUntil: '2026-10-25T18:00:00',
        remarks: 'Ready for immediate dispatch',
      );

      final json = offer.toJson();
      expect(
        json,
        equals({
          'amount': 25000.0,
          'paymentTerms': 'ADVANCE_PERCENT',
          'validUntil': '2026-10-25T18:00:00',
          'message': 'Ready for immediate dispatch',
        }),
      );
      expect(json.containsKey('offeredAmount'), isFalse);
      expect(json.containsKey('remarks'), isFalse);
      expect(json.containsKey('listingId'), isFalse);
      expect(json.containsKey('status'), isFalse);
    });

    test('submitOffer rejects missing or invalid listingId without falling back to legacy endpoint', () async {
      final fakeApi = _FakeApiRequest();
      final service = MarketplaceService(api: fakeApi);

      final missingListingOffer = MarketplaceOfferModel(
        listingId: null,
        offeredAmount: 25000.0,
      );
      final zeroListingOffer = MarketplaceOfferModel(
        listingId: 0,
        offeredAmount: 25000.0,
      );

      expect(await service.submitOffer(missingListingOffer), isFalse);
      expect(await service.submitOffer(zeroListingOffer), isFalse);
      expect(fakeApi.postCallCount, equals(0));

      final validOffer = MarketplaceOfferModel(
        listingId: 42,
        offeredAmount: 25000.0,
        paymentTerms: PaymentTermType.TO_PAY,
        remarks: 'Direct delivery',
      );
      expect(await service.submitOffer(validOffer), isTrue);
      expect(fakeApi.postCallCount, equals(1));
      expect(fakeApi.lastPostUrl, equals(Urls.marketplaceOffersForListing(42)));
      expect(
        fakeApi.lastPostData,
        equals({
          'amount': 25000.0,
          'paymentTerms': 'TO_PAY',
          'message': 'Direct delivery',
        }),
      );
    });

    test('fromJson parses enriched backend OfferResponse correctly', () {
      final backendPayload = {
        'id': 15,
        'listingId': 100,
        'listingNumber': 'LD-20261010-0001',
        'bidderCompanyId': 2,
        'bidderCompanyName': 'Acme Logistics',
        'offeredByStaffId': 7,
        'offeredByName': 'John Doe',
        'amount': 24500.0,
        'paymentTerms': 'ADVANCE_PERCENT',
        'validUntil': '2026-10-20T12:00:00',
        'status': 'PENDING',
        'message': 'Can deliver within 2 days',
      };

      final offer = MarketplaceOfferModel.fromJson(backendPayload);
      expect(offer.id, equals(15));
      expect(offer.listingId, equals(100));
      expect(offer.listingNumber, equals('LD-20261010-0001'));
      expect(offer.bidderCompanyId, equals(2));
      expect(offer.bidderCompanyName, equals('Acme Logistics'));
      expect(offer.offeredByStaffId, equals(7));
      expect(offer.offeredByStaffName, equals('John Doe'));
      expect(offer.offeredAmount, equals(24500.0));
      expect(offer.paymentTerms, equals(PaymentTermType.ADVANCE_PERCENT));
      expect(offer.validUntil, equals('2026-10-20T12:00:00'));
      expect(offer.status, equals(OfferStatus.PENDING));
      expect(offer.remarks, equals('Can deliver within 2 days'));
    });
  });

  group('Marketplace Booking Model Serialization Tests', () {
    test('toJson produces required CreateBookingRequest fields', () {
      final booking = MarketplaceBookingModel(
        listingId: 200,
        offerId: 15,
        vehicleId: 3,
        driverId: 5,
        agreedFreight: 50000.0,
        paymentTerms: PaymentTermType.ADVANCE_PERCENT,
        advancePercentage: 50,
        requestedCapacity: 18.5,
      );

      final json = booking.toJson();
      expect(json['listingId'], equals(200));
      expect(json['offerId'], equals(15));
      expect(json['vehicleId'], equals(3));
      expect(json['driverId'], equals(5));
      expect(json['agreedFreight'], equals(50000.0));
      expect(json['paymentTerms'], equals('ADVANCE_PERCENT'));
      expect(json['advancePercentage'], equals(50));
      expect(json['requestedCapacity'], equals(18.5));
    });

    test('fromJson parses enriched backend BookingResponse', () {
      final backendPayload = {
        'id': 88,
        'bookingNumber': 'BK-20261010-0088',
        'listingId': 200,
        'listingNumber': 'TK-20261010-0005',
        'shipperCompanyId': 10,
        'shipperCompanyName': 'Global Shippers Inc',
        'transporterCompanyId': 20,
        'transporterCompanyName': 'Speedy Fleet Transport',
        'vehicleId': 3,
        'vehicleNumber': 'MH 12 CD 5678',
        'driverId': 5,
        'driverName': 'Suresh Kumar',
        'driverPhone': '9876543210',
        'agreedFreight': 48000.0,
        'paymentTerms': 'ADVANCE_PERCENT',
        'advancePercentage': 40,
        'status': 'CONFIRMED',
        'requestedCapacity': 20.0,
      };

      final booking = MarketplaceBookingModel.fromJson(backendPayload);
      expect(booking.id, equals(88));
      expect(booking.bookingNumber, equals('BK-20261010-0088'));
      expect(booking.shipperCompanyName, equals('Global Shippers Inc'));
      expect(booking.transporterCompanyName, equals('Speedy Fleet Transport'));
      expect(booking.vehicleNumber, equals('MH 12 CD 5678'));
      expect(booking.driverName, equals('Suresh Kumar'));
      expect(booking.driverPhone, equals('9876543210'));
      expect(booking.agreedFreight, equals(48000.0));
      expect(booking.status, equals(BookingStatus.CONFIRMED));
      expect(booking.requestedCapacity, equals(20.0));
    });
  });

  group('Marketplace Truck Post & Chat Model Tests', () {
    test('TruckPostModel toJson omits vehicleId when null instead of falling back to 1', () {
      final truckWithoutVehicle = TruckPostModel(
        currentCity: 'Pune',
        routeTo: 'Mumbai',
        availableCapacity: 15.0,
      );

      final jsonWithoutVehicle = truckWithoutVehicle.toJson();
      expect(jsonWithoutVehicle.containsKey('vehicleId'), isFalse);

      final truckWithVehicle = TruckPostModel(
        vehicleId: 12,
        driverId: 8,
        currentCity: 'Pune',
        routeTo: 'Mumbai',
        availableCapacity: 15.0,
        passingCapacityTons: 15.0,
        pricePerKm: 55.0,
      );

      final json = truckWithVehicle.toJson();
      expect(json['vehicleId'], equals(12));
      expect(json['driverId'], equals(8));
      expect(json['currentCity'], equals('Pune'));
      expect(json['routeTo'], equals('Mumbai'));
      expect(json['totalCapacity'], equals(15.0));
      expect(json['availableCapacity'], equals(15.0));
      expect(json['pricePerKm'], equals(55.0));
    });

    test('ChatMessageModel identifies message sender correctly', () {
      final msg = ChatMessageModel.fromJson({
        'id': 1,
        'conversationId': 10,
        'senderStaffId': 4,
        'message': 'Truck is ready for pickup',
        'messageType': 'TEXT',
      }, currentStaffId: 4);

      expect(msg.isMe, isTrue);
      expect(msg.message, equals('Truck is ready for pickup'));

      final otherMsg = ChatMessageModel.fromJson({
        'id': 2,
        'conversationId': 10,
        'senderStaffId': 5,
        'message': 'Acknowledged',
      }, currentStaffId: 4);

      expect(otherMsg.isMe, isFalse);
    });
  });

  group('Chat UI Failure & Vehicle Selection Widget Tests', () {
    testWidgets('LoadDetailScreen does not open chat when startConversation fails and shows Retry action', (tester) async {
      final fakeService = _FakeMarketplaceService()..conversationToReturn = null;
      final load = LoadPostModel(
        listingId: 10,
        companyId: 200,
        postedByStaffId: 8,
        companyName: 'Apex Shippers',
        originCity: 'Pune',
        destinationCity: 'Delhi',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: LoadDetailScreen(load: load, service: fakeService),
        ),
      );

      final chatBtn = find.text('Chat');
      await tester.ensureVisible(chatBtn);
      await tester.pumpAndSettle();
      await tester.tap(chatBtn);
      await tester.pumpAndSettle();

      expect(fakeService.startConversationCalls, equals(1));
      expect(find.byType(MarketplaceChatScreen), findsNothing);
      expect(find.textContaining('Unable to start chat conversation'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('TruckDetailScreen does not open chat when participant IDs are missing', (tester) async {
      final fakeService = _FakeMarketplaceService();
      final truck = TruckPostModel(
        listingId: 20,
        companyId: null,
        postedByStaffId: null,
        currentCity: 'Mumbai',
        routeTo: 'Surat',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: TruckDetailScreen(truck: truck, service: fakeService),
        ),
      );

      final chatBtn = find.text('Chat');
      await tester.ensureVisible(chatBtn);
      await tester.pumpAndSettle();
      await tester.tap(chatBtn);
      await tester.pumpAndSettle();

      expect(fakeService.startConversationCalls, equals(0));
      expect(find.byType(MarketplaceChatScreen), findsNothing);
      expect(find.textContaining('participant details are unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('CreateTruckPostScreen requires explicit vehicle selection and does not fallback to first vehicle', (tester) async {
      final fakeMarketplace = _FakeMarketplaceService();
      final fakeVehicleService = _FakeVehicleService(
        vehiclesToReturn: [
          VehicleModel(
            id: 42,
            chassisNumber: 'CH123',
            engineNumber: 'EN123',
            registrationNumber: 'MH12AB1234',
            vehicleType: 'TRUCK',
            model: 'Prima',
            manufacturer: 'Tata',
            capacityKg: 20000,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: CreateTruckPostScreen(
            service: fakeMarketplace,
            vehicleService: fakeVehicleService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Attempt to submit without selecting a vehicle
      final publishBtn = find.text('Publish Truck Availability');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      expect(fakeMarketplace.submittedTruckPost, isNull);
      expect(
        find.text('Please select a vehicle from your fleet before publishing.'),
        findsOneWidget,
      );
    });

    testWidgets('CreateTruckPostScreen handles fleet load failure and empty fleet with Retry', (tester) async {
      final fakeMarketplace = _FakeMarketplaceService();
      final fakeVehicleService = _FakeVehicleService(shouldThrow: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: CreateTruckPostScreen(
            service: fakeMarketplace,
            vehicleService: fakeVehicleService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to load your fleet vehicles'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Now make retry succeed with empty fleet
      fakeVehicleService.shouldThrow = false;
      fakeVehicleService.vehiclesToReturn = [];
      final retryBtn = find.text('Retry');
      await tester.ensureVisible(retryBtn);
      await tester.pumpAndSettle();
      await tester.tap(retryBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('No vehicles found in your fleet'), findsOneWidget);
    });

    testWidgets('CreateTruckPostScreen selecting a vehicle with LCV_CONTAINER bodyType does not throw DropdownButton error', (tester) async {
      final fakeMarketplace = _FakeMarketplaceService();
      final fakeVehicleService = _FakeVehicleService(
        vehiclesToReturn: [
          VehicleModel(
            id: 77,
            chassisNumber: 'CH777',
            engineNumber: 'EN777',
            registrationNumber: 'MH14XY7777',
            vehicleType: 'LCV',
            truckType: 'LCV',
            bodyType: 'LCV_CONTAINER',
            model: 'Bolero Pickup',
            manufacturer: 'Mahindra',
            capacityKg: 3500,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: CreateTruckPostScreen(
            service: fakeMarketplace,
            vehicleService: fakeVehicleService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open vehicle dropdown and select the LCV_CONTAINER vehicle
      final dropdownPrompt = find.text('Select a vehicle...');
      await tester.ensureVisible(dropdownPrompt);
      await tester.pumpAndSettle();
      await tester.tap(dropdownPrompt);
      await tester.pumpAndSettle();

      final vehicleOption = find.text('MH14XY7777 (Bolero Pickup)').last;
      await tester.tap(vehicleOption);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('LCV CONTAINER'), findsOneWidget);
    });
  });
}
