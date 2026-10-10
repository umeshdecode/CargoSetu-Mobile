/// Enums representing all domain statuses and classifications in the CargoSetu Marketplace.

enum ListingType {
  LOAD_POST,
  TRUCK_POST;

  static ListingType fromString(String? value) {
    return ListingType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ListingType.LOAD_POST,
    );
  }
}

enum ListingStatus {
  DRAFT,
  PUBLISHED,
  MATCHED,
  NEGOTIATING,
  BOOKED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  EXPIRED,
  CLOSED;

  static ListingStatus fromString(String? value) {
    return ListingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ListingStatus.DRAFT,
    );
  }

  String get displayName {
    switch (this) {
      case ListingStatus.DRAFT:
        return 'Draft';
      case ListingStatus.PUBLISHED:
        return 'Active';
      case ListingStatus.MATCHED:
        return 'Matched';
      case ListingStatus.NEGOTIATING:
        return 'Negotiating';
      case ListingStatus.BOOKED:
        return 'Booked';
      case ListingStatus.IN_PROGRESS:
        return 'In Progress';
      case ListingStatus.COMPLETED:
        return 'Completed';
      case ListingStatus.CANCELLED:
        return 'Cancelled';
      case ListingStatus.EXPIRED:
        return 'Expired';
      case ListingStatus.CLOSED:
        return 'Closed';
    }
  }
}

enum CargoType {
  ALL,
  CARTON,
  FRAGILE,
  FOOD,
  ELECTRONICS,
  TEXTILE,
  INDUSTRIAL,
  PERISHABLE,
  HAZARDOUS,
  FMCG,
  GENERAL;

  static CargoType fromString(String? value) {
    if (value == null) return CargoType.GENERAL;
    return CargoType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => CargoType.GENERAL,
    );
  }

  String get displayName {
    switch (this) {
      case CargoType.ALL:
        return 'All Commodities';
      case CargoType.CARTON:
        return 'Carton Boxes';
      case CargoType.FRAGILE:
        return 'Fragile Goods';
      case CargoType.FOOD:
        return 'Food & Agro';
      case CargoType.ELECTRONICS:
        return 'Electronics';
      case CargoType.TEXTILE:
        return 'Textile & Apparel';
      case CargoType.INDUSTRIAL:
        return 'Industrial Goods';
      case CargoType.PERISHABLE:
        return 'Perishable Goods';
      case CargoType.HAZARDOUS:
        return 'Hazardous (HAZMAT)';
      case CargoType.FMCG:
        return 'FMCG Goods';
      case CargoType.GENERAL:
        return 'General Freight';
    }
  }
}

enum CapacityUnit {
  TONNE,
  KG,
  POUND,
  CBM,
  SQ_FT;

  static CapacityUnit fromString(String? value) {
    if (value == null) return CapacityUnit.TONNE;
    final upper = value.toUpperCase();
    if (upper == 'TONS' || upper == 'TON' || upper == 'TONNES') return CapacityUnit.TONNE;
    if (upper == 'KGS' || upper == 'KILOGRAM') return CapacityUnit.KG;
    if (upper == 'LBS' || upper == 'POUNDS') return CapacityUnit.POUND;
    return CapacityUnit.values.firstWhere(
      (e) => e.name == upper,
      orElse: () => CapacityUnit.TONNE,
    );
  }

  String get displayName {
    switch (this) {
      case CapacityUnit.TONNE:
        return 'Tons (MT)';
      case CapacityUnit.KG:
        return 'Kilograms (Kg)';
      case CapacityUnit.POUND:
        return 'Pounds (lb)';
      case CapacityUnit.CBM:
        return 'Cubic Meters (CBM)';
      case CapacityUnit.SQ_FT:
        return 'Square Feet (sq ft)';
    }
  }
}

enum PaymentTermType {
  ADVANCE_PERCENT,
  HALF_ADVANCE,
  FULL_ADVANCE,
  TO_PAY,
  PARTIAL_TO_PAY,
  CREDIT,
  CASH_TO_DRIVER,
  DIRECT_TO_OWNER;

