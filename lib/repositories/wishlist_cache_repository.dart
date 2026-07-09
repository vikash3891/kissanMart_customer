import '../core/storage/hive_storage_service.dart';

class WishlistCacheRepository {
  static const _boxName = HiveStorageService.wishlistBox;
  static const _idsKey = 'wishlist_product_ids';

  /// Returns cached wishlist product IDs.
  Set<int> getCachedIds() {
    final raw = HiveStorageService.read(_boxName, _idsKey);
    if (raw is List) {
      return raw.map((e) => e as int).toSet();
    }
    return {};
  }

  /// Saves wishlist product IDs to cache.
  Future<void> cacheIds(Set<int> ids) async {
    await HiveStorageService.write(_boxName, _idsKey, ids.toList());
  }

  /// Optimistic add.
  Future<void> addId(int productId) async {
    final ids = getCachedIds();
    ids.add(productId);
    await cacheIds(ids);
  }

  /// Optimistic remove.
  Future<void> removeId(int productId) async {
    final ids = getCachedIds();
    ids.remove(productId);
    await cacheIds(ids);
  }

  Future<void> clearCache() async {
    await HiveStorageService.clear(_boxName);
  }
}
