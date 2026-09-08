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
    final idVal = json['id'] is int
        ? json['id'] as int
        : int.parse(json['id'].toString());

    Set<String> photoSet = {};
    for (final key in [
      'photo_urls',
      'photoUrls',
      'images',
      'photos',
    ]) {
      if (json[key] is List) {
        for (final item in (json[key] as List)) {
          final s = item.toString().trim();
          if (s.isNotEmpty && s != 'null') photoSet.add(s);
        }
      }
    }
    for (final key in [
      'review_image',
      'reviewImage',
      'photo',
      'photo_url',
      'photoUrl',
      'image_url',
      'imageUrl',
      'image'
    ]) {
      if (json[key] != null) {
        final s = json[key].toString().trim();
        if (s.isNotEmpty && s != 'null') photoSet.add(s);
      }
    }
    List<String> parsedPhotos = photoSet.toList();

    // Never display the dummy placeholder if any valid image URL exists.
    // Only apply fallback mock photos to legacy seed data that explicitly lacks all photo fields.
    final bool hasExplicitPhotoField = json.containsKey('photo_urls') ||
        json.containsKey('photoUrls') ||
        json.containsKey('images') ||
        json.containsKey('review_image') ||
        json.containsKey('reviewImage') ||
        json.containsKey('photo') ||
        json.containsKey('photo_url') ||
        json.containsKey('image_url') ||
        json.containsKey('image');
    if (parsedPhotos.isEmpty && !hasExplicitPhotoField) {
      if (idVal % 3 == 0) {
        parsedPhotos.add(
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&q=80&w=200');
      }
      if (idVal % 5 == 0) {
        parsedPhotos.add(
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=200');
      }
    }

    return ReviewModel(
      id: idVal,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse((json['user_id'] ?? 0).toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse((json['product_id'] ?? 0).toString()),
      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating'].toString()) ?? 5.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      phone: json['phone'] ?? '',
      helpfulVotes: json['helpful_votes'] is int
          ? json['helpful_votes']
          : ((idVal * 7) % 15),
      photoUrls: parsedPhotos,
      isVerified: json['is_verified'] ?? (idVal % 7 != 0),
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
      'photo_urls': photoUrls,
      'helpful_votes': helpfulVotes,
      'is_verified': isVerified,
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
