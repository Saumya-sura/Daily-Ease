import 'package:flutter_test/flutter_test.dart';
import 'package:daily_ease/features/provider/domain/provider_profile.dart';

void main() {
  group('ProviderProfile Domain Model Tests', () {
    test('ProviderProfile formats pricing correctly across models', () {
      const hourlyProvider = ProviderProfile(
        id: 'p_1',
        businessName: 'Electric Pro',
        phoneNumber: '+91 99999 88888',
        bio: 'Expert electrician',
        primaryCategoryId: 'electrician',
        experienceYears: 4,
        serviceAreas: ['Powai'],
        pricingModel: 'hourly',
        basePrice: 200.0,
      );
      expect(hourlyProvider.formattedPrice, '₹200 / hr');

      const monthlyProvider = ProviderProfile(
        id: 'p_2',
        businessName: 'Sunita Maid',
        phoneNumber: '+91 99999 77777',
        bio: 'Expert helper',
        primaryCategoryId: 'maid',
        experienceYears: 8,
        serviceAreas: ['Powai'],
        pricingModel: 'monthly',
        basePrice: 2500.0,
      );
      expect(monthlyProvider.formattedPrice, '₹2500 / month');

      const perLiterProvider = ProviderProfile(
        id: 'p_3',
        businessName: 'Fresh Dairy Farm',
        phoneNumber: '+91 99999 66666',
        bio: 'Fresh milk',
        primaryCategoryId: 'milkman',
        experienceYears: 10,
        serviceAreas: ['Powai'],
        pricingModel: 'per_liter',
        basePrice: 65.0,
      );
      expect(perLiterProvider.formattedPrice, '₹65 / liter');

      const perVisitProvider = ProviderProfile(
        id: 'p_4',
        businessName: 'Quick Plumber',
        phoneNumber: '+91 99999 55555',
        bio: 'Pipe fix',
        primaryCategoryId: 'plumber',
        experienceYears: 3,
        serviceAreas: ['Powai'],
        pricingModel: 'per_visit',
        basePrice: 300.0,
      );
      expect(perVisitProvider.formattedPrice, '₹300 / visit');
    });

    test('isVerified correctly checks verification status', () {
      const unverified = ProviderProfile(
        id: 'p_1',
        businessName: 'Self Listed Worker',
        phoneNumber: '+91 99999 88888',
        bio: 'New provider',
        primaryCategoryId: 'carpenter',
        experienceYears: 1,
        serviceAreas: ['Powai'],
        pricingModel: 'per_visit',
        basePrice: 400.0,
        verificationStatus: 'unverified',
      );
      expect(unverified.isVerified, isFalse);

      const verified = ProviderProfile(
        id: 'p_2',
        businessName: 'Verified Master Worker',
        phoneNumber: '+91 99999 88888',
        bio: 'Vetted provider',
        primaryCategoryId: 'carpenter',
        experienceYears: 5,
        serviceAreas: ['Powai'],
        pricingModel: 'per_visit',
        basePrice: 400.0,
        verificationStatus: 'verified',
      );
      expect(verified.isVerified, isTrue);
    });

    test('ProviderProfile round-trips through JSON accurately', () {
      const profile = ProviderProfile(
        id: 'p_full_test',
        businessName: 'A-1 Care',
        phoneNumber: '+91 98765 43210',
        bio: 'Top-rated household assistance',
        primaryCategoryId: 'maid',
        experienceYears: 9,
        serviceAreas: ['Powai', 'Vikhroli'],
        societiesServed: ['Gokuldham Society', 'Hiranandani Gardens'],
        languagesSpoken: ['en', 'hi', 'mr'],
        isActive: true,
        isEmergencyAvailable: false,
        verificationStatus: 'verified',
        avgRating: 4.85,
        totalReviews: 64,
        pricingModel: 'monthly',
        basePrice: 2800.0,
        workingHours: '07:00 AM - 01:00 PM',
        maxDailyJobs: 5,
        leaveDates: ['2026-11-10', '2026-11-11'],
        portfolioPhotos: ['https://example.com/photo1.jpg'],
        profileViews: 120,
        callsInitiated: 25,
        bookingRequestsCount: 14,
        isTemporaryJobModeActive: true,
      );

      final json = profile.toJson();
      final fromJson = ProviderProfile.fromJson(json);

      expect(fromJson.id, 'p_full_test');
      expect(fromJson.businessName, 'A-1 Care');
      expect(fromJson.experienceYears, 9);
      expect(fromJson.serviceAreas, contains('Powai'));
      expect(fromJson.societiesServed, contains('Gokuldham Society'));
      expect(fromJson.avgRating, 4.85);
      expect(fromJson.totalReviews, 64);
      expect(fromJson.basePrice, 2800.0);
      expect(fromJson.isTemporaryJobModeActive, isTrue);
      expect(fromJson.leaveDates, contains('2026-11-10'));
    });
  });
}
