import '../core/storage/hive_storage_service.dart';
import '../models/coupon.dart';

class CouponCacheRepository {
  static const _boxName = HiveStorageService.couponsBox;
  static const _couponsKey = 'cached_coupons';

  Future<List<Coupon>> getCachedCoupons() async {
    final raw = HiveStorageService.read(_boxName, _couponsKey);
    if (raw is Map) {
      final wrapped = Map<dynamic, dynamic>.from(raw);
      if (!HiveStorageService.isCacheStale(wrapped)) {
        final data = wrapped['data'];
        if (data is List) {
          return data.map((e) => Coupon.fromJson(e as Map)).toList();
        }
      }
    }
    return [];
  }

  Future<void> cacheCoupons(List<Coupon> coupons) async {
    final wrapped = HiveStorageService.wrapCache(
      coupons.map((c) => c.toJson()).toList(),
      const Duration(days: 1),
    );
    await HiveStorageService.write(_boxName, _couponsKey, wrapped);
  }

  Future<void> clearCache() async {
    await HiveStorageService.clear(_boxName);
  }
}
