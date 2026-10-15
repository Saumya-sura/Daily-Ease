import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../localization/locale_cubit.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String _selectedRole = 'consumer';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = context.watch<LocaleCubit>().state.languageCode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Switcher Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.handyman_rounded, color: AppColors.primaryLight, size: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Tri-lingual Chips (EN, HI, MR)
                  Row(
                    children: [
                      _buildLangChip(context, 'en', 'EN', currentLocale),
                      const SizedBox(width: 6),
                      _buildLangChip(context, 'hi', 'हिं', currentLocale),
                      const SizedBox(width: 6),
                      _buildLangChip(context, 'mr', 'मरा', currentLocale),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              Text(
                l10n.welcomeTitle,
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Consumer Role Card
              _buildRoleCard(
                context,
                role: 'consumer',
                title: l10n.roleConsumer,
                description: l10n.roleConsumerDesc,
                icon: Icons.person_search_rounded,
                color: AppColors.primaryLight,
              ),
              const SizedBox(height: 16),

              // Provider Role Card
              _buildRoleCard(
                context,
                role: 'provider',
                title: l10n.roleProvider,
                description: l10n.roleProviderDesc,
                icon: Icons.work_outline_rounded,
                color: AppColors.secondaryLight,
              ),

              const Spacer(flex: 2),

              AppButton(
                label: l10n.continueButton,
                onPressed: () {
                  if (_selectedRole == 'consumer') {
                    context.read<AuthBloc>().add(const AuthRoleSwitched('consumer'));
                    context.go('/consumer/home');
                  } else {
                    context.read<AuthBloc>().add(const AuthRoleSwitched('provider'));
                    context.go('/provider/onboarding');
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangChip(BuildContext context, String code, String label, String current) {
    final isSelected = current == code;
    return GestureDetector(
      onTap: () => context.read<LocaleCubit>().changeLocale(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? color : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
