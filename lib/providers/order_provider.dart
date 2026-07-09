import 'package:flutter/material.dart';

import '../api_models/api_order.dart';
import '../repositories/order_repository.dart';
import '../services/api_exception.dart';
import '../models/product.dart' as ui;

/// Provider that manages order state, loading status, errors, and actions.
class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  bool _loading = false;
  bool _placingOrder = false;
  List<ApiOrder> _orders = [];
  ApiOrder? _selectedOrder;
  String? _error;

  bool get loading => _loading;
  bool get isLoading => _loading; // backwards compatibility
  bool get placingOrder => _placingOrder;
  List<ApiOrder> get orders => _orders;
  ApiOrder? get selectedOrder => _selectedOrder;
  String? get error => _error;

  // ─── Recently Purchased (Feature 5) ───────────────────────────────────────

  List<ui.Product> get recentPurchases {
    final list = <ui.Product>[];
    final seen = <int>{};
    for (final order in _orders) {
      for (final item in order.items) {
        final p = item.product;
        if (!seen.contains(p.id)) {
          seen.add(p.id);
          list.add(ui.Product(
            id: p.id,
            store: p.brand,
            name: p.name,
            category: '',
            subCategory: '',
            type: '',
            image: p.imageUrl,
            unit: p.unit,
            price: p.discountPrice,
            mrp: p.price,
            rating: 4.5,
            reviews: 0,
            tag: '',
            origin: '',
            farmer: p.brand,
            process: '',
            organic: true,
          ));
        }
      }
    }
    return list;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.getOrders();
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrder(int orderId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedOrder = await _repository.getOrder(orderId);
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
    List<int>? cartItemIds,
  }) async {
    _placingOrder = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _repository.placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        cartItemIds: cartItemIds,
      );
      _orders.insert(0, order);
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _placingOrder = false;
      notifyListeners();
    }
  }

  Future<bool> buyNow({
    required int productId,
    required int quantity,
    required int addressId,
    required String paymentMethod,
  }) async {
    _placingOrder = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _repository.buyNow(
        productId: productId,
        quantity: quantity,
        addressId: addressId,
        paymentMethod: paymentMethod,
      );
      _orders.insert(0, order);
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _placingOrder = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.cancelOrder(orderId);
      _selectedOrder = await _repository.getOrder(orderId);
      await loadOrders();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Something went wrong';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
