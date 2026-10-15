import 'package:equatable/equatable.dart';

class ProviderProfile extends Equatable {
  final String id;
  final String businessName;
  final String phoneNumber;
  final String bio;
  final String primaryCategoryId;
  final int experienceYears;
  final List<String> serviceAreas;
  final List<String> societiesServed;
  final List<String> languagesSpoken;
  final bool isActive;
  final bool isEmergencyAvailable;
  final String verificationStatus; // 'unverified', 'verified', 'pending'
  final double avgRating;
  final int totalReviews;
  final String pricingModel; // 'hourly', 'daily', 'monthly', 'per_visit', 'per_liter'
  final double basePrice;
  final String workingHours;
  final int maxDailyJobs;
  final List<String> leaveDates;
  final List<String> portfolioPhotos;
  final Map<String, dynamic> categoryCustomData;
  final int profileViews;
  final int callsInitiated;
  final int bookingRequestsCount;
  final bool isTemporaryJobModeActive;

  const ProviderProfile({
    required this.id,
    required this.businessName,
    required this.phoneNumber,
    required this.bio,
    required this.primaryCategoryId,
    required this.experienceYears,
    required this.serviceAreas,
    this.societiesServed = const [],
    this.languagesSpoken = const ['en', 'hi'],
    this.isActive = true,
    this.isEmergencyAvailable = false,
    this.verificationStatus = 'unverified',
    this.avgRating = 0.0,
    this.totalReviews = 0,
    required this.pricingModel,
    required this.basePrice,
    this.workingHours = '08:00 AM - 08:00 PM',
    this.maxDailyJobs = 5,
    this.leaveDates = const [],
    this.portfolioPhotos = const [],
    this.categoryCustomData = const {},
    this.profileViews = 0,
    this.callsInitiated = 0,
    this.bookingRequestsCount = 0,
    this.isTemporaryJobModeActive = true,
  });

  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  String get formattedPrice {
    final currency = '₹${basePrice.toStringAsFixed(0)}';
    switch (pricingModel.toLowerCase()) {
      case 'hourly':
        return '$currency / hr';
      case 'daily':
        return '$currency / day';
      case 'monthly':
        return '$currency / month';
      case 'per_liter':
        return '$currency / liter';
      case 'per_visit':
      default:
        return '$currency / visit';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_name': businessName,
        'phone_number': phoneNumber,
        'bio': bio,
        'primary_category_id': primaryCategoryId,
        'experience_years': experienceYears,
        'service_areas': serviceAreas,
        'societies_served': societiesServed,
        'languages_spoken': languagesSpoken,
        'is_active': isActive,
        'is_emergency_available': isEmergencyAvailable,
        'verification_status': verificationStatus,
        'avg_rating': avgRating,
        'total_reviews': totalReviews,
        'pricing_model': pricingModel,
        'base_price': basePrice,
        'working_hours': workingHours,
        'max_daily_jobs': maxDailyJobs,
        'leave_dates': leaveDates,
        'portfolio_photos': portfolioPhotos,
        'category_custom_data': categoryCustomData,
        'profile_views': profileViews,
        'calls_initiated': callsInitiated,
        'booking_requests_count': bookingRequestsCount,
        'is_temporary_job_mode_active': isTemporaryJobModeActive,
      };

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      businessName: json['business_name'] as String? ?? 'Service Provider',
      phoneNumber: json['phone_number'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      primaryCategoryId: json['primary_category_id'] as String? ?? 'general',
      experienceYears: json['experience_years'] as int? ?? 1,
      serviceAreas: List<String>.from(json['service_areas'] ?? []),
      societiesServed: List<String>.from(json['societies_served'] ?? []),
      languagesSpoken: List<String>.from(json['languages_spoken'] ?? ['en']),
      isActive: json['is_active'] as bool? ?? true,
      isEmergencyAvailable: json['is_emergency_available'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      pricingModel: json['pricing_model'] as String? ?? 'per_visit',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 300.0,
      workingHours: json['working_hours'] as String? ?? '08:00 AM - 08:00 PM',
      maxDailyJobs: json['max_daily_jobs'] as int? ?? 5,
      leaveDates: List<String>.from(json['leave_dates'] ?? []),
      portfolioPhotos: List<String>.from(json['portfolio_photos'] ?? []),
      categoryCustomData: json['category_custom_data'] as Map<String, dynamic>? ?? {},
      profileViews: json['profile_views'] as int? ?? 0,
      callsInitiated: json['calls_initiated'] as int? ?? 0,
      bookingRequestsCount: json['booking_requests_count'] as int? ?? 0,
      isTemporaryJobModeActive: json['is_temporary_job_mode_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessName,
        phoneNumber,
        primaryCategoryId,
        experienceYears,
        verificationStatus,
        avgRating,
        totalReviews,
        basePrice,
        isActive,
      ];
}
