import 'package:flutter/material.dart';

import '../api_models/category.dart';
import '../models/product.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadCategories() async {
    final cached = _repository.getCachedCategories();
    if (cached != null) {
      _categories = cached;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _categories = await _repository.getAllCategories();
      _error = null;
    } catch (e) {
      if (_categories.isEmpty) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> loadCategoryProducts(int categoryId) async {
    final apiProducts = await _repository.getCategoryProducts(categoryId);

    return apiProducts.map((p) {
      return Product(
        id: p.id,
        store: p.brand,
        name: p.name,
        category: p.category.name,
        subCategory: "",
        type: p.category.name,
        image: p.imageUrl ?? "",
        unit: p.unit,
        price: p.discountPrice,
        mrp: p.price,
        rating: 4.5,
        reviews: 0,
        tag: p.stockStatus,
        origin: "",
        farmer: p.brand,
        process: "",
        organic: true,
      );
    }).toList();
  }
}
