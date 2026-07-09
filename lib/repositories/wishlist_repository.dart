import '../api_models/api_product.dart';
import '../services/wishlist_service.dart';

class WishlistRepository {
  final WishlistService _service = WishlistService();

  Future<List<ApiProduct>> getWishlist() => _service.getWishlist();

  Future<bool> addToWishlist(int productId) =>
      _service.addToWishlist(productId);

  Future<bool> removeFromWishlist(int productId) =>
      _service.removeFromWishlist(productId);
}
