import '../api_models/api_product.dart';
import 'api_service.dart';

class WishlistService {
  final ApiService _apiService = ApiService();

  Future<List<ApiProduct>> getWishlist() async {
    try {
      final response = await _apiService.get('/wishlist');
      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];
        return data.map((e) => ApiProduct.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load wishlist: $e');
    }
  }

  Future<bool> addToWishlist(int productId) async {
    try {
      final response = await _apiService.post('/wishlist/$productId', {});
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    try {
      final response = await _apiService.delete('/wishlist/$productId');
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
}
