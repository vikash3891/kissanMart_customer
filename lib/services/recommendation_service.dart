import '../api_models/api_product.dart';
import 'product_service.dart';

/// Service responsible for fetching recommended products.
class RecommendationService {
  final ProductService _productService = ProductService();

  Future<List<ApiProduct>> getTrending() async {
    final result =
        await _productService.getProducts(sort: 'popularity', limit: 10);
    return result.products;
  }

  Future<List<ApiProduct>> getRecommended() async {
    final result = await _productService.getProducts(sort: 'newest', limit: 10);
    return result.products;
  }

  Future<List<ApiProduct>> getPopular() async {
    final result =
        await _productService.getProducts(sort: 'discount', limit: 10);
    return result.products;
  }

  Future<List<ApiProduct>> getSeasonal() async {
    final result = await _productService.getProducts(limit: 10);
    return result.products;
  }
}
