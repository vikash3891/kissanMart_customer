import '../api_models/category.dart';
import '../services/category_service.dart';
import '../api_models/api_product.dart';

class CategoryRepository {
  final CategoryService _service = CategoryService();

  // Cache store
  static List<Category>? _categoriesCache;

  Future<List<Category>> getAllCategories() async {
    final result = await _service.getAllCategories();
    _categoriesCache = result;
    return result;
  }

  List<Category>? getCachedCategories() {
    return _categoriesCache;
  }

  Future<Category> getSingleCategory(int id) {
    return _service.getSingleCategory(id);
  }

  Future<List<Category>> searchCategory(String keyword) {
    return _service.searchCategory(keyword);
  }

  Future<List<ApiProduct>> getCategoryProducts(int categoryId) {
    return _service.getCategoryProducts(categoryId);
  }
}
