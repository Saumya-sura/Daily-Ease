import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/service_categories_catalog.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../discovery/data/discovery_repository.dart';
import '../../discovery/domain/service_category.dart';
import '../../provider/domain/provider_profile.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategoryId = 'maid';
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _societyController = TextEditingController();
  int _experience = 3;
  String _billingModel = 'monthly';
  final Map<String, dynamic> _dynamicAnswers = {};

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _societyController.dispose();
    super.dispose();
  }

  ServiceCategory get _currentCategory =>
      ServiceCategoriesCatalog.defaultCategories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => ServiceCategoriesCatalog.defaultCategories.first,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = _currentCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Service Provider'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Select Your Service Category',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Horizontal Category Picker
              SizedBox(
                height: 95,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ServiceCategoriesCatalog.defaultCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = ServiceCategoriesCatalog.defaultCategories[index];
                    final isSelected = cat.id == _selectedCategoryId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                          _billingModel = cat.supportedBillingModels.first;
                          _dynamicAnswers.clear();
                        });
                      },
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight.withValues(alpha: 0.12)
                              : theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ServiceIconBadge(categoryId: cat.id, size: 36),
                            const SizedBox(height: 6),
                            Text(
                              cat.nameEn,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primaryLight : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Text(
                '2. Basic Details',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Business / Full Name',
                hint: 'e.g. Ramesh Electricals, Sunita Tai Household Help',
                controller: _businessNameController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Direct Phone Calling Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                hint: '+919876543210',
                validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required for customers to call' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'About Your Experience & Work',
                controller: _bioController,
                maxLines: 2,
                hint: 'Tell customers about your skills, punctuality, and experience...',
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Experience (Years)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _experience,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                          items: List.generate(25, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} years'))),
                          onChanged: (val) => setState(() => _experience = val ?? 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billing Model', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _billingModel,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                          items: category.supportedBillingModels
                              .map((m) => DropdownMenuItem(value: m, child: Text(m.replaceAll('_', ' '))))
                              .toList(),
                          onChanged: (val) => setState(() => _billingModel = val ?? 'per_visit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Base Rate / Estimated Price (₹)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.currency_rupee),
                hint: 'e.g. 350',
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your rate' : null,
              ),
              const SizedBox(height: 24),

              // Dynamic Category-Specific Attributes
              if (category.dynamicFields.isNotEmpty) ...[
                Text(
                  '3. ${category.nameEn} Specializations',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...category.dynamicFields.map((field) => _buildDynamicField(field)),
                const SizedBox(height: 24),
              ],

              Text(
                '4. Service Area & Societies',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Neighborhoods Served (comma-separated)',
                controller: _areaController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                hint: 'e.g. Powai, Chandivali, Kothrud',
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Apartment / Society Name (Optional)',
                controller: _societyController,
                prefixIcon: const Icon(Icons.apartment_outlined),
                hint: 'e.g. Gokuldham Co-op Housing Society',
              ),
              const SizedBox(height: 28),

              // Instant Self-Serve Listing Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.info, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Instant Activation: Your listing goes live immediately without waiting for admin approval. You can upload ID verification later.',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Publish Listing Immediately',
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final areas = _areaController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    final societies = _societyController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final newProvider = ProviderProfile(
                      id: 'prov_${DateTime.now().millisecondsSinceEpoch}',
                      businessName: _businessNameController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      bio: _bioController.text.trim(),
                      primaryCategoryId: _selectedCategoryId,
                      experienceYears: _experience,
                      serviceAreas: areas.isNotEmpty ? areas : ['Local Area'],
                      societiesServed: societies,
                      pricingModel: _billingModel,
                      basePrice: double.tryParse(_priceController.text) ?? 300.0,
                      categoryCustomData: _dynamicAnswers,
                      isActive: true,
                      verificationStatus: 'unverified',
                    );

                    await sl<DiscoveryRepository>().registerProvider(newProvider);

                    if (context.mounted) {
                      AppNotifier.showSuccess(
                        context,
                        title: 'Listing Activated!',
                        description: 'Your services are now live and searchable in your area.',
                      );
                      context.go('/provider/dashboard');
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicField(CategoryFormField field) {
    if (field.fieldType == 'multiselect') {
      final selectedOptions = List<String>.from(_dynamicAnswers[field.key] ?? []);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: field.options.map((option) {
                final isSelected = selectedOptions.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                      _dynamicAnswers[field.key] = selectedOptions;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _dynamicAnswers[field.key] ?? field.options.first,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
              items: field.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (val) {
                setState(() {
                  _dynamicAnswers[field.key] = val;
                });
              },
            ),
          ],
        ),
      );
    }
  }
}
