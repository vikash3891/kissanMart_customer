import 'api_service.dart';
import '../models/review.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  /// Gets all reviews for a product.
  Future<ProductReviewsResponse> getProductReviews(int productId) async {
    try {
      final response = await _apiService.get('/reviews/$productId');
      if (response['success'] == true && response['data'] != null) {
        return ProductReviewsResponse.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load reviews');
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  /// Adds a new review for a product.
  Future<ReviewModel> addReview(
      int productId, double rating, String comment, {List<String>? imagePaths}) async {
    try {
      dynamic response;
      if (imagePaths != null && imagePaths.isNotEmpty) {
        response = await _apiService.postMultipart(
          '/reviews/$productId',
          {'rating': rating.toString(), 'comment': comment},
          imagePaths: imagePaths,
          fileFieldName: 'images',
        );
      } else {
        response = await _apiService.post('/reviews/$productId', {
          'rating': rating,
          'comment': comment,
        });
      }
      if (response['success'] == true && response['data'] != null) {
        return ReviewModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to add review');
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  /// Updates an existing review.
  Future<ReviewModel> updateReview(
      int reviewId, double rating, String comment, {List<String>? imagePaths}) async {
    try {
      dynamic response;
      if (imagePaths != null && imagePaths.isNotEmpty) {
        response = await _apiService.putMultipart(
          '/reviews/$reviewId',
          {'rating': rating.toString(), 'comment': comment},
          imagePaths: imagePaths,
          fileFieldName: 'images',
        );
      } else {
        response = await _apiService.put('/reviews/$reviewId', {
          'rating': rating,
          'comment': comment,
        });
      }
      if (response['success'] == true && response['data'] != null) {
        return ReviewModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to update review');
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Deletes an existing review.
  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await _apiService.delete('/reviews/$reviewId');
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
