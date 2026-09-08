import '../models/review.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _reviewService = ReviewService();

  Future<ProductReviewsResponse> getProductReviews(int productId) {
    return _reviewService.getProductReviews(productId);
  }

  Future<ReviewModel> addReview(int productId, double rating, String comment, {List<String>? imagePaths}) {
    return _reviewService.addReview(productId, rating, comment, imagePaths: imagePaths);
  }

  Future<ReviewModel> updateReview(
      int reviewId, double rating, String comment, {List<String>? imagePaths}) {
    return _reviewService.updateReview(reviewId, rating, comment, imagePaths: imagePaths);
  }

  Future<void> deleteReview(int reviewId) {
    return _reviewService.deleteReview(reviewId);
  }
}
