import '../api_models/api_product.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _service = ProductService();

  // Cache stores
  static final Map<String, PaginatedProducts> _productsCache = {};
  static final Map<int, ApiProduct> _singleProductCache = {};

  Future<PaginatedProducts> getProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _service.getProducts(
      search: search,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sort: sort,
      page: page,
      limit: limit,
    );

    final key = _cacheKey(
      search: search,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sort: sort,
      page: page,
      limit: limit,
    );
    _productsCache[key] = result;
    return result;
  }

  PaginatedProducts? getCachedProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 10,
  }) {
    final key = _cacheKey(
      search: search,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sort: sort,
      page: page,
      limit: limit,
    );
    return _productsCache[key];
  }

  Future<ApiProduct> getSingleProduct(int id) async {
    final result = await _service.getSingleProduct(id);
    _singleProductCache[id] = result;
    return result;
  }

  ApiProduct? getCachedSingleProduct(int id) {
    return _singleProductCache[id];
  }

  Future<List<ApiProduct>> getAllProducts() async {
    final paginated = await _service.getProducts();
    return paginated.products;
  }

  String _cacheKey({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 10,
  }) {
    return 'q=$search&cat=$categoryId&min=$minPrice&max=$maxPrice&sort=$sort&page=$page&limit=$limit';
  }
}
