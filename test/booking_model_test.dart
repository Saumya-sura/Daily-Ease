import 'package:flutter_test/flutter_test.dart';
import 'package:daily_ease/features/bookings/domain/booking_model.dart';

void main() {
  group('BookingModel & BookingTimelineEvent Tests', () {
    final now = DateTime(2026, 10, 15, 10, 30);

    test('BookingTimelineEvent parses from JSON and serializes correctly', () {
      final event = BookingTimelineEvent(
        timestamp: now,
        actorRole: 'consumer',
        status: 'requested',
        note: 'Customer requested service',
      );

      final json = event.toJson();
      expect(json['actor_role'], 'consumer');
      expect(json['status'], 'requested');
      expect(json['note'], 'Customer requested service');

      final fromJson = BookingTimelineEvent.fromJson(json);
      expect(fromJson.actorRole, 'consumer');
      expect(fromJson.status, 'requested');
      expect(fromJson.note, 'Customer requested service');
    });

    test('BookingModel computed properties correctly reflect booking type and status', () {
      final oneTimeBooking = BookingModel(
        id: 'bk_1',
        consumerId: 'c_1',
        consumerName: 'Aarav Patel',
        consumerPhone: '+91 98200 00000',
        providerId: 'p_1',
        providerName: 'Ramesh Plumber',
        providerPhone: '+91 98200 11111',
        categoryId: 'plumber',
        serviceTitle: 'Tap Repair',
        bookingType: 'one_time',
        status: 'requested',
        scheduledDate: now,
        timeSlot: '10:00 AM',
        serviceAddress: 'Flat 101, Lake Homes, Powai',
        estimatedPrice: 350.0,
        createdAt: now,
      );

      expect(oneTimeBooking.isRecurring, isFalse);
      expect(oneTimeBooking.isPending, isTrue);
      expect(oneTimeBooking.isCompleted, isFalse);
      expect(oneTimeBooking.isCancelled, isFalse);

      final dailyRecurringBooking = BookingModel(
        id: 'bk_2',
        consumerId: 'c_1',
        consumerName: 'Aarav Patel',
        consumerPhone: '+91 98200 00000',
        providerId: 'p_2',
        providerName: 'Krishna Dairy',
        providerPhone: '+91 98200 22222',
        categoryId: 'milkman',
        serviceTitle: 'Cow Milk Delivery',
        bookingType: 'recurring_daily',
        status: 'completed',
        scheduledDate: now,
        timeSlot: '06:30 AM',
        serviceAddress: 'Flat 101, Lake Homes, Powai',
        estimatedPrice: 68.0,
        createdAt: now,
      );

      expect(dailyRecurringBooking.isRecurring, isTrue);
      expect(dailyRecurringBooking.isCompleted, isTrue);
      expect(dailyRecurringBooking.isPending, isFalse);
    });

    test('BookingModel round-trips through JSON without data loss', () {
      final booking = BookingModel(
        id: 'bk_test_100',
        consumerId: 'c_99',
        consumerName: 'Sneha Rao',
        consumerPhone: '+91 98111 22233',
        providerId: 'p_88',
        providerName: 'Sunita Maid',
        providerPhone: '+91 98444 55566',
        categoryId: 'maid',
        serviceTitle: 'House Cleaning',
        bookingType: 'recurring_monthly',
        status: 'accepted',
        recurringStatus: 'active',
        scheduledDate: DateTime(2026, 11, 1),
        timeSlot: '07:30 AM - 09:00 AM',
        serviceAddress: 'Apt 502, Prestige Enclave',
        instructions: 'Please take service elevator',
        estimatedPrice: 3000.0,
        timeline: [
          BookingTimelineEvent(
            timestamp: now,
            actorRole: 'consumer',
            status: 'requested',
            note: 'Initial booking',
          ),
          BookingTimelineEvent(
            timestamp: now.add(const Duration(minutes: 15)),
            actorRole: 'provider',
            status: 'accepted',
            note: 'Accepted slot',
          ),
        ],
        cancellationReason: null,
        isNoShowReported: false,
        createdAt: now,
      );

      final json = booking.toJson();
      final reconstructed = BookingModel.fromJson(json);

      expect(reconstructed.id, 'bk_test_100');
      expect(reconstructed.consumerName, 'Sneha Rao');
      expect(reconstructed.providerName, 'Sunita Maid');
      expect(reconstructed.bookingType, 'recurring_monthly');
      expect(reconstructed.status, 'accepted');
      expect(reconstructed.recurringStatus, 'active');
      expect(reconstructed.estimatedPrice, 3000.0);
      expect(reconstructed.timeline.length, 2);
      expect(reconstructed.timeline.first.status, 'requested');
      expect(reconstructed.timeline.last.status, 'accepted');
    });
  });
}