  static PaymentTermType fromString(String? value) {
    if (value == null) return PaymentTermType.ADVANCE_PERCENT;
    final upper = value.toUpperCase();
    if (upper == 'ADVANCE_BALANCE') return PaymentTermType.ADVANCE_PERCENT;
    if (upper.startsWith('CREDIT')) return PaymentTermType.CREDIT;
    return PaymentTermType.values.firstWhere(
      (e) => e.name == upper,
      orElse: () => PaymentTermType.ADVANCE_PERCENT,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentTermType.ADVANCE_PERCENT:
        return 'Advance + Balance';
      case PaymentTermType.HALF_ADVANCE:
        return '50% Advance';
      case PaymentTermType.FULL_ADVANCE:
        return '100% Advance';
      case PaymentTermType.TO_PAY:
        return 'To Pay on Delivery';
      case PaymentTermType.PARTIAL_TO_PAY:
        return 'Partial To Pay';
      case PaymentTermType.CREDIT:
        return 'Credit Terms';
      case PaymentTermType.CASH_TO_DRIVER:
        return 'Cash To Driver';
      case PaymentTermType.DIRECT_TO_OWNER:
        return 'Direct To Transporter Owner';
    }
  }
}

enum OfferStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  COUNTERED,
  EXPIRED,
  WITHDRAWN;

  static OfferStatus fromString(String? value) {
    return OfferStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OfferStatus.PENDING,
    );
  }
}

enum BookingStatus {
  PENDING_PAYMENT,
  CONFIRMED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  DISPUTED;

  static BookingStatus fromString(String? value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.PENDING_PAYMENT,
    );
  }

  String get displayName {
    switch (this) {
      case BookingStatus.PENDING_PAYMENT:
        return 'Pending Payment';
      case BookingStatus.CONFIRMED:
        return 'Confirmed';
      case BookingStatus.IN_PROGRESS:
        return 'In Transit';
      case BookingStatus.COMPLETED:
        return 'Completed';
      case BookingStatus.CANCELLED:
        return 'Cancelled';
      case BookingStatus.DISPUTED:
        return 'Disputed';
    }
  }
}

enum MarketplaceTripStatus {
  BOOKED,
  DRIVER_ASSIGNED,
  VEHICLE_ASSIGNED,
  DRIVER_ACCEPTED,
  REACHED_LOADING,
  LOADING_STARTED,
  LOADING_COMPLETED,
  IN_TRANSIT,
  REACHED_DESTINATION,
  UNLOADING_STARTED,
  DELIVERED,
  POD_UPLOADED,
  PAYMENT_COMPLETED,
  COMPLETED,
  DELAYED,
  BREAKDOWN,
  ACCIDENT,
  CANCELLED,
  DISPUTED;

  static MarketplaceTripStatus fromString(String? value) {
    return MarketplaceTripStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MarketplaceTripStatus.BOOKED,
    );
  }

  String get displayName {
    return name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

enum DisputeStatus {
  OPEN,
  UNDER_REVIEW,
  RESOLVED,
  CLOSED,
  ESCALATED;

  static DisputeStatus fromString(String? value) {
    return DisputeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DisputeStatus.OPEN,
    );
  }
}

enum DisputeCategory {
  SHORTAGE,
  DAMAGE,
  DELAY,
  PAYMENT,
  CANCELLATION,
  FRAUD,
  ROUTE_DEVIATION,
  DETENTION,
  BEHAVIOR,
  OTHER;

  static DisputeCategory fromString(String? value) {
    return DisputeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DisputeCategory.OTHER,
    );
  }
}

enum WalletTransactionType {
  CREDIT,
  DEBIT,
  HOLD,
  RELEASE,
  REFUND;

  static WalletTransactionType fromString(String? value) {
    return WalletTransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WalletTransactionType.CREDIT,
    );
  }
}

enum PaymentStatus {
  INITIATED,
  PENDING,
  SUCCESS,
  FAILED,
  SETTLED,
  REFUNDED,
  PARTIALLY_REFUNDED;

  static PaymentStatus fromString(String? value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => PaymentStatus.PENDING,
    );
  }
}

enum TruckAvailabilityStatus {
  EMPTY_STANDING,
  EMPTY_MOVING,
  PARTIALLY_LOADED,
  FULL,
  BOOKED,
  UNAVAILABLE;

  static TruckAvailabilityStatus fromString(String? value) {
    if (value == null) return TruckAvailabilityStatus.EMPTY_STANDING;
    return TruckAvailabilityStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => TruckAvailabilityStatus.EMPTY_STANDING,
    );
  }
}

