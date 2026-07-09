import '../models/review.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _reviewService = ReviewService();

  Future<ProductReviewsResponse> getProductReviews(int productId) {
    return _reviewService.getProductReviews(productId);
  }

  Future<ReviewModel> addReview(int productId, double rating, String comment) {
    return _reviewService.addReview(productId, rating, comment);
  }

  Future<ReviewModel> updateReview(
      int reviewId, double rating, String comment) {
    return _reviewService.updateReview(reviewId, rating, comment);
  }

  Future<void> deleteReview(int reviewId) {
    return _reviewService.deleteReview(reviewId);
  }
}
