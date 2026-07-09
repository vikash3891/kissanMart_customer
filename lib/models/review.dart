class ReviewModel {
  final int id;
  final int userId;
  final int productId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String phone;
  int helpfulVotes;
  final List<String> photoUrls;
  final bool isVerified;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.phone,
    this.helpfulVotes = 0,
    this.photoUrls = const [],
    this.isVerified = true,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Generate some mock photos & helpful votes for realistic presentation
    final idVal = json['id'] is int
        ? json['id'] as int
        : int.parse(json['id'].toString());
    final List<String> mockPhotos = [];
    if (idVal % 3 == 0) {
      mockPhotos.add(
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&q=80&w=200');
    }
    if (idVal % 5 == 0) {
      mockPhotos.add(
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=200');
    }

    return ReviewModel(
      id: idVal,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.parse(json['rating'].toString()),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      phone: json['phone'] ?? '',
      helpfulVotes: (idVal * 7) % 15,
      photoUrls: mockPhotos,
      isVerified: idVal % 7 != 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'phone': phone,
    };
  }
}

class ProductReviewsResponse {
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;
  final Map<int, int> starCounts; // Histogram values e.g. {5: 12, 4: 5, ...}

  ProductReviewsResponse({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
    required this.starCounts,
  });

  factory ProductReviewsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['reviews'] as List? ?? [];
    final parsedReviews = list.map((e) => ReviewModel.fromJson(e)).toList();

    final starMap = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final rev in parsedReviews) {
      final key = rev.rating.round();
      if (starMap.containsKey(key)) {
        starMap[key] = starMap[key]! + 1;
      }
    }

    return ProductReviewsResponse(
      averageRating: json['averageRating'] != null
          ? double.parse(json['averageRating'].toString())
          : 0.0,
      totalReviews: json['totalReviews'] is int
          ? json['totalReviews']
          : int.parse(json['totalReviews'].toString()),
      reviews: parsedReviews,
      starCounts: starMap,
    );
  }
}
