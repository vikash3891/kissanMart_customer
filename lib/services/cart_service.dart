import '../api_models/api_cart_item.dart';
import 'api_service.dart';

class CartService {
  final ApiService _apiService = ApiService();

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    await _apiService.post('/cart', {
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<List<ApiCartItem>> getCart() async {
    final response = await _apiService.get('/cart');
    final List list = response['data'] ?? [];
    return list.map((e) => ApiCartItem.fromJson(e)).toList();
  }

  Future<void> updateCart({
    required int productId,
    required int quantity,
  }) async {
    await _apiService.put('/cart/$productId', {
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart(int productId) async {
    await _apiService.delete('/cart/$productId');
  }

  Future<void> clearCart() async {
    await _apiService.delete('/cart/clear/all');
  }
}
