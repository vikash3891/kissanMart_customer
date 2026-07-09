import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api_models/api_cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../services/api_exception.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();

  bool _loading = false;
  bool _operationInProgress = false;
  String? _error;
  List<ApiCartItem> _items = [];
  final List<Product> _savedProducts = [];
  final Set<int> _selectedCartItemIds = {};

  bool get loading => _loading;
  bool get operationInProgress => _operationInProgress;
  String? get error => _error;
  List<ApiCartItem> get items => _items;
  Set<int> get selectedCartItemIds => _selectedCartItemIds;

  List<ApiCartItem> get selectedItems =>
      _items.where((item) => _selectedCartItemIds.contains(item.id)).toList();

  // Totals calculations based on selected items only
  double get subtotal => selectedItems.fold(
      0.0, (sum, item) => sum + (item.discountPrice * item.quantity));

  double get deliveryFee {
    if (subtotal == 0) return 0.0;
    return subtotal >= 199.0 ? 0.0 : 25.0;
  }

  double get gst {
    if (subtotal == 0) return 0.0;
    return double.parse((subtotal * 0.05).toStringAsFixed(2));
  }

  double get handling {
    if (subtotal == 0) return 0.0;
    return 4.0;
  }

  double get total {
    if (subtotal == 0) return 0.0;
    return subtotal + deliveryFee + gst + handling;
  }

  int get itemCount =>
      selectedItems.fold(0, (sum, item) => sum + item.quantity);

  // Helper queries to support current codebase without major rewrites
  Map<int, int> get cart =>
      {for (var item in _items) item.productId: item.quantity};

  int qtyByProductId(int productId) {
    final idx = _items.indexWhere((item) => item.productId == productId);
    return idx != -1 ? _items[idx].quantity : 0;
  }

  int qty(dynamic product) {
    return qtyByProductId(product.id);
  }

  void toggleSelection(int cartItemId) {
    if (_selectedCartItemIds.contains(cartItemId)) {
      _selectedCartItemIds.remove(cartItemId);
    } else {
      _selectedCartItemIds.add(cartItemId);
    }
    notifyListeners();
  }

  void selectAll(bool select) {
    if (select) {
      _selectedCartItemIds.addAll(_items.map((e) => e.id));
    } else {
      _selectedCartItemIds.clear();
    }
    notifyListeners();
  }

  Future<void> loadCart() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _cartRepository.getCart();
      _selectedCartItemIds.addAll(_items.map((e) => e.id));
      _error = null;
    } catch (e) {
      debugPrint('[CartProvider] loadCart error: $e');
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required int productId,
    required int quantity,
    String name = 'Product',
    double price = 0.0,
    double discountPrice = 0.0,
    String imageUrl = '',
    int stock = 99,
  }) async {
    if (_loading || _operationInProgress) return false;
    _operationInProgress = true;

    // Optimistic Update
    final originalItems = List<ApiCartItem>.from(_items);
    final existingIdx =
        _items.indexWhere((item) => item.productId == productId);
    if (existingIdx != -1) {
      final existing = _items[existingIdx];
      _items[existingIdx] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items.add(ApiCartItem(
        id: 0,
        productId: productId,
        quantity: quantity,
        name: name,
        price: price,
        discountPrice: discountPrice,
        imageUrl: imageUrl,
        stock: stock,
      ));
    }
    notifyListeners();

    try {
      await _cartRepository.addToCart(productId: productId, quantity: quantity);
      await _refreshQuietly();
      _operationInProgress = false;
      return true;
    } catch (e) {
      debugPrint('[CartProvider] addToCart error for productId=$productId: $e');
      _items = originalItems;
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _operationInProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    if (_loading || _operationInProgress) return false;

    if (quantity <= 0) {
      return removeItem(productId);
    }

    _operationInProgress = true;

    // Optimistic Update
    final originalItems = List<ApiCartItem>.from(_items);
    final idx = _items.indexWhere((item) => item.productId == productId);
    if (idx != -1) {
      final original = _items[idx];
      _items[idx] = original.copyWith(quantity: quantity);
    }
    notifyListeners();

    try {
      await _cartRepository.updateCart(
          productId: productId, quantity: quantity);
      await _refreshQuietly();
      _operationInProgress = false;
      return true;
    } catch (e) {
      debugPrint(
          '[CartProvider] updateQuantity error for productId=$productId: $e');
      _items = originalItems;
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _operationInProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(int productId) async {
    if (_loading || _operationInProgress) return false;
    _operationInProgress = true;

    // Optimistic Update
    final originalItems = List<ApiCartItem>.from(_items);
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();

    try {
      await _cartRepository.removeFromCart(productId);
      await _refreshQuietly();
      _operationInProgress = false;
      return true;
    } catch (e) {
      debugPrint(
          '[CartProvider] removeItem error for productId=$productId: $e');
      _items = originalItems;
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _operationInProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart() async {
    if (_loading || _operationInProgress) return false;
    _operationInProgress = true;

    // Optimistic Update
    final originalItems = List<ApiCartItem>.from(_items);
    _items.clear();
    _selectedCartItemIds.clear();
    notifyListeners();

    try {
      await _cartRepository.clearCart();
      await _refreshQuietly();
      _operationInProgress = false;
      return true;
    } catch (e) {
      debugPrint('[CartProvider] clearCart error: $e');
      _items = originalItems;
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _operationInProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> add(dynamic product) {
    if (product.stock <= 0 || !product.isAvailable) {
      _error = 'Product is out of stock';
      notifyListeners();
      return Future.value(false);
    }

    final currentQty = qty(product);
    if (currentQty == 0) {
      return addToCart(
        productId: product.id,
        quantity: 1,
        name: product.name,
        price: product.mrp,
        discountPrice: product.price,
        imageUrl: product.image,
        stock: product.stock,
      );
    } else {
      if (currentQty >= product.stock) {
        _error = 'Only ${product.stock} item(s) available';
        notifyListeners();
        return Future.value(false);
      }
      return updateQuantity(
        productId: product.id,
        quantity: currentQty + 1,
      );
    }
  }

  Future<bool> remove(dynamic product) {
    final currentQty = qty(product);
    if (currentQty <= 1) {
      return removeItem(product.id);
    } else {
      return updateQuantity(
        productId: product.id,
        quantity: currentQty - 1,
      );
    }
  }

  Future<void> _refreshQuietly() async {
    try {
      _items = await _cartRepository.getCart();
      // Retain or select new items
      final currentIds = _items.map((e) => e.id).toSet();
      _selectedCartItemIds.retainAll(currentIds);
      for (final item in _items) {
        if (item.id != 0 && !_selectedCartItemIds.contains(item.id)) {
          _selectedCartItemIds.add(item.id);
        }
      }
      _error = null;
    } catch (e) {
      debugPrint('[CartProvider] _refreshQuietly error: $e');
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() {
    return loadCart();
  }

  void clear() {
    clearCart();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<List<int>> syncCartToBackend() async {
    await loadCart();
    return _items.map((e) => e.id).toList();
  }

  List<Product> get savedProducts => List.unmodifiable(_savedProducts);

  void saveForLater(Product p) {
    removeItem(p.id);
    if (!_savedProducts.any((s) => s.id == p.id)) {
      _savedProducts.add(p);
    }
    notifyListeners();
  }

  void moveToCart(Product p) {
    _savedProducts.removeWhere((s) => s.id == p.id);
    add(p);
    notifyListeners();
  }

  List<Product> cartProducts(List<Product> allProducts) {
    final productMap = {for (var p in allProducts) p.id: p};
    final result = <Product>[];
    for (final item in _items) {
      final matched = productMap[item.productId];
      if (matched != null) {
        result.add(matched);
      }
    }
    return result;
  }
}
