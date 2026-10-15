import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/app_notifier.dart';
import '../../auth/domain/user_address.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../localization/locale_cubit.dart';

class ConsumerProfileScreen extends StatelessWidget {
  const ConsumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeCubit>().state;
    final currentLocale = context.watch<LocaleCubit>().state.languageCode;
    final authState = context.watch<AuthBloc>().state;
    final UserProfile? user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryContainerLight,
                      child: Text(
                        (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Guest User',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (user?.phoneNumber.isNotEmpty ?? false)
                            Text(user!.phoneNumber, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                          if (user?.email.isNotEmpty ?? false)
                            Text(user!.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Multiple Saved Addresses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Addresses (${user?.addresses.length ?? 0})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Address'),
                  onPressed: () => _showAddAddressDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (user == null || user.addresses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No saved addresses yet.\nAdd your home, hostel, or office address for fast bookings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              )
            else
              ...user.addresses.map((addr) => _buildAddressCard(context, addr)),
            const SizedBox(height: 24),

            // App Preferences
            Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  // Tri-lingual Language Selector
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primaryLight),
                    title: const Text('App Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      currentLocale == 'hi'
                          ? 'हिंदी (Hindi)'
                          : currentLocale == 'mr'
                              ? 'मराठी (Marathi)'
                              : 'English',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: DropdownButton<String>(
                      value: currentLocale,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                        DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          context.read<LocaleCubit>().changeLocale(val);
                          AppNotifier.showSuccess(context, title: 'Language Changed', description: 'Updated successfully');
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  // Dark Mode Switch
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primaryLight,
                    ),
                    title: const Text('Dark Mode (OLED Slate)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: isDark,
                    onChanged: (val) => context.read<ThemeCubit>().toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),

            // Logout
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Sign Out / Reset Account', style: TextStyle(color: AppColors.error)),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/');
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, UserAddress addr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          addr.type == AddressType.home
              ? Icons.home_rounded
              : addr.type == AddressType.office
                  ? Icons.work_rounded
                  : Icons.school_rounded,
          color: AppColors.primaryLight,
        ),
        title: Row(
          children: [
            Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (addr.isPrimary) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryContainerLight, borderRadius: BorderRadius.circular(4)),
                child: const Text('DEFAULT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
              ),
            ],
          ],
        ),
        subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final labelCtrl = TextEditingController(text: 'Home');
    final flatCtrl = TextEditingController();
    final socCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Saved Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. Home, Hostel, Office)')),
            const SizedBox(height: 8),
            TextField(controller: flatCtrl, decoration: const InputDecoration(labelText: 'Flat / Room No')),
            const SizedBox(height: 8),
            TextField(controller: socCtrl, decoration: const InputDecoration(labelText: 'Apartment / Society Name')),
            const SizedBox(height: 8),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Locality & City')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (labelCtrl.text.isNotEmpty) {
                final newAddress = UserAddress(
                  id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                  label: labelCtrl.text.trim(),
                  type: AddressType.home,
                  societyOrBuilding: socCtrl.text.trim(),
                  flatOrRoom: flatCtrl.text.trim(),
                  locality: locCtrl.text.trim(),
                  city: 'City',
                  pincode: '',
                  isPrimary: true,
                );
                context.read<AuthBloc>().add(AuthAddressAdded(newAddress));
                Navigator.pop(context);
                AppNotifier.showSuccess(context, title: 'Address Saved', description: '${labelCtrl.text} added to your addresses.');
              }
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }
}
