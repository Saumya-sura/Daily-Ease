import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../discovery/data/discovery_repository.dart';
import '../../provider/domain/provider_profile.dart';
import '../domain/booking_model.dart';
import 'bloc/booking_bloc.dart';

class CreateBookingScreen extends StatefulWidget {
  final String providerId;

  const CreateBookingScreen({super.key, required this.providerId});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _bookingType = 'one_time';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '08:30 AM - 10:30 AM';
  String _selectedAddress = '';
  final _addressTextController = TextEditingController();
  final _instructionsController = TextEditingController();
  ProviderProfile? _provider;
  bool _isLoading = true;

  final List<String> _timeSlots = [
    '06:30 AM - 08:30 AM',
    '08:30 AM - 10:30 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '05:00 PM - 07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final p = await sl<DiscoveryRepository>().getProviderById(widget.providerId);
    if (mounted) {
      setState(() {
        _provider = p;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _addressTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Service')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Provider details unavailable'),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => context.pop(), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final provider = _provider!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ServiceIconBadge(categoryId: provider.primaryCategoryId, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.businessName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Estimated rate: ${provider.formattedPrice}',
                            style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Booking Type
              Text('Booking Arrangement', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'one_time',
                    label: Text('1-Day / Temporary'),
                    icon: Icon(Icons.flash_on_rounded),
                  ),
                  ButtonSegment(
                    value: 'recurring_daily',
                    label: Text('Daily Recurring'),
                    icon: Icon(Icons.repeat_rounded),
                  ),
                  ButtonSegment(
                    value: 'recurring_monthly',
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month_rounded),
                  ),
                ],
                selected: {_bookingType},
                onSelectionChanged: (val) => setState(() => _bookingType = val.first),
              ),
              const SizedBox(height: 24),

              // Date Picker
              Text('Start Date', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryLight),
                          const SizedBox(width: 10),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Text('Change', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Slot Picker
              Text('Preferred Time Slot', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSlot = slot);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Service Address
              Text('Service Address & Society', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (currentUser != null && currentUser.addresses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioGroup<String>(
                    groupValue: _selectedAddress,
                    onChanged: (val) => setState(() => _selectedAddress = val ?? _selectedAddress),
                    child: Column(
                      children: currentUser.addresses.map((addr) {
                        final fullText = addr.fullAddress;
                        if (_selectedAddress.isEmpty) _selectedAddress = fullText;
                        return RadioListTile<String>(
                          title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(fullText, style: const TextStyle(fontSize: 12)),
                          value: fullText,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                AppTextField(
                  label: 'Enter Delivery / Service Address',
                  hint: 'Flat no, building/society name, locality, city',
                  controller: _addressTextController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please specify service location' : null,
                ),
              ],
              const SizedBox(height: 20),

              // Instructions
              AppTextField(
                label: 'Special Instructions for Worker',
                controller: _instructionsController,
                maxLines: 2,
                hint: 'e.g. Ring bell, bring specific tools, preferred gate entrance',
              ),
              const SizedBox(height: 24),

              // Offline Direct Payment Disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.handshake_rounded, color: AppColors.success, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Direct Payment Settlement',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'No advance or in-app charges. You pay the worker directly upon completion via Cash or UPI.',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              AppButton(
                label: 'Confirm Booking Request',
                onPressed: () {
                  final finalAddr = _selectedAddress.isNotEmpty
                      ? _selectedAddress
                      : _addressTextController.text.trim();

                  if (finalAddr.isEmpty) {
                    AppNotifier.showWarning(context, title: 'Address Required', description: 'Please provide service address.');
                    return;
                  }

                  final newBooking = BookingModel(
                    id: 'book_${DateTime.now().millisecondsSinceEpoch}',
                    consumerId: currentUser?.id ?? 'guest_consumer',
                    consumerName: currentUser?.fullName ?? 'Valued Customer',
                    consumerPhone: currentUser?.phoneNumber ?? '',
                    providerId: provider.id,
                    providerName: provider.businessName,
                    providerPhone: provider.phoneNumber,
                    categoryId: provider.primaryCategoryId,
                    serviceTitle: '${provider.businessName} Service',
                    bookingType: _bookingType,
                    status: 'requested',
                    scheduledDate: _selectedDate,
                    timeSlot: _selectedSlot,
                    serviceAddress: finalAddr,
                    instructions: _instructionsController.text,
                    estimatedPrice: provider.basePrice,
                    createdAt: DateTime.now(),
                  );

                  context.read<BookingBloc>().add(BookingCreatedEvent(newBooking));
                  AppNotifier.showSuccess(
                    context,
                    title: 'Booking Requested!',
                    description: 'Your request was sent directly to ${provider.businessName}.',
                  );
                  context.go('/consumer/bookings');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
