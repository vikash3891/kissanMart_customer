import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';

import '../core/storage/hive_storage_service.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_repository.dart';
import '../services/product_analytics_service.dart';

/// Manages the product catalogue, filters, sorting, search history, favorites,
/// recently viewed, and voice search integration.
///
/// Architecture:  UI → ProductProvider → ProductRepository → ProductService → ApiService
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Product lists & details
  List<Product> _products = [];
  Product? _selectedProduct;
  List<Product> _relatedProducts = [];

  // Favorites, Recents & Search History
  List<Product> _favorites = [];
  List<Product> _recentProducts = [];
  List<Product> _customersAlsoBought = [];
  List<String> _searchHistory = [];

  // Filter & State Variables
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isListening = false;
  String _searchQuery = '';
  int? _categoryId;
  double? _minPrice;
  double? _maxPrice;
  String? _sort;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  List<Product> get relatedProducts => _relatedProducts;
  List<Product> get favorites => _favorites;
  List<Product> get recentProducts => _recentProducts;
  List<Product> get customersAlsoBought => _customersAlsoBought;
  List<String> get searchHistory => _searchHistory;

  String get search => _searchQuery;
  String get searchQuery => _searchQuery;
  int? get categoryId => _categoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get sort => _sort;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isListening => _isListening;
  String? get error => _error;

  ProductProvider() {
    _initLocalData();
  }

  // ─── Local Data Persistence (Favorites, Recents, Search History) ─────────

  Future<void> _initLocalData() async {
    try {
      // 1. Favorites
      final favsList = HiveStorageService.read(
          HiveStorageService.wishlistBox, 'kk_favorites');
      if (favsList is List) {
        _favorites = favsList
            .map((e) => _productFromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      // 2. Recently Viewed
      final recentsList = HiveStorageService.read(
          HiveStorageService.recentlyViewedBox, 'kk_recents');
      if (recentsList is List) {
        _recentProducts = recentsList
            .map((e) => _productFromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      // 3. Search History
      final history = HiveStorageService.read(
          HiveStorageService.searchHistoryBox, 'kk_search_history');
      if (history is List) {
        _searchHistory = history.map((e) => e.toString()).toList();
      }

      notifyListeners();
    } catch (_) {
      // Silently ignore loading errors
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final list = _favorites.map((e) => _productToJson(e)).toList();
      await HiveStorageService.write(
          HiveStorageService.wishlistBox, 'kk_favorites', list);
    } catch (_) {}
  }

  Future<void> _saveRecents() async {
    try {
      final list = _recentProducts.map((e) => _productToJson(e)).toList();
      await HiveStorageService.write(
          HiveStorageService.recentlyViewedBox, 'kk_recents', list);
    } catch (_) {}
  }

  Future<void> _saveSearchHistory() async {
    try {
      await HiveStorageService.write(HiveStorageService.searchHistoryBox,
          'kk_search_history', _searchHistory);
    } catch (_) {}
  }

  // ─── Favorites (Feature 1) ────────────────────────────────────────────────

  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere((e) => e.id == product.id);
    final bool isFavNow;
    if (index >= 0) {
      _favorites.removeAt(index);
      isFavNow = false;
    } else {
      _favorites.insert(0, product);
      isFavNow = true;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Analytics
    ProductAnalyticsService.instance
        .favoriteProduct(product.id, product.name, isFavNow);

    notifyListeners();
    _saveFavorites();
  }

  bool isFavorite(int productId) {
    return _favorites.any((e) => e.id == productId);
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
    _saveFavorites();
  }

  // ─── Recently Viewed (Feature 3) ──────────────────────────────────────────

  void addRecentlyViewed(Product product) {
    _recentProducts.removeWhere((e) => e.id == product.id);
    _recentProducts.insert(0, product);
    if (_recentProducts.length > 20) {
      _recentProducts = _recentProducts.sublist(0, 20);
    }
    notifyListeners();
    _saveRecents();
  }

  void clearHistory() {
    _recentProducts.clear();
    notifyListeners();
    _saveRecents();
  }

  // ─── Search History (Feature 4) ───────────────────────────────────────────

  void addSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _searchHistory.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    _searchHistory.insert(0, trimmed);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    _saveSearchHistory();
    notifyListeners();
  }

  void deleteSearchQuery(String query) {
    _searchHistory.removeWhere((e) => e == query);
    _saveSearchHistory();
    notifyListeners();
  }

  void clearAllSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
    notifyListeners();
  }

  // ─── Voice Search (Feature 5) ─────────────────────────────────────────────

  Future<void> startVoiceSearch(Function(String) onResult) async {
    try {
      final available = await _speech.initialize();
      if (available) {
        _isListening = true;
        notifyListeners();
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            onResult(val.recognizedWords);
            _isListening = false;
            notifyListeners();
          }
        });
      }
    } catch (_) {
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopVoiceSearch() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  // ─── Product Listing & Filters (Stale-While-Revalidate Cache Support) ──────

  Future<void> loadProducts({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    } else {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = false;
      _error = null;

      // Stale-While-Revalidate: serve cached list immediately if available
      final cached = _repository.getCachedProducts(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _categoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sort,
        page: 1,
        limit: 10,
      );

      if (cached != null) {
        _products = cached.products.map((p) => _mapApiProduct(p)).toList();
        _totalPages = cached.totalPages;
        _currentPage = cached.currentPage;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }

    try {
      final paginated = await _repository.getProducts(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _categoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sort,
        page: isLoadMore ? _currentPage : 1,
        limit: 10,
      );

      final mappedProducts =
          paginated.products.map((p) => _mapApiProduct(p)).toList();

      if (isLoadMore) {
        _products.addAll(mappedProducts);
      } else {
        _products = mappedProducts;
      }

      _totalPages = paginated.totalPages;
      _currentPage = paginated.currentPage;
      _hasMore = _currentPage < _totalPages;
      if (_hasMore) {
        _currentPage++;
      }
      _error = null;
    } catch (e) {
      if (_products.isEmpty) {
        _error = e.toString();
      }
    } finally {
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    addSearchQuery(query);
    ProductAnalyticsService.instance.searchProduct(query);
    await loadProducts(isLoadMore: false);
  }

  Future<void> applyCategory(int? categoryId) async {
    _categoryId = categoryId;
    await loadProducts(isLoadMore: false);
  }

  Future<void> applyPriceFilter(double? minPrice, double? maxPrice) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    await loadProducts(isLoadMore: false);
  }

  Future<void> applySorting(String? sort) async {
    _sort = sort;
    await loadProducts(isLoadMore: false);
  }

  Future<void> refresh() async {
    await loadProducts(isLoadMore: false);
  }

  Future<void> loadMore() async {
    await loadProducts(isLoadMore: true);
  }

  // ─── Single Product Load (Stale-While-Revalidate Cache Support) ────────────

  Future<void> loadSingleProduct(int id) async {
    _isLoading = true;
    _error = null;

    // Optimistic cache load
    final cachedDetail = _repository.getCachedSingleProduct(id);
    if (cachedDetail != null) {
      _selectedProduct = _mapApiProduct(cachedDetail);
      _isLoading = false;
      notifyListeners();
    } else {
      _selectedProduct = null;
      _relatedProducts = [];
      notifyListeners();
    }

    try {
      final apiProduct = await _repository.getSingleProduct(id);
      final detailedProduct = _mapApiProduct(apiProduct);
      _selectedProduct = detailedProduct;

      // Add to recently viewed
      addRecentlyViewed(detailedProduct);

      // Analytics view trigger
      ProductAnalyticsService.instance
          .viewProduct(detailedProduct.id, detailedProduct.name);

      // Load related products
      final relatedApiResult = await _repository.getProducts(
        categoryId: apiProduct.category.id,
        limit: 7,
      );

      _relatedProducts = relatedApiResult.products
          .where((p) => p.id != id)
          .take(6)
          .map((p) => _mapApiProduct(p))
          .toList();

      // Customers also bought (Feature 2)
      final recRepo = RecommendationRepository();
      final customersBoughtApi = await recRepo.getRecommended();
      _customersAlsoBought = customersBoughtApi
          .where((p) => p.id != id)
          .take(6)
          .map((p) => _mapApiProduct(p))
          .toList();

      _error = null;
    } catch (e) {
      if (_selectedProduct == null) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearFilters({bool notify = true}) async {
    _searchQuery = '';
    _categoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _sort = null;
    if (notify) {
      await loadProducts(isLoadMore: false);
    }
  }

  Product? getProduct(int id) {
    try {
      return _products.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _products.clear();
    _searchQuery = '';
    notifyListeners();
  }

  // ─── Mapper & Serialization Helpers ────────────────────────────────────────

  Product _mapApiProduct(dynamic p) {
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

  Map<String, dynamic> _productToJson(Product p) {
    return {
      'id': p.id,
      'store': p.store,
      'name': p.name,
      'category': p.category,
      'subCategory': p.subCategory,
      'type': p.type,
      'image': p.image,
      'unit': p.unit,
      'price': p.price,
      'mrp': p.mrp,
      'rating': p.rating,
      'reviews': p.reviews,
      'tag': p.tag,
      'origin': p.origin,
      'farmer': p.farmer,
      'process': p.process,
      'organic': p.organic,
      'description': p.description,
      'stock': p.stock,
      'isAvailable': p.isAvailable,
    };
  }

  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      store: json['store'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subCategory: json['subCategory'] as String? ?? '',
      type: json['type'] as String? ?? '',
      image: json['image'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviews: json['reviews'] as int? ?? 0,
      tag: json['tag'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      farmer: json['farmer'] as String? ?? '',
      process: json['process'] as String? ?? '',
      organic: json['organic'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
