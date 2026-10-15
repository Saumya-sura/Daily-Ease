import 'package:equatable/equatable.dart';

class BookingTimelineEvent extends Equatable {
  final DateTime timestamp;
  final String actorRole; // 'consumer', 'provider', 'system'
  final String status;
  final String? note;

  const BookingTimelineEvent({
    required this.timestamp,
    required this.actorRole,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'actor_role': actorRole,
        'status': status,
        'note': note,
      };

  factory BookingTimelineEvent.fromJson(Map<String, dynamic> json) {
    return BookingTimelineEvent(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      actorRole: json['actor_role'] as String? ?? 'system',
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [timestamp, actorRole, status, note];
}

class BookingModel extends Equatable {
  final String id;
  final String consumerId;
  final String consumerName;
  final String consumerPhone;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String categoryId;
  final String serviceTitle;
  final String bookingType; // 'one_time', 'temporary_range', 'recurring_daily', 'recurring_monthly'
  final String status; // 'requested', 'accepted', 'declined', 'rescheduled', 'completed', 'cancelled'
  final String recurringStatus; // 'active', 'paused', 'skipped_today'
  final DateTime scheduledDate;
  final DateTime? scheduledEndDate;
  final String timeSlot;
  final String serviceAddress;
  final String? instructions;
  final double estimatedPrice;
  final List<BookingTimelineEvent> timeline;
  final String? cancellationReason;
  final bool isNoShowReported;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.consumerId,
    required this.consumerName,
    required this.consumerPhone,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.categoryId,
    required this.serviceTitle,
    required this.bookingType,
    required this.status,
    this.recurringStatus = 'active',
    required this.scheduledDate,
    this.scheduledEndDate,
    required this.timeSlot,
    required this.serviceAddress,
    this.instructions,
    required this.estimatedPrice,
    this.timeline = const [],
    this.cancellationReason,
    this.isNoShowReported = false,
    required this.createdAt,
  });

  bool get isRecurring =>
      bookingType == 'recurring_daily' || bookingType == 'recurring_monthly';

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'requested';

  Map<String, dynamic> toJson() => {
        'id': id,
        'consumer_id': consumerId,
        'consumer_name': consumerName,
        'consumer_phone': consumerPhone,
        'provider_id': providerId,
        'provider_name': providerName,
        'provider_phone': providerPhone,
        'category_id': categoryId,
        'service_title': serviceTitle,
        'booking_type': bookingType,
        'status': status,
        'recurring_status': recurringStatus,
        'scheduled_date': scheduledDate.toIso8601String(),
        'scheduled_end_date': scheduledEndDate?.toIso8601String(),
        'time_slot': timeSlot,
        'service_address': serviceAddress,
        'instructions': instructions,
        'estimated_price': estimatedPrice,
        'timeline': timeline.map((e) => e.toJson()).toList(),
        'cancellation_reason': cancellationReason,
        'is_no_show_reported': isNoShowReported,
        'created_at': createdAt.toIso8601String(),
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      consumerId: json['consumer_id'] as String? ?? '',
      consumerName: json['consumer_name'] as String? ?? 'Consumer',
      consumerPhone: json['consumer_phone'] as String? ?? '',
      providerId: json['provider_id'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? 'Provider',
      providerPhone: json['provider_phone'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? 'general',
      serviceTitle: json['service_title'] as String? ?? 'Service',
      bookingType: json['booking_type'] as String? ?? 'one_time',
      status: json['status'] as String? ?? 'requested',
      recurringStatus: json['recurring_status'] as String? ?? 'active',
      scheduledDate: DateTime.tryParse(json['scheduled_date'] ?? '') ?? DateTime.now(),
      scheduledEndDate: json['scheduled_end_date'] != null
          ? DateTime.tryParse(json['scheduled_end_date'])
          : null,
      timeSlot: json['time_slot'] as String? ?? '10:00 AM',
      serviceAddress: json['service_address'] as String? ?? '',
      instructions: json['instructions'] as String?,
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0.0,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => BookingTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cancellationReason: json['cancellation_reason'] as String?,
      isNoShowReported: json['is_no_show_reported'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        consumerId,
        providerId,
        status,
        recurringStatus,
        scheduledDate,
        timeSlot,
        estimatedPrice,
      ];
}
