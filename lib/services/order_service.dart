import '../api_models/api_order.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Service layer for order-related API calls.
class OrderService {
  final ApiService _apiService = ApiService();

  Future<ApiOrder> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
    List<int>? cartItemIds,
  }) async {
    final body = <String, dynamic>{
      'address_id': addressId,
      'payment_method': paymentMethod,
    };
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      body['coupon_code'] = couponCode.trim();
    }
    if (cartItemIds != null && cartItemIds.isNotEmpty) {
      body['cart_item_ids'] = cartItemIds;
    }
    final response = await _apiService.post(ApiConstants.placeOrder, body);
    return ApiOrder.fromJson(response['data']);
  }

  Future<ApiOrder> buyNow({
    required int productId,
    required int quantity,
    required int addressId,
    required String paymentMethod,
  }) async {
    final response = await _apiService.post(
      ApiConstants.buyNow,
      {
        'product_id': productId,
        'quantity': quantity,
        'address_id': addressId,
        'payment_method': paymentMethod,
      },
    );
    return ApiOrder.fromJson(response['data']);
  }

  Future<List<ApiOrder>> getMyOrders() async {
    final response = await _apiService.get(ApiConstants.getMyOrders);
    final List data = response['data'] ?? [];
    return data
        .map((e) => ApiOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApiOrder> getOrder(int id) async {
    final response = await _apiService.get(
      '${ApiConstants.getSingleOrder}/$id',
    );
    return ApiOrder.fromJson(response['data']);
  }

  Future<String> cancelOrder(int orderId) async {
    final response = await _apiService.patch(
      '${ApiConstants.cancelOrder}/$orderId',
      {},
    );
    return response['data'] ?? '';
  }
}
