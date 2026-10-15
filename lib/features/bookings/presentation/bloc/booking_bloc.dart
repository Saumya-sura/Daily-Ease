import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/booking_repository.dart';
import '../../domain/booking_model.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class BookingLoadConsumerBookings extends BookingEvent {
  final String consumerId;
  const BookingLoadConsumerBookings(this.consumerId);
  @override
  List<Object?> get props => [consumerId];
}

class BookingLoadProviderBookings extends BookingEvent {
  final String providerId;
  const BookingLoadProviderBookings(this.providerId);
  @override
  List<Object?> get props => [providerId];
}

class BookingCreatedEvent extends BookingEvent {
  final BookingModel booking;
  const BookingCreatedEvent(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingStatusUpdatedEvent extends BookingEvent {
  final String bookingId;
  final String newStatus;
  final String actorRole;
  final String? note;
  final String? cancellationReason;
  final bool isNoShow;

  const BookingStatusUpdatedEvent({
    required this.bookingId,
    required this.newStatus,
    required this.actorRole,
    this.note,
    this.cancellationReason,
    this.isNoShow = false,
  });

  @override
  List<Object?> get props => [bookingId, newStatus, actorRole, cancellationReason, isNoShow];
}

class BookingRecurringUpdatedEvent extends BookingEvent {
  final String bookingId;
  final String newRecurringStatus; // 'paused', 'active', 'skipped_today'

  const BookingRecurringUpdatedEvent({
    required this.bookingId,
    required this.newRecurringStatus,
  });

  @override
  List<Object?> get props => [bookingId, newRecurringStatus];
}

// States
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  const BookingLoaded(this.bookings);

  List<BookingModel> get activeBookings =>
      bookings.where((b) => b.status == 'accepted' || b.status == 'requested').toList();

  List<BookingModel> get recurringBookings =>
      bookings.where((b) => b.isRecurring).toList();

  List<BookingModel> get historyBookings =>
      bookings.where((b) => b.status == 'completed' || b.status == 'cancelled' || b.status == 'declined').toList();

  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc(this._bookingRepository) : super(BookingInitial()) {
    on<BookingLoadConsumerBookings>(_onLoadConsumerBookings);
    on<BookingLoadProviderBookings>(_onLoadProviderBookings);
    on<BookingCreatedEvent>(_onBookingCreated);
    on<BookingStatusUpdatedEvent>(_onStatusUpdated);
    on<BookingRecurringUpdatedEvent>(_onRecurringUpdated);
  }

  Future<void> _onLoadConsumerBookings(
    BookingLoadConsumerBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final list = await _bookingRepository.getBookingsForConsumer(event.consumerId);
      emit(BookingLoaded(list));
    } catch (e) {
      AppLogger.error('BookingBloc', 'Failed to load bookings', error: e);
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadProviderBookings(
    BookingLoadProviderBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final list = await _bookingRepository.getBookingsForProvider(event.providerId);
      emit(BookingLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onBookingCreated(
    BookingCreatedEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _bookingRepository.createBooking(event.booking);
      final list = await _bookingRepository.getBookingsForConsumer(event.booking.consumerId);
      emit(BookingLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onStatusUpdated(
    BookingStatusUpdatedEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _bookingRepository.updateBookingStatus(
        event.bookingId,
        event.newStatus,
        actorRole: event.actorRole,
        note: event.note,
        cancellationReason: event.cancellationReason,
        isNoShow: event.isNoShow,
      );
      // Reload current bookings
      if (state is BookingLoaded) {
        final current = (state as BookingLoaded).bookings;
        final consumerId = current.isNotEmpty ? current.first.consumerId : 'user_consumer_1';
        final updated = await _bookingRepository.getBookingsForConsumer(consumerId);
        emit(BookingLoaded(updated));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onRecurringUpdated(
    BookingRecurringUpdatedEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await _bookingRepository.updateRecurringStatus(
        event.bookingId,
        event.newRecurringStatus,
      );
      if (state is BookingLoaded) {
        final current = (state as BookingLoaded).bookings;
        final consumerId = current.isNotEmpty ? current.first.consumerId : 'user_consumer_1';
        final updated = await _bookingRepository.getBookingsForConsumer(consumerId);
        emit(BookingLoaded(updated));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
