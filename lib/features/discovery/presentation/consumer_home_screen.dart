import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../provider/domain/provider_profile.dart';
import 'bloc/discovery_bloc.dart';

class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedSociety = 'All Societies';
  bool _emergencyOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(DiscoveryLoadInitial());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter({String? categoryId, String? society, bool? emergency}) {
    context.read<DiscoveryBloc>().add(
          DiscoveryFilterChanged(
            categoryId: categoryId ?? _selectedCategory,
            searchQuery: _searchController.text,
            societyFilter: society ?? _selectedSociety,
            emergencyOnly: emergency ?? _emergencyOnly,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final primaryAddr = user?.primaryAddress;
    final hasAddress = primaryAddr != null && primaryAddr.locality.isNotEmpty;
    final locationTitle = hasAddress
        ? '${primaryAddr.locality}, ${primaryAddr.city}'
        : 'Local Services Area';
    final locationSubtitle = (primaryAddr != null && primaryAddr.societyOrBuilding.isNotEmpty)
        ? primaryAddr.societyOrBuilding
        : 'Within 5 km radius';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 4),
                Text(
                  locationTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
            Text(
              locationSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Milk & Maid Bill Tracker',
            onPressed: () => context.push('/consumer/household-tracker'),
          ),
          IconButton(
            icon: const Icon(Icons.post_add_rounded),
            tooltip: 'Post Custom Request',
            onPressed: () => context.push('/consumer/custom-request'),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_rounded),
            tooltip: 'Apartment Directory',
            onPressed: () => context.push('/consumer/society-directory'),
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiscoveryError) {
            return Center(child: Text(state.message));
          }
          if (state is! DiscoveryLoaded) return const SizedBox.shrink();

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Search Bar with Aliases support
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _searchController,
                              hint: l10n.searchPlaceholder,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        _applyFilter();
                                      },
                                    )
                                  : null,
                              onChanged: (_) => _applyFilter(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: _emergencyOnly
                                  ? AppColors.errorLight
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.emergency_rounded,
                                color: _emergencyOnly ? AppColors.error : AppColors.textSecondaryLight,
                              ),
                              tooltip: '24/7 Emergency Services',
                              onPressed: () {
                                setState(() => _emergencyOnly = !_emergencyOnly);
                                _applyFilter(emergency: _emergencyOnly);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // "Need Help Today" Quick Launcher Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: InkWell(
                        onTap: () {
                          _searchController.text = 'maid';
                          _applyFilter(categoryId: 'maid');
                          AppNotifier.showInfo(
                            context,
                            title: 'Today\'s Available Helpers',
                            description: 'Showing instant temporary helpers in your area.',
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF0D9488)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.needHelpToday,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      l10n.needHelpTodayDesc,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Apartment & Society Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                      child: SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            _buildSocietyChip('All Societies'),
                            ...state.societies.map((s) => _buildSocietyChip(s.name)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Service Categories Horizontal Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: SizedBox(
                        height: 98,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: state.categories.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isSelected = _selectedCategory == 'all';
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedCategory = 'all');
                                  _applyFilter(categoryId: 'all');
                                },
                                child: _buildCategoryItem(
                                  'All',
                                  Icons.grid_view_rounded,
                                  isSelected,
                                ),
                              );
                            }
                            final cat = state.categories[index - 1];
                            final isSelected = _selectedCategory == cat.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = cat.id);
                                _applyFilter(categoryId: cat.id);
                              },
                              child: _buildCategoryItem(
                                cat.nameEn,
                                ServiceIconBadge.getIconForCategory(cat.id),
                                isSelected,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Section Title: Available Providers
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trusted Local Providers (${state.providers.length})',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (state.compareList.isNotEmpty)
                            TextButton(
                              onPressed: () => context.read<DiscoveryBloc>().add(DiscoveryClearCompare()),
                              child: Text('Clear Compare (${state.compareList.length})'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Provider List Cards
                  if (state.providers.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 54, color: AppColors.textTertiaryLight),
                            SizedBox(height: 12),
                            Text(
                              'No matching providers found',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text('Try broadening your search or choosing another society'),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 90.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final provider = state.providers[index];
                            final isCompared = state.compareList.any((p) => p.id == provider.id);
                            return _buildProviderCard(context, provider, isCompared);
                          },
                          childCount: state.providers.length,
                        ),
                      ),
                    ),
                ],
              ),

              // Bottom Comparison Float Bar
              if (state.compareList.length >= 2)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildComparisonBar(context, state.compareList),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSocietyChip(String label) {
    final isSelected = _selectedSociety == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedSociety = label);
          _applyFilter(society: label);
        },
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool isSelected) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.primaryContainerLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.primaryLight,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(BuildContext context, ProviderProfile provider, bool isCompared) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => context.push('/provider-details/${provider.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ServiceIconBadge(categoryId: provider.primaryCategoryId, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.businessName,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: provider.verificationStatus, isVerifiedBadge: true),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '${provider.avgRating} (${provider.totalReviews})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${provider.experienceYears} yrs exp',
                              style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                            ),
                            if (provider.isEmergencyAvailable) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '24/7',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                provider.bio,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (provider.societiesServed.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, size: 14, color: AppColors.textTertiaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Serves: ${provider.societiesServed.join(", ")}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const Text(
                        'Direct offline payment',
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Compare Toggle Button
                      IconButton(
                        icon: Icon(
                          isCompared ? Icons.check_circle_rounded : Icons.compare_arrows_rounded,
                          color: isCompared ? AppColors.secondaryLight : AppColors.textTertiaryLight,
                        ),
                        tooltip: 'Compare Provider',
                        onPressed: () {
                          context.read<DiscoveryBloc>().add(DiscoveryToggleCompareProvider(provider));
                        },
                      ),
                      // Direct Phone Call Button
                      IconButton.filledTonal(
                        icon: const Icon(Icons.call_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainerLight,
                          foregroundColor: AppColors.secondaryLight,
                        ),
                        onPressed: () {
                          PhoneLauncher.makePhoneCall(
                            context,
                            rawPhoneNumber: provider.phoneNumber,
                            recipientName: provider.businessName,
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      // Direct WhatsApp Chat Button
                      IconButton.filledTonal(
                        tooltip: 'Chat on WhatsApp',
                        icon: const Icon(Icons.chat_bubble_rounded, size: 17),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFF1EBE5D),
                        ),
                        onPressed: () {
                          PhoneLauncher.openWhatsApp(
                            context,
                            rawPhoneNumber: provider.phoneNumber,
                            recipientName: provider.businessName,
                            prefilledMessage:
                                'Hi ${provider.businessName}, I found your profile on Daily-Ease for ${provider.primaryCategoryId}. Are you available?',
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Book Button
                      FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => context.push('/book-service/${provider.id}'),
                        child: const Text('Book', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonBar(BuildContext context, List<ProviderProfile> compareList) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.secondaryLight, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows_rounded, color: AppColors.secondaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Comparing ${compareList.length} Providers',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () => _showComparisonModal(context, compareList),
            child: const Text('View Comparison', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showComparisonModal(BuildContext context, List<ProviderProfile> list) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Side-by-Side Comparison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ServiceIconBadge(categoryId: p.primaryCategoryId, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.businessName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Text(
                              p.formattedPrice,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('⭐ ${p.avgRating} (${p.totalReviews} reviews)'),
                            const SizedBox(width: 12),
                            Text('${p.experienceYears} yrs experience'),
                            const SizedBox(width: 12),
                            StatusBadge(status: p.verificationStatus, isVerifiedBadge: true),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Societies: ${p.societiesServed.join(", ")}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.call, size: 16),
                              label: const Text('Call'),
                              onPressed: () => PhoneLauncher.makePhoneCall(
                                context,
                                rawPhoneNumber: p.phoneNumber,
                                recipientName: p.businessName,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/book-service/${p.id}');
                              },
                              child: const Text('Book This Provider'),
                            ),
                          ],
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
}
