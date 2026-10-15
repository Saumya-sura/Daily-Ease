import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../discovery/data/discovery_repository.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/domain/review_model.dart';
import '../domain/provider_profile.dart';

class ProviderDetailScreen extends StatefulWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  ProviderProfile? _provider;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    final p = await sl<DiscoveryRepository>().getProviderById(widget.providerId);
    final r = await sl<ReviewRepository>().getReviewsForProvider(widget.providerId);
    if (mounted) {
      setState(() {
        _provider = p;
        _reviews = r;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provider Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 54, color: AppColors.textTertiaryLight),
              const SizedBox(height: 12),
              const Text('Provider not found or listing paused', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Discovery'),
              ),
            ],
          ),
        ),
      );
    }

    final provider = _provider!;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.businessName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report Provider',
            onPressed: () => _showReportDialog(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Profile Card
            Row(
              children: [
                ServiceIconBadge(categoryId: provider.primaryCategoryId, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.businessName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(status: provider.verificationStatus, isVerifiedBadge: true),
                          const SizedBox(width: 8),
                          if (provider.isEmergencyAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '24/7 Emergency',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key Metrics Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('Rating', '⭐ ${provider.avgRating}'),
                  _buildMetric('Reviews', '${provider.totalReviews}'),
                  _buildMetric('Experience', '${provider.experienceYears} yrs'),
                  _buildMetric('Daily Cap', '${provider.maxDailyJobs} jobs'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bio
            if (provider.bio.isNotEmpty) ...[
              Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(provider.bio, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],

            // Category Dynamic Attributes
            if (provider.categoryCustomData.isNotEmpty) ...[
              Text(
                'Services Offered',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categoryCustomData.entries.expand((entry) {
                  if (entry.value is List) {
                    return (entry.value as List).map(
                      (item) => Chip(
                        label: Text(item.toString()),
                        backgroundColor: AppColors.primaryContainerLight,
                      ),
                    );
                  }
                  return [
                    Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      backgroundColor: AppColors.primaryContainerLight,
                    ),
                  ];
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Working Hours & Areas
            Text('Working Hours & Localities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Text(provider.workingHours, style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (provider.societiesServed.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.apartment_rounded, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Societies: ${provider.societiesServed.join(", ")}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Pricing Notice Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Rate: ${provider.formattedPrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Prices are informational and settled directly between you and the provider via Cash or UPI.',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Verified Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer Reviews (${_reviews.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No reviews yet. Book and complete a service to leave a verified review!'),
              )
            else
              ..._reviews.map(
                (r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.consumerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                                Text('${r.rating}'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Verified Completed Booking',
                              style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(r.reviewText, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Direct Phone Call Action
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                PhoneLauncher.makePhoneCall(
                  context,
                  rawPhoneNumber: provider.phoneNumber,
                  recipientName: provider.businessName,
                );
              },
              child: const Icon(Icons.call_rounded),
            ),
            const SizedBox(width: 8),
            // WhatsApp Direct Action
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
            // Book Service Action
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('Book Service'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => context.push('/book-service/${provider.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
      ],
    );
  }

  void _showReportDialog(BuildContext context, ProviderProfile provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report / Moderate Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report "${provider.businessName}" for inappropriate behavior or fake details:'),
            const SizedBox(height: 12),
            const Text('• Fake profile or contact', style: TextStyle(fontSize: 12)),
            const Text('• Harassment or inappropriate conduct', style: TextStyle(fontSize: 12)),
            const Text('• Persistent no-show', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted for moderation review.')),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
