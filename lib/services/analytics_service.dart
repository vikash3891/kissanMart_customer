/// Premium analytics tracking service architecture for Kisaan Kart.
///
/// Methods are empty placeholders ready for future third-party integrations (e.g. Firebase, Mixpanel).
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  void viewProduct(int id, String name) {}
  void favorite(int id, String name, bool isFav) {}
  void share(int id, String name) {}
  void search(String query) {}
  void filter(String key, String value) {}
  void checkout(double totalAmount) {}
  void buyAgain(int orderId) {}
}
