import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String bookingId;
  final String consumerId;
  final String consumerName;
  final String providerId;
  final double rating;
  final String reviewText;
  final bool isVerifiedBooking;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.consumerId,
    required this.consumerName,
    required this.providerId,
    required this.rating,
    required this.reviewText,
    this.isVerifiedBooking = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'consumer_id': consumerId,
        'consumer_name': consumerName,
        'provider_id': providerId,
        'rating': rating,
        'review_text': reviewText,
        'is_verified_booking': isVerifiedBooking,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? '',
      consumerId: json['consumer_id'] as String? ?? '',
      consumerName: json['consumer_name'] as String? ?? 'Verified Customer',
      providerId: json['provider_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: json['review_text'] as String? ?? '',
      isVerifiedBooking: json['is_verified_booking'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, bookingId, consumerId, providerId, rating, isVerifiedBooking];
}

class UserReport extends Equatable {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String? bookingId;
  final String reason; // 'harassment', 'fake_profile', 'no_show', 'fraud', 'other'
  final String details;
  final String status; // 'pending', 'investigating', 'resolved', 'dismissed'
  final DateTime createdAt;

  const UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.bookingId,
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'booking_id': bookingId,
        'reason': reason,
        'details': details,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String? ?? '',
      reportedUserId: json['reported_user_id'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      reason: json['reason'] as String? ?? 'other',
      details: json['details'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, reporterId, reportedUserId, reason, status];
}
