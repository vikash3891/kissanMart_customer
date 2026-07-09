import '../api_models/api_product.dart';
import 'api_service.dart';

/// Service layer for product-related API calls.
///
/// Endpoint: GET /products
class ProductService {
  final ApiService _apiService = ApiService();

  /// Fetches a paginated, filterable product list.
  Future<PaginatedProducts> getProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) query['search'] = search;
      if (categoryId != null) query['category_id'] = categoryId.toString();
      if (minPrice != null) query['minPrice'] = minPrice.toString();
      if (maxPrice != null) query['maxPrice'] = maxPrice.toString();
      if (sort != null && sort.isNotEmpty) query['sort'] = sort;

      final uri = Uri(path: '/products', queryParameters: query);
      final response = await _apiService.get(uri.toString());

      final payload = response['data'];
      final List productsList = payload['products'] as List<dynamic>;
      final products = productsList.map((e) => ApiProduct.fromJson(e)).toList();
      final totalPages = payload['totalPages'] ?? 1;
      final currentPage = payload['currentPage'] ?? 1;
      final totalProducts = payload['totalProducts'] ?? products.length;

      return PaginatedProducts(
        products: products,
        totalPages: totalPages,
        currentPage: currentPage,
        totalProducts: totalProducts,
      );
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Fetches a single product by ID.
  Future<ApiProduct> getSingleProduct(int productId) async {
    try {
      final response = await _apiService.get('/products/$productId');
      return ApiProduct.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  /// Compatibility shim — returns all products without filters.
  Future<List<ApiProduct>> getAllProducts() async {
    final paginated = await getProducts();
    return paginated.products;
  }
}
