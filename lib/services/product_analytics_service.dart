/// Prepared architecture for analytics tracking in Kisaan Kart.
///
/// Methods are empty placeholders ready for production integration.
class ProductAnalyticsService {
  static final ProductAnalyticsService instance = ProductAnalyticsService._();
  ProductAnalyticsService._();

  void viewProduct(int id, String name) {}
  void searchProduct(String query) {}
  void shareProduct(int id, String name) {}
  void favoriteProduct(int id, String name, bool isFavorite) {}
  void addToCart(int id, String name, int quantity) {}
}
