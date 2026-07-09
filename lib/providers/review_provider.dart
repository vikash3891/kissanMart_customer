import 'package:flutter/material.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';
import '../services/api_exception.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();

  bool _loading = false;
  bool _submitting = false;
  String? _error;
  ProductReviewsResponse? _reviewsResponse;

  String _selectedSort =
      'Most Recent'; // 'Most Recent', 'Highest Rating', 'Lowest Rating', 'Most Helpful'
  String _selectedFilter =
      'All Stars'; // 'All Stars', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star', 'With Photos'

  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;
  ProductReviewsResponse? get reviewsResponse => _reviewsResponse;
  String get selectedSort => _selectedSort;
  String get selectedFilter => _selectedFilter;

  List<ReviewModel> get filteredReviews {
    if (_reviewsResponse == null) return [];

    List<ReviewModel> list = List.from(_reviewsResponse!.reviews);

    // Apply Filter
    if (_selectedFilter != 'All Stars') {
      if (_selectedFilter == 'With Photos') {
        list = list.where((r) => r.photoUrls.isNotEmpty).toList();
      } else {
        final star = int.tryParse(_selectedFilter.split(' ')[0]);
        if (star != null) {
          list = list.where((r) => r.rating.round() == star).toList();
        }
      }
    }

    // Apply Sort
    if (_selectedSort == 'Most Recent') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Highest Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedSort == 'Lowest Rating') {
      list.sort((a, b) => a.rating.compareTo(b.rating));
    } else if (_selectedSort == 'Most Helpful') {
      list.sort((a, b) => b.helpfulVotes.compareTo(a.helpfulVotes));
    }

    return list;
  }

  void setSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void upvoteReview(int reviewId) {
    if (_reviewsResponse == null) return;
    final idx = _reviewsResponse!.reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      _reviewsResponse!.reviews[idx].helpfulVotes += 1;
      notifyListeners();
    }
  }

  /// Fetches reviews list and average ratings for a product.
  Future<void> fetchReviews(int productId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _reviewsResponse = await _repository.getProductReviews(productId);
      _error = null;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Adds a review to a product.
  Future<bool> addReview(int productId, double rating, String comment) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.addReview(productId, rating, comment);
      _error = null;
      await fetchReviews(productId); // Refresh list
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Updates a review.
  Future<bool> updateReview(
      int reviewId, double rating, String comment, int productId) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateReview(reviewId, rating, comment);
      _error = null;
      await fetchReviews(productId); // Refresh list
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Deletes a review.
  Future<bool> deleteReview(int reviewId, int productId) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteReview(reviewId);
      _error = null;
      await fetchReviews(productId); // Refresh list
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
