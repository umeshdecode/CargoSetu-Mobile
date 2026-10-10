import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:cargo_setu/marketplace/models/marketplace_offer_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_booking_model.dart';
import 'package:cargo_setu/marketplace/models/truck_post_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_chat_model.dart';
import 'package:cargo_setu/marketplace/models/marketplace_enums.dart';

void main() {
  group('Marketplace URL Configuration Tests', () {
    test('Base URL has default fallback to production Render backend', () {
      expect(Urls.baseUrl, contains('onrender.com'));
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

  group('Marketplace Offer Model Serialization Tests', () {
    test('toJson generates dual-key payloads compatible with backend and legacy mobile', () {
      final offer = MarketplaceOfferModel(
        listingId: 100,
        offeredAmount: 25000.0,
        advancePercentage: 20,
        paymentTerms: PaymentTermType.ADVANCE_PERCENT,
        remarks: 'Ready for immediate dispatch',
      );

      final json = offer.toJson();
      expect(json['listingId'], equals(100));
      expect(json['amount'], equals(25000.0));
      expect(json['offeredAmount'], equals(25000.0));
      expect(json['advancePercentage'], equals(20));
      expect(json['paymentTerms'], equals('ADVANCE_PERCENT'));
      expect(json['message'], equals('Ready for immediate dispatch'));
      expect(json['remarks'], equals('Ready for immediate dispatch'));
      expect(json['status'], equals('PENDING'));
    });

    test('fromJson parses enriched backend OfferResponse correctly', () {
      final backendPayload = {
        'id': 15,
        'listingId': 100,
        'listingNumber': 'LD-20261010-0001',
        'bidderCompanyId': 2,
        'bidderCompanyName': 'Acme Logistics',
        'offeredByStaffId': 7,
        'offeredByStaffName': 'John Doe',
        'offeredAmount': 24500.0,
        'advancePercentage': 30,
        'paymentTerms': 'ADVANCE_PERCENT',
        'status': 'PENDING',
        'remarks': 'Can deliver within 2 days',
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
      expect(offer.advancePercentage, equals(30));
      expect(offer.paymentTerms, equals(PaymentTermType.ADVANCE_PERCENT));
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
    test('TruckPostModel toJson serializes fleet resources and capacity', () {
      final truck = TruckPostModel(
        vehicleId: 12,
        driverId: 8,
        currentCity: 'Pune',
        routeTo: 'Mumbai',
        availableCapacity: 15.0,
        passingCapacityTons: 15.0,
        pricePerKm: 55.0,
      );

      final json = truck.toJson();
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
}
