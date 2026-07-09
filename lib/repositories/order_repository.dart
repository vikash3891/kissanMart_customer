import '../api_models/api_order.dart';
import '../services/order_service.dart';

/// Repository layer for orders. Delegates to [OrderService].
class OrderRepository {
  final OrderService _service = OrderService();

  Future<ApiOrder> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
    List<int>? cartItemIds,
  }) {
    return _service.placeOrder(
      addressId: addressId,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      cartItemIds: cartItemIds,
    );
  }

  Future<ApiOrder> buyNow({
    required int productId,
    required int quantity,
    required int addressId,
    required String paymentMethod,
  }) {
    return _service.buyNow(
      productId: productId,
      quantity: quantity,
      addressId: addressId,
      paymentMethod: paymentMethod,
    );
  }

  Future<List<ApiOrder>> getOrders() => _service.getMyOrders();

  Future<ApiOrder> getOrder(int id) => _service.getOrder(id);

  Future<String> cancelOrder(int id) => _service.cancelOrder(id);
}
