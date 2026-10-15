import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookingsForConsumer(String consumerId);
  Future<List<BookingModel>> getBookingsForProvider(String providerId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String newStatus, {
    required String actorRole,
    String? note,
    String? cancellationReason,
    bool isNoShow = false,
  });
  Future<BookingModel> updateRecurringStatus(
    String bookingId,
    String newRecurringStatus,
  );
  Future<void> saveDraftBooking(Map<String, dynamic> draftData);
  Future<Map<String, dynamic>?> getDraftBooking();
  Future<void> clearDraftBooking();
}

class BookingRepositoryImpl implements BookingRepository {
  final HiveStorageService _storageService;
  final List<BookingModel> _bookings = [];

  BookingRepositoryImpl(this._storageService) {
    _loadCachedBookings();
  }

  void _loadCachedBookings() {
    try {
      final cachedList = _storageService.getCached(HiveBoxes.bookings, 'all_bookings');
      if (cachedList != null && cachedList is List) {
        for (final item in cachedList) {
          if (item is Map) {
            final b = BookingModel.fromJson(Map<String, dynamic>.from(item));
            if (!_isLegacyDummyBooking(b.id)) {
              _bookings.add(b);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.warning('BookingRepo', 'Failed loading cached bookings: $e');
    }
  }

  bool _isLegacyDummyBooking(String id) {
    return id.startsWith('bk_10');
  }

  Future<void> _persistBookings() async {
    try {
      await _storageService.putCached(
        HiveBoxes.bookings,
        'all_bookings',
        _bookings.map((b) => b.toJson()).toList(),
      );
    } catch (e) {
      AppLogger.warning('BookingRepo', 'Failed caching bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>> getBookingsForConsumer(String consumerId) async {
    if (consumerId.isEmpty) return [];
    AppLogger.debug('BookingRepo', 'Fetching bookings for consumer', {'consumerId': consumerId});

    if (SupabaseConfig.isLiveConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('bookings')
            .select()
            .eq('consumer_id', consumerId);
        for (final item in response) {
          try {
            final b = BookingModel.fromJson(Map<String, dynamic>.from(item));
            if (!_isLegacyDummyBooking(b.id)) {
              final idx = _bookings.indexWhere((existing) => existing.id == b.id);
              if (idx >= 0) {
                _bookings[idx] = b;
              } else {
                _bookings.add(b);
              }
            }
          } catch (_) {}
        }
      } catch (e) {
        AppLogger.warning('BookingRepo', 'Could not query Supabase bookings: $e');
      }
    }

    return _bookings.where((b) => b.consumerId == consumerId).toList();
  }

  @override
  Future<List<BookingModel>> getBookingsForProvider(String providerId) async {
    if (providerId.isEmpty) return [];
    AppLogger.debug('BookingRepo', 'Fetching bookings for provider', {'providerId': providerId});

    if (SupabaseConfig.isLiveConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('bookings')
            .select()
            .eq('provider_id', providerId);
        for (final item in response) {
          try {
            final b = BookingModel.fromJson(Map<String, dynamic>.from(item));
            if (!_isLegacyDummyBooking(b.id)) {
              final idx = _bookings.indexWhere((existing) => existing.id == b.id);
              if (idx >= 0) {
                _bookings[idx] = b;
              } else {
                _bookings.add(b);
              }
            }
          } catch (_) {}
        }
      } catch (e) {
        AppLogger.warning('BookingRepo', 'Could not query Supabase provider bookings: $e');
      }
    }

    return _bookings.where((b) => b.providerId == providerId).toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    AppLogger.info('BookingRepo', 'Creating new real booking', {
      'id': booking.id,
      'service': booking.serviceTitle,
      'type': booking.bookingType,
    });

    final updatedTimeline = [
      ...booking.timeline,
      BookingTimelineEvent(
        timestamp: DateTime.now(),
        actorRole: 'consumer',
        status: 'requested',
        note: 'Booking requested by consumer',
      ),
    ];

    final finalBooking = BookingModel(
      id: booking.id,
      consumerId: booking.consumerId,
      consumerName: booking.consumerName,
      consumerPhone: booking.consumerPhone,
      providerId: booking.providerId,
      providerName: booking.providerName,
      providerPhone: booking.providerPhone,
      categoryId: booking.categoryId,
      serviceTitle: booking.serviceTitle,
      bookingType: booking.bookingType,
      status: 'requested',
      recurringStatus: 'active',
      scheduledDate: booking.scheduledDate,
      scheduledEndDate: booking.scheduledEndDate,
      timeSlot: booking.timeSlot,
      serviceAddress: booking.serviceAddress,
      instructions: booking.instructions,
      estimatedPrice: booking.estimatedPrice,
      timeline: updatedTimeline,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, finalBooking);
    await _persistBookings();
    await clearDraftBooking();

    if (SupabaseConfig.isLiveConfigured) {
      try {
        await Supabase.instance.client
            .from('bookings')
            .insert(finalBooking.toJson());
        AppLogger.info('BookingRepo', 'Booking pushed to Supabase');
      } catch (e) {
        AppLogger.warning('BookingRepo', 'Failed pushing booking to Supabase: $e');
      }
    }

    return finalBooking;
  }

  @override
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String newStatus, {
    required String actorRole,
    String? note,
    String? cancellationReason,
    bool isNoShow = false,
  }) async {
    AppLogger.info('BookingRepo', 'Updating booking status', {
      'bookingId': bookingId,
      'newStatus': newStatus,
      'actor': actorRole,
    });

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }

    final current = _bookings[index];
    final updatedTimeline = List<BookingTimelineEvent>.from(current.timeline)
      ..add(
        BookingTimelineEvent(
          timestamp: DateTime.now(),
          actorRole: actorRole,
          status: newStatus,
          note: note ?? 'Status changed to $newStatus',
        ),
      );

    final updated = BookingModel(
      id: current.id,
      consumerId: current.consumerId,
      consumerName: current.consumerName,
      consumerPhone: current.consumerPhone,
      providerId: current.providerId,
      providerName: current.providerName,
      providerPhone: current.providerPhone,
      categoryId: current.categoryId,
      serviceTitle: current.serviceTitle,
      bookingType: current.bookingType,
      status: newStatus,
      recurringStatus: current.recurringStatus,
      scheduledDate: current.scheduledDate,
      scheduledEndDate: current.scheduledEndDate,
      timeSlot: current.timeSlot,
      serviceAddress: current.serviceAddress,
      instructions: current.instructions,
      estimatedPrice: current.estimatedPrice,
      timeline: updatedTimeline,
      cancellationReason: cancellationReason ?? current.cancellationReason,
      isNoShowReported: isNoShow || current.isNoShowReported,
      createdAt: current.createdAt,
    );

    _bookings[index] = updated;
    await _persistBookings();

    if (SupabaseConfig.isLiveConfigured) {
      try {
        await Supabase.instance.client
            .from('bookings')
            .update({
              'status': newStatus,
              'timeline': updatedTimeline.map((e) => e.toJson()).toList(),
              'cancellation_reason': ?cancellationReason,
              if (isNoShow) 'is_no_show_reported': true,
            })
            .eq('id', bookingId);
      } catch (e) {
        AppLogger.warning('BookingRepo', 'Supabase status update failed: $e');
      }
    }

    return updated;
  }

  @override
  Future<BookingModel> updateRecurringStatus(
    String bookingId,
    String newRecurringStatus,
  ) async {
    AppLogger.info('BookingRepo', 'Updating recurring status', {
      'bookingId': bookingId,
      'recurringStatus': newRecurringStatus,
    });

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }

    final current = _bookings[index];
    final updatedTimeline = List<BookingTimelineEvent>.from(current.timeline)
      ..add(
        BookingTimelineEvent(
          timestamp: DateTime.now(),
          actorRole: 'consumer',
          status: newRecurringStatus,
          note: 'Recurring schedule: $newRecurringStatus',
        ),
      );

    final updated = BookingModel(
      id: current.id,
      consumerId: current.consumerId,
      consumerName: current.consumerName,
      consumerPhone: current.consumerPhone,
      providerId: current.providerId,
      providerName: current.providerName,
      providerPhone: current.providerPhone,
      categoryId: current.categoryId,
      serviceTitle: current.serviceTitle,
      bookingType: current.bookingType,
      status: current.status,
      recurringStatus: newRecurringStatus,
      scheduledDate: current.scheduledDate,
      scheduledEndDate: current.scheduledEndDate,
      timeSlot: current.timeSlot,
      serviceAddress: current.serviceAddress,
      instructions: current.instructions,
      estimatedPrice: current.estimatedPrice,
      timeline: updatedTimeline,
      cancellationReason: current.cancellationReason,
      isNoShowReported: current.isNoShowReported,
      createdAt: current.createdAt,
    );

    _bookings[index] = updated;
    await _persistBookings();

    if (SupabaseConfig.isLiveConfigured) {
      try {
        await Supabase.instance.client
            .from('bookings')
            .update({
              'recurring_status': newRecurringStatus,
              'timeline': updatedTimeline.map((e) => e.toJson()).toList(),
            })
            .eq('id', bookingId);
      } catch (e) {
        AppLogger.warning('BookingRepo', 'Supabase recurring update failed: $e');
      }
    }

    return updated;
  }

  @override
  Future<void> saveDraftBooking(Map<String, dynamic> draftData) async {
    await _storageService.putCached(HiveBoxes.drafts, 'current_booking_draft', draftData);
  }

  @override
  Future<Map<String, dynamic>?> getDraftBooking() async {
    final data = _storageService.getCached(HiveBoxes.drafts, 'current_booking_draft');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  @override
  Future<void> clearDraftBooking() async {
    await _storageService.deleteCached(HiveBoxes.drafts, 'current_booking_draft');
  }
}
