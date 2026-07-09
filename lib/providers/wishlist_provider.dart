import 'package:flutter/material.dart';

import '../api_models/api_product.dart';
import '../models/product.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/wishlist_cache_repository.dart';
import '../services/api_exception.dart';
import '../core/logging/logger_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repository = WishlistRepository();
  final WishlistCacheRepository _cache = WishlistCacheRepository();

  bool _loading = false;
  String? _error;
  List<Product> _wishlistItems = [];
  Set<int> _favoriteIds = {};

  bool get loading => _loading;
  String? get error => _error;
  List<Product> get wishlistItems => _wishlistItems;
  int get count => _wishlistItems.length;

  Future<void> loadWishlist() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Load cached IDs immediately for instant UI response
      _favoriteIds = _cache.getCachedIds();

      final apiProducts = await _repository.getWishlist();
      _wishlistItems = apiProducts.map((e) => _mapApiProduct(e)).toList();
      _favoriteIds = _wishlistItems.map((e) => e.id).toSet();
      await _cache.cacheIds(_favoriteIds);
      _error = null;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      LoggerService.error('Failed to load wishlist', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addToWishlist(int productId) async {
    // Optimistic update
    _favoriteIds.add(productId);
    await _cache.addId(productId);
    notifyListeners();

    _error = null;
    try {
      final success = await _repository.addToWishlist(productId);
      if (success) {
        await loadWishlist();
      } else {
        // Revert optimistic update
        _favoriteIds.remove(productId);
        await _cache.removeId(productId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      // Revert optimistic update
      _favoriteIds.remove(productId);
      await _cache.removeId(productId);
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    // Optimistic update
    _favoriteIds.remove(productId);
    await _cache.removeId(productId);
    _wishlistItems.removeWhere((item) => item.id == productId);
    notifyListeners();

    _error = null;
    try {
      final success = await _repository.removeFromWishlist(productId);
      if (!success) {
        // Revert
        _favoriteIds.add(productId);
        await _cache.addId(productId);
        await loadWishlist();
      }
      return success;
    } catch (e) {
      _favoriteIds.add(productId);
      await _cache.addId(productId);
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      await loadWishlist();
      return false;
    }
  }

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleWishlist(int productId) async {
    if (isFavorite(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  Future<void> removeAll() async {
    final ids = List<int>.from(_favoriteIds);
    _favoriteIds.clear();
    _wishlistItems.clear();
    await _cache.clearCache();
    notifyListeners();

    for (final id in ids) {
      try {
        await _repository.removeFromWishlist(id);
      } catch (_) {}
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
