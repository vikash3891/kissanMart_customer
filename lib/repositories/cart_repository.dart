import '../api_models/api_cart_item.dart';
import '../services/cart_service.dart';

class CartRepository {
  final CartService _cartService = CartService();

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) {
    return _cartService.addToCart(productId: productId, quantity: quantity);
  }

  Future<List<ApiCartItem>> getCart() {
    return _cartService.getCart();
  }

  Future<void> updateCart({
    required int productId,
    required int quantity,
  }) {
    return _cartService.updateCart(productId: productId, quantity: quantity);
  }

  Future<void> removeFromCart(int productId) {
    return _cartService.removeFromCart(productId);
  }

  Future<void> clearCart() {
    return _cartService.clearCart();
  }
}
