import 'api_banner.dart';
import 'category.dart';
import 'api_product.dart';

class HomeDataResponse {
  final List<ApiBanner> banners;
  final List<Category> categories;
  final List<ApiProduct> trendingProducts;
  final List<ApiProduct> offerProducts;

  HomeDataResponse({
    required this.banners,
    required this.categories,
    required this.trendingProducts,
    required this.offerProducts,
  });

  factory HomeDataResponse.fromJson(Map<String, dynamic> json) {
    return HomeDataResponse(
      banners: (json['banners'] as List? ?? [])
          .map((e) => ApiBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingProducts: (json['trendingProducts'] as List? ?? [])
          .map((e) => ApiProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      offerProducts: (json['offerProducts'] as List? ?? [])
          .map((e) => ApiProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
