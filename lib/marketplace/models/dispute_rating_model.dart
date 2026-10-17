import 'marketplace_enums.dart';

class DisputeModel {
  final int? id;
  final int bookingId;
  final int? raisedByCompanyId;
  final DisputeCategory category;
  final DisputeStatus status;
  final String description;
  final double? claimAmount;
  final String? resolution;
  final String? createdAt;

  DisputeModel({
    this.id,
    required this.bookingId,
    this.raisedByCompanyId,
    required this.category,
    this.status = DisputeStatus.OPEN,
    required this.description,
    this.claimAmount,
    this.resolution,
    this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] as int?,
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      raisedByCompanyId: json['raisedByCompanyId'] as int?,
      category: DisputeCategory.fromString(json['category']?.toString()),
      status: DisputeStatus.fromString(json['status']?.toString()),
      description: json['description']?.toString() ?? '',
      claimAmount: (json['claimAmount'] as num?)?.toDouble(),
      resolution: json['resolution']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'category': category.name,
      'description': description,
      if (claimAmount != null) 'claimAmount': claimAmount,
    };
  }
}

class RatingReviewModel {
  final int? id;
  final int bookingId;
  final int? reviewerCompanyId;
  final int? revieweeCompanyId;
  final int overallRating;
  final int? communicationRating;
  final int? punctualityRating;
  final int? professionalismRating;
  final int? paymentRating;
  final String? comment;
  final List<String>? tags;
  final String? createdAt;

  RatingReviewModel({
    this.id,
    required this.bookingId,
    this.reviewerCompanyId,
    this.revieweeCompanyId,
    required this.overallRating,
    this.communicationRating,
    this.punctualityRating,
    this.professionalismRating,
    this.paymentRating,
    this.comment,
    this.tags,
    this.createdAt,
  });

  factory RatingReviewModel.fromJson(Map<String, dynamic> json) {
    return RatingReviewModel(
      id: json['id'] as int?,
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      reviewerCompanyId: json['reviewerCompanyId'] as int?,
      revieweeCompanyId: json['revieweeCompanyId'] as int?,
      overallRating: (json['overallRating'] as num?)?.toInt() ?? 5,
      communicationRating: (json['communicationRating'] as num?)?.toInt(),
      punctualityRating: (json['punctualityRating'] as num?)?.toInt(),
      professionalismRating: (json['professionalismRating'] as num?)?.toInt(),
      paymentRating: (json['paymentRating'] as num?)?.toInt(),
      comment: json['comment']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'overallRating': overallRating,
      if (communicationRating != null)
        'communicationRating': communicationRating,
      if (punctualityRating != null) 'punctualityRating': punctualityRating,
      if (professionalismRating != null)
        'professionalismRating': professionalismRating,
      if (paymentRating != null) 'paymentRating': paymentRating,
      if (comment != null) 'comment': comment,
      if (tags != null) 'tags': tags,
    };
  }
}
