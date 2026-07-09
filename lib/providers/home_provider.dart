import 'package:flutter/material.dart';

import '../api_models/api_banner.dart';
import '../api_models/api_product.dart';
import '../api_models/category.dart';
import '../api_models/home_data_response.dart';
import '../models/product.dart';
import '../repositories/home_repository.dart';
import '../services/api_exception.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  bool _loading = false;
  HomeDataResponse? _homeData;
  String? _error;

  List<ApiBanner> _banners = [];
  List<Category> _categories = [];
  List<Product> _trendingProducts = [];
  List<Product> _offerProducts = [];

  bool get loading => _loading;
  bool get isLoading => _loading;
  String? get error => _error;

  List<ApiBanner> get banners => _banners;
  List<Category> get categories => _categories;
  List<Product> get trendingProducts => _trendingProducts;
  List<Product> get offerProducts => _offerProducts;

  Future<void> loadHomeData() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _homeData = await _repository.getHomeData();
      if (_homeData != null) {
        _banners = _homeData!.banners;
        _categories = _homeData!.categories;
        _trendingProducts =
            _homeData!.trendingProducts.map((e) => _mapApiProduct(e)).toList();
        _offerProducts =
            _homeData!.offerProducts.map((e) => _mapApiProduct(e)).toList();
      }
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

  Product _mapApiProduct(ApiProduct p) {
    return Product(
      id: p.id,
      store: p.brand,
      name: p.name,
      category: p.category.name,
      subCategory: '',
      type: p.category.name,
      image: p.imageUrl ?? '',
      unit: p.unit,
      price: p.discountPrice,
      mrp: p.price,
      rating: 4.5,
      reviews: 0,
      tag: p.stockStatus,
      origin: '',
      farmer: p.brand,
      process: '',
      organic: true,
      description: p.description,
      stock: p.stock,
      isAvailable: p.isAvailable,
    );
  }
}
