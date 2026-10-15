import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../domain/booking_model.dart';
import 'bloc/booking_bloc.dart';

class ConsumerBookingsScreen extends StatefulWidget {
  const ConsumerBookingsScreen({super.key});

  @override
  State<ConsumerBookingsScreen> createState() => _ConsumerBookingsScreenState();
}

class _ConsumerBookingsScreenState extends State<ConsumerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';
    context
        .read<BookingBloc>()
        .add(BookingLoadConsumerBookings(currentUserId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings & Services'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Active (Now)'),
            Tab(text: 'Household Recurring'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! BookingLoaded) return const SizedBox.shrink();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, state.activeBookings, isRecurringTab: false),
              _buildBookingList(context, state.recurringBookings, isRecurringTab: true),
              _buildBookingList(context, state.historyBookings, isRecurringTab: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<BookingModel> list, {
    required bool isRecurringTab,
  }) {
    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecurringTab) ...[
                _buildTrackerBanner(context),
                const SizedBox(height: 24),
              ],
              Icon(
                isRecurringTab ? Icons.repeat_rounded : Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.textTertiaryLight,
              ),
              const SizedBox(height: 12),
              Text(
                isRecurringTab
                    ? 'No ongoing household recurring contracts'
                    : 'No bookings found in this category',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                isRecurringTab
                    ? 'Track daily milk or maid visits using the calculator above.'
                    : 'Your service updates will appear here.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (isRecurringTab ? 1 : 0),
      itemBuilder: (context, index) {
        if (isRecurringTab && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _buildTrackerBanner(context),
          );
        }
        final booking = list[isRecurringTab ? index - 1 : index];
        return _buildBookingCard(context, booking, isRecurringTab: isRecurringTab);
      },
    );
  }

  Widget _buildTrackerBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/consumer/household-tracker'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Attendance & Bill Tracker',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Track milk delivery or maid days, calculate bill & share on WhatsApp',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    BookingModel booking, {
    required bool isRecurringTab,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ServiceIconBadge(categoryId: booking.categoryId, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        booking.providerName,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Text(
                  '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year} • ${booking.timeSlot}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.serviceAddress,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Recurring Management Controls (Pause, Resume, Skip Day)
            if (isRecurringTab) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recurring State: ${booking.recurringStatus.toUpperCase()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                    ),
                    Row(
                      children: [
                        if (booking.recurringStatus != 'paused')
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            onPressed: () {
                              context.read<BookingBloc>().add(
                                    BookingRecurringUpdatedEvent(
                                      bookingId: booking.id,
                                      newRecurringStatus: 'paused',
                                    ),
                                  );
                              AppNotifier.showInfo(context, title: 'Service Paused', description: 'Visits paused until you resume.');
                            },
                            child: const Text('Pause', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        else
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            onPressed: () {
                              context.read<BookingBloc>().add(
                                    BookingRecurringUpdatedEvent(
                                      bookingId: booking.id,
                                      newRecurringStatus: 'active',
                                    ),
                                  );
                              AppNotifier.showSuccess(context, title: 'Service Resumed', description: 'Visits active as scheduled.');
                            },
                            child: const Text('Resume', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(width: 12),
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          onPressed: () {
                            context.read<BookingBloc>().add(
                                  BookingRecurringUpdatedEvent(
                                    bookingId: booking.id,
                                    newRecurringStatus: 'skipped_today',
                                  ),
                                );
                            AppNotifier.showWarning(context, title: 'Skipped Today', description: 'Worker notified for today.');
                          },
                          child: const Text('Skip Day', style: TextStyle(fontSize: 12, color: AppColors.warning)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timeline Audit Trail Button
                TextButton.icon(
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text('Timeline', style: TextStyle(fontSize: 12)),
                  onPressed: () => _showTimelineModal(context, booking),
                ),
                Row(
                  children: [
                    // Direct Call
                    IconButton(
                      icon: const Icon(Icons.call_rounded, color: AppColors.secondaryLight, size: 18),
                      tooltip: 'Call Worker',
                      onPressed: () => PhoneLauncher.makePhoneCall(
                        context,
                        rawPhoneNumber: booking.providerPhone,
                        recipientName: booking.providerName,
                      ),
                    ),
                    // Chat on WhatsApp
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 18),
                      tooltip: 'Chat on WhatsApp',
                      onPressed: () => PhoneLauncher.openWhatsApp(
                        context,
                        rawPhoneNumber: booking.providerPhone,
                        recipientName: booking.providerName,
                        prefilledMessage: 'Hi ${booking.providerName}, regarding our ${booking.serviceTitle} arrangement on Daily-Ease...',
                      ),
                    ),
                    // Cancel Booking
                    if (booking.status == 'requested' || booking.status == 'accepted')
                      TextButton(
                        onPressed: () => _showCancelDialog(context, booking),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    // Write Review (Only for completed bookings)
                    if (booking.status == 'completed')
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _showReviewDialog(context, booking),
                        child: const Text('Write Review', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTimelineModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Timeline & Audit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Audit history for ${booking.serviceTitle} (${booking.id})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: booking.timeline.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = booking.timeline[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primaryLight),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.status.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              if (event.note != null)
                                Text(event.note!, style: const TextStyle(fontSize: 12)),
                              Text(
                                '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')} • ${event.actorRole}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, BookingModel booking) {
    String selectedReason = 'Plan changed / Found alternative';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please select a cancellation reason:'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedReason,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Plan changed / Found alternative', child: Text('Plan changed')),
                DropdownMenuItem(value: 'Provider requested cancellation', child: Text('Worker requested cancel')),
                DropdownMenuItem(value: 'Worker did not arrive (No-Show)', child: Text('Worker No-Show')),
                DropdownMenuItem(value: 'Price disagreement', child: Text('Price disagreement')),
              ],
              onChanged: (val) => selectedReason = val ?? selectedReason,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingBloc>().add(
                    BookingStatusUpdatedEvent(
                      bookingId: booking.id,
                      newStatus: 'cancelled',
                      actorRole: 'consumer',
                      cancellationReason: selectedReason,
                      isNoShow: selectedReason.contains('No-Show'),
                    ),
                  );
              AppNotifier.showInfo(context, title: 'Booking Cancelled', description: selectedReason);
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, BookingModel booking) {
    double selectedRating = 5.0;
    final reviewTextController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Review ${booking.providerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How was the completed service?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = starIndex.toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewTextController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your feedback for future customers...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                AppNotifier.showSuccess(
                  context,
                  title: 'Review Submitted!',
                  description: 'Thank you for helping keep Daily-Ease trusted.',
                );
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
