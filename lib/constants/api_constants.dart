import '../core/config/environment_config.dart';

class ApiConstants {
  // Google Maps API Key constant
  static String get googleMapsApiKey => EnvironmentConfig.googleMapsApiKey;

  // Change this according to your device

  // Android Emulator
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // Physical Phone Example
  // static const String baseUrl = "http://192.168.1.5:5000";

  // ================= Authentication =================

  static const login = "/auth/login";
  static const register = "/auth/register";

  // ================= Products =================

  static const products = "/products";

  // ================= Cart =================

  static const addToCart = "/cart";
  static const getCart = "/cart";
  static const updateCart = "/cart";
  static const deleteCart = "/cart";

  // ================= Address =================

  static const addresses = "/address";

  // ================= Orders =================

  static const placeOrder = "/orders";

  static const buyNow = "/orders/buy-now";

  static const getMyOrders = "/orders/my";

  static const getSingleOrder = "/orders";

  static const cancelOrder = "/orders/cancel";
}
