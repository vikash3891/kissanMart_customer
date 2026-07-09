import '../api_models/category.dart';
import 'api_service.dart';
import '../api_models/api_product.dart';

class CategoryService {
  final ApiService _api = ApiService();

  Future<List<ApiProduct>> getCategoryProducts(int categoryId) async {
    final response = await _api.get("/categories/$categoryId/products");
    final List list = response["data"] ?? [];
    return list.map((e) => ApiProduct.fromJson(e)).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final response = await _api.get("/categories");
    final List list = response["data"] ?? [];
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> getSingleCategory(int id) async {
    final response = await _api.get("/categories/$id");
    return Category.fromJson(response["data"]);
  }

  Future<List<Category>> searchCategory(String keyword) async {
    final response = await _api.get("/categories/search?keyword=$keyword");
    final List list = response["data"] ?? [];
    return list.map((e) => Category.fromJson(e)).toList();
  }
}
