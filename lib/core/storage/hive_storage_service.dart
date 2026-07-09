import 'package:hive_flutter/hive_flutter.dart';
import '../logging/logger_service.dart';

class HiveStorageService {
  static const String profileBox = 'profile_box';
  static const String wishlistBox = 'wishlist_box';
  static const String notificationBox = 'notification_box';
  static const String ordersBox = 'orders_box';
  static const String productsBox = 'products_box';
  static const String categoriesBox = 'categories_box';
  static const String couponsBox = 'coupons_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String recentlyViewedBox = 'recently_viewed_box';
  static const String remoteConfigBox = 'remote_config_box';
  static const String settingsBox = 'settings_box';

  static final List<String> _boxesList = [
    profileBox,
    wishlistBox,
    notificationBox,
    ordersBox,
    productsBox,
    categoriesBox,
    couponsBox,
    searchHistoryBox,
    recentlyViewedBox,
    remoteConfigBox,
    settingsBox,
  ];

  /// Initializes Hive and opens all boxes.
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      for (final boxName in _boxesList) {
        await Hive.openBox(boxName);
      }
      LoggerService.info('Hive initialized and all boxes opened successfully.');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize Hive.', e, stackTrace);
    }
  }

  /// Writes data to a box.
  static Future<void> write(String boxName, String key, dynamic value) async {
    try {
      final box = Hive.box(boxName);
      await box.put(key, value);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Hive write failed in box $boxName for key $key', e, stackTrace);
    }
  }

  /// Reads data from a box.
  static dynamic read(String boxName, String key) {
    try {
      final box = Hive.box(boxName);
      return box.get(key);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Hive read failed in box $boxName for key $key', e, stackTrace);
      return null;
    }
  }

  /// Deletes a key from a box.
  static Future<void> delete(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      await box.delete(key);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Hive delete failed in box $boxName for key $key', e, stackTrace);
    }
  }

  /// Clears all keys in a box.
  static Future<void> clear(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.clear();
    } catch (e, stackTrace) {
      LoggerService.error('Hive clear failed for box $boxName', e, stackTrace);
    }
  }

  /// Retrieves all values in a box.
  static List<dynamic> getAll(String boxName) {
    try {
      final box = Hive.box(boxName);
      return box.values.toList();
    } catch (e, stackTrace) {
      LoggerService.error('Hive getAll failed for box $boxName', e, stackTrace);
      return [];
    }
  }

  /// Wraps data with caching metadata.
  static Map<String, dynamic> wrapCache(dynamic data, Duration ttl,
      {int version = 1}) {
    final now = DateTime.now();
    return {
      'data': data,
      'cachedAt': now.toIso8601String(),
      'expiresAt': now.add(ttl).toIso8601String(),
      'version': version,
    };
  }

  /// Checks if cached item is stale.
  static bool isCacheStale(Map<dynamic, dynamic>? wrapped) {
    if (wrapped == null) return true;
    final expiresAtStr = wrapped['expiresAt'] as String?;
    if (expiresAtStr == null) return true;
    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }
}
