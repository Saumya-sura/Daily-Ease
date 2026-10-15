import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../bookings/domain/booking_model.dart';
import '../../bookings/presentation/bloc/booking_bloc.dart';
import '../../discovery/data/discovery_repository.dart';
import '../domain/provider_profile.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isListingActive = true;
  bool _isTemporaryModeActive = true;
  ProviderProfile? _provider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
  }

  Future<void> _loadProviderProfile() async {
    final providers = await sl<DiscoveryRepository>().getProviders();
    if (mounted) {
      setState(() {
        _provider = providers.isNotEmpty ? providers.first : null;
        _isLoading = false;
      });
      if (_provider != null) {
        context.read<BookingBloc>().add(BookingLoadProviderBookings(_provider!.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provider Pro Portal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_outlined, size: 64, color: AppColors.primaryLight),
                const SizedBox(height: 16),
                Text(
                  'No Service Profile Found',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your provider profile to list services, set pricing, and start receiving direct customer requests.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Create Service Profile'),
                  onPressed: () => context.go('/provider/onboarding'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  onPressed: () => context.go('/'),
                  label: const Text('Back to Welcome'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = _provider!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.businessName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Provider Pro Dashboard',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Dashboard',
            onPressed: _loadProviderProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Analytics Cards
            Row(
              children: [
                _buildStatCard('Profile Views', '${provider.profileViews}', Icons.visibility_outlined, AppColors.primaryLight),
                const SizedBox(width: 10),
                _buildStatCard('Direct Calls', '${provider.callsInitiated}', Icons.phone_callback_rounded, AppColors.secondaryLight),
                const SizedBox(width: 10),
                _buildStatCard('Bookings', '${provider.bookingRequestsCount}', Icons.check_circle_outline, AppColors.success),
              ],
            ),
            const SizedBox(height: 20),

            // Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Listing Active (Searchable)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Turn off to temporarily pause new customer inquiries', style: TextStyle(fontSize: 11)),
                      value: _isListingActive,
                      activeThumbColor: AppColors.success,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _isListingActive = val);
                        AppNotifier.showInfo(
                          context,
                          title: val ? 'Listing Activated' : 'Listing Paused',
                          description: val ? 'You appear in search results.' : 'Profile hidden from new searches.',
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Temporary-Job Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Accept 1-day urgent help requests without altering regular schedules', style: TextStyle(fontSize: 11)),
                      value: _isTemporaryModeActive,
                      activeThumbColor: AppColors.secondaryLight,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isTemporaryModeActive = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Availability & Calendar Summary
            Text('Working Hours & Capacity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daily Working Hours:', style: TextStyle(fontSize: 13)),
                      Text(provider.workingHours, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daily Job Capacity Limit:', style: TextStyle(fontSize: 13)),
                      Text('${provider.maxDailyJobs} jobs/day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Incoming Customer Requests Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Incoming Requests & Jobs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),

            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is! BookingLoaded) return const SizedBox.shrink();

                final requests = state.bookings;
                if (requests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No active customer requests yet.\nNew bookings from nearby customers will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                    ),
                  );
                }

                return Column(
                  children: requests.map((booking) => _buildRequestTile(context, booking)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context, BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.consumerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.serviceTitle} • ₹${booking.estimatedPrice.toStringAsFixed(0)} (Direct payment)',
              style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Scheduled: ${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year} at ${booking.timeSlot}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Address: ${booking.serviceAddress}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
            if (booking.instructions != null && booking.instructions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Note: "${booking.instructions}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            ],
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, size: 18, color: AppColors.secondaryLight),
                  tooltip: 'Call Customer',
                  onPressed: () => PhoneLauncher.makePhoneCall(
                    context,
                    rawPhoneNumber: booking.consumerPhone,
                    recipientName: booking.consumerName,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF25D366)),
                  tooltip: 'Chat on WhatsApp',
                  onPressed: () => PhoneLauncher.openWhatsApp(
                    context,
                    rawPhoneNumber: booking.consumerPhone,
                    recipientName: booking.consumerName,
                    prefilledMessage:
                        'Hello ${booking.consumerName}, regarding your booking for ${booking.serviceTitle} on Daily-Ease...',
                  ),
                ),
                if (booking.status == 'requested') ...[
                  TextButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(
                            BookingStatusUpdatedEvent(
                              bookingId: booking.id,
                              newStatus: 'declined',
                              actorRole: 'provider',
                              note: 'Provider unavailable for requested slot',
                            ),
                          );
                      AppNotifier.showInfo(context, title: 'Request Declined', description: 'Customer notified.');
                    },
                    child: const Text('Decline', style: TextStyle(color: AppColors.error)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(
                            BookingStatusUpdatedEvent(
                              bookingId: booking.id,
                              newStatus: 'accepted',
                              actorRole: 'provider',
                              note: 'Provider confirmed slot',
                            ),
                          );
                      AppNotifier.showSuccess(context, title: 'Booking Accepted!', description: 'Added to your active jobs.');
                    },
                    child: const Text('Accept Job'),
                  ),
                ] else if (booking.status == 'accepted') ...[
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () {
                      context.read<BookingBloc>().add(
                            BookingStatusUpdatedEvent(
                              bookingId: booking.id,
                              newStatus: 'completed',
                              actorRole: 'provider',
                              note: 'Service marked as completed by provider',
                            ),
                          );
                      AppNotifier.showSuccess(context, title: 'Job Completed!', description: 'Direct payment collected from customer.');
                    },
                    child: const Text('Mark Completed'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
