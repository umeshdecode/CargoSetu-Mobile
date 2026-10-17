/// All API endpoint URLs for the CargoSetu backend.
class Urls {
  /// Base API URL configurable via --dart-define=API_BASE_URL=<url>
  /// Defaults to deployed production backend: https://code-setu-app.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.6:31201',
  );

  // ─── AUTH ───────────────────────────────────────────────
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/user/register";
  static const String sendOtp = "$baseUrl/auth/otp/send";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String checkUser = "$baseUrl/auth/check-user";
  static const String googleLogin = "$baseUrl/auth/google/login";
  static const String googleSignup = "$baseUrl/auth/google/signup";

  // ─── TOKEN ──────────────────────────────────────────────
  static const String refreshToken = "$baseUrl/api/v2/cargosetu/refreshtoken";

  // ─── COMPANY ────────────────────────────────────────────
  static const String company = "$baseUrl/api/v2/cargosetu/company";
  static const String currentCompany = "$company/currentCompany";

  // ─── STAFF / PROFILE ───────────────────────────────────
  static const String staff = "$baseUrl/api/v2/cargosetu/staff";
  static const String myProfile = "$staff/myprofile";
  static const String myProfileImage = "$staff/myprofile/image";
  static String staffById(int staffId) => "$staff/$staffId";
  static String staffProfileImage(int staffId) => "$staff/$staffId/image";

  // ─── BRANCHES ───────────────────────────────────────────
  static const String branches = "$baseUrl/api/v2/cargosetu/branches";

  // ─── ROLES & PERMISSIONS ────────────────────────────────
  static const String roles = "$baseUrl/api/v2/cargosetu/role";
  static const String permissions = "$baseUrl/api/v2/cargosetu/permission";

  // ─── TEMPLATES ──────────────────────────────────────────
  static const String templates = "$baseUrl/api/v2/cargosetu/templates";
  static const String templatesByType = "$templates/by-type";
  static String templateDefault(int id) => "$templates/$id/default";
  static String templatePreviewHtml(int id) => "$templates/$id/preview-html";
  static String quotationPdf(int shiftingId, {int? templateId}) =>
      "$templates/quotation/$shiftingId/pdf${templateId != null ? '?templateId=$templateId' : ''}";
  static String sendQuotation(int shiftingId, {int? templateId}) =>
      "$templates/quotation/$shiftingId/send${templateId != null ? '?templateId=$templateId' : ''}";
  static String packingListPdf(int shiftingId, {int? templateId}) =>
      "$templates/packing-list/$shiftingId/pdf${templateId != null ? '?templateId=$templateId' : ''}";
  static String sendPackingList(int shiftingId, {int? templateId}) =>
      "$templates/packing-list/$shiftingId/send${templateId != null ? '?templateId=$templateId' : ''}";
  static String documentPdf(String docType, int shiftingId, {int? templateId}) {
    final typePath = docType.toLowerCase().replaceAll('_', '-');
    return "$templates/$typePath/$shiftingId/pdf${templateId != null ? '?templateId=$templateId' : ''}";
  }

  static String sendDocument(
    String docType,
    int shiftingId, {
    int? templateId,
  }) {
    final typePath = docType.toLowerCase().replaceAll('_', '-');
    return "$templates/$typePath/$shiftingId/send${templateId != null ? '?templateId=$templateId' : ''}";
  }

  // ─── SHIFTINGS ──────────────────────────────────────────
  static const String shifts = "$baseUrl/api/v2/cargosetu/shifts";
  static const String shiftsSearch = "$shifts/search";

  // ─── SHIFT INVENTORY / PACKING LIST ─────────────────────
  static const String shiftInventory =
      "$baseUrl/api/v2/cargosetu/shift-inventory";
  static String shiftInventoryByShiftId(int shiftId) =>
      "$shiftInventory/shift/$shiftId";
  static String shiftInventoryBulk(int shiftId) =>
      "$shiftInventory/bulk/$shiftId";
  static String shiftInventoryItem(int itemId) => "$shiftInventory/$itemId";

  // ─── VEHICLE & FLEET MANAGEMENT ─────────────────────────
  static const String vehicle = "$baseUrl/vehicle";
  static String vehicleById(int id) => "$vehicle/$id";
  static const String drivers = "$baseUrl/api/v2/cargosetu/drivers";
  static String driverById(int id) => "$drivers/$id";
  static const String assignments = "$baseUrl/api/v2/cargosetu/assignments";
  static String unassignDriver(int id) => "$assignments/unassign/$id";

  // ─── VEHICLE CATALOGUE ───────────────────────────────────
  static const String catalogueBrands =
      "$baseUrl/api/v2/cargosetu/vehicles/brands";
  static const String catalogueModels =
      "$baseUrl/api/v2/cargosetu/vehicles/models";
  static String catalogueModelById(int id) => "$catalogueModels/$id";
  static const String catalogueSearch = "$catalogueModels/search";

  // ─── MARKETPLACE ─────────────────────────────────────────
  static const String marketplace = "$baseUrl/api/v2/cargosetu/marketplace";
  static const String marketplaceLoads = "$marketplace/loads";
  static const String marketplaceMyLoads = "$marketplaceLoads/my";
  static String marketplaceLoadById(int id) => "$marketplaceLoads/$id";
  static String marketplaceLoadPublish(int id) =>
      "$marketplaceLoads/$id/publish";
  static String marketplaceLoadClose(int id) => "$marketplaceLoads/$id/close";

  static const String marketplaceTrucks = "$marketplace/trucks";
  static const String marketplaceMyTrucks = "$marketplaceTrucks/my";
  static String marketplaceTruckById(int id) => "$marketplaceTrucks/$id";
  static String marketplaceTruckPublish(int id) =>
      "$marketplaceTrucks/$id/publish";
  static String marketplaceTruckClose(int id) => "$marketplaceTrucks/$id/close";

  static const String marketplaceOffers = "$marketplace/offers";
  static const String marketplaceMyOffers = "$marketplaceOffers/my";
  static String marketplaceOffersForListing(int listingId) =>
      "$marketplace/listings/$listingId/offers";
  static String marketplaceOfferAccept(int id) =>
      "$marketplaceOffers/$id/accept";
  static String marketplaceOfferReject(int id) =>
      "$marketplaceOffers/$id/reject";
  static String marketplaceOfferCounter(int id) =>
      "$marketplaceOffers/$id/counter";

  static const String marketplaceBookings = "$marketplace/bookings";
  static String marketplaceBookListing(int listingId) =>
      "$marketplaceBookings/listing/$listingId";
  static String marketplaceBookingById(int id) => "$marketplaceBookings/$id";
  static String marketplaceBookingAccept(int id) =>
      "$marketplaceBookings/$id/accept";
  static String marketplaceBookingReject(int id) =>
      "$marketplaceBookings/$id/reject";
  static String marketplaceBookingCounter(int id) =>
      "$marketplaceBookings/$id/counter";
  static String marketplaceBookingCancel(int id) =>
      "$marketplaceBookings/$id/cancel";
  static String marketplaceBookingAssign(int id) =>
      "$marketplaceBookings/$id/assign";

  static const String marketplaceTrips = "$marketplace/trips";
  static String marketplaceTripById(int id) => "$marketplaceTrips/$id";
  static String marketplaceTripTimeline(int id) =>
      "$marketplaceTrips/$id/timeline";
  static String marketplaceTripEvents(int id) => "$marketplaceTrips/$id/events";
  static String marketplaceTripLocation(int id) =>
      "$marketplaceTrips/$id/location";
  static const String marketplaceActiveTrips = "$marketplaceTrips/active";

  static const String marketplacePayments = "$marketplace/payments";
  static String marketplacePaymentHistory(int bookingId) =>
      "$marketplacePayments/history/$bookingId";
  static const String marketplacePaymentOrders = "$marketplacePayments/orders";
  static const String marketplaceWalletStatement =
      "$marketplacePayments/wallet/statement";

  static const String marketplaceConversations = "$marketplace/conversations";
  static String marketplaceMessages(int conversationId) =>
      "$marketplaceConversations/$conversationId/messages";
  static String marketplaceConversationRead(int conversationId) =>
      "$marketplaceConversations/$conversationId/read";

  static const String marketplaceDisputes = "$marketplace/disputes";
  static String marketplaceDisputeByBooking(int bookingId) =>
      "$marketplaceDisputes/booking/$bookingId";
  static String marketplaceDisputeById(int id) => "$marketplaceDisputes/$id";
  static String marketplaceDisputeEvidence(int id) =>
      "$marketplaceDisputes/$id/evidence";

  static const String marketplaceMatches = "$marketplace/matches";
  static String marketplaceMatchesForLoad(int loadId) =>
      "$marketplaceMatches/load/$loadId";
  static String marketplaceMatchesForTruck(int truckId) =>
      "$marketplaceMatches/truck/$truckId";
  static const String marketplaceRecommendations =
      "$marketplaceMatches/recommendations";
  static const String marketplaceAlerts = "$marketplaceMatches/alerts";

  static const String marketplaceRatings = "$marketplace/ratings";
  static String marketplaceRatingsForBooking(int bookingId) =>
      "$marketplaceRatings/booking/$bookingId";
  static String marketplaceRatingsForCompany(int companyId) =>
      "$marketplaceRatings/company/$companyId";
}
