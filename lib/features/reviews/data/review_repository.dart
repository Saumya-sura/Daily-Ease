import '../../../core/utils/app_logger.dart';
import '../domain/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviewsForProvider(String providerId);
  Future<ReviewModel> submitReview(ReviewModel review);
  Future<void> submitReport(UserReport report);
}

class ReviewRepositoryImpl implements ReviewRepository {
  final List<ReviewModel> _reviews = [];
  final List<UserReport> _reports = [];

  @override
  Future<List<ReviewModel>> getReviewsForProvider(String providerId) async {
    AppLogger.debug('ReviewRepo', 'Fetching reviews from store', {'providerId': providerId});
    return _reviews.where((r) => r.providerId == providerId).toList();
  }

  @override
  Future<ReviewModel> submitReview(ReviewModel review) async {
    AppLogger.info('ReviewRepo', 'Submitting live customer review', {
      'providerId': review.providerId,
      'rating': review.rating,
      'isVerified': review.isVerifiedBooking,
    });

    _reviews.insert(0, review);
    return review;
  }

  @override
  Future<void> submitReport(UserReport report) async {
    AppLogger.warning('ReviewRepo', 'Abuse report submitted', {
      'reportedUserId': report.reportedUserId,
      'reason': report.reason,
    });
    _reports.add(report);
  }
}
