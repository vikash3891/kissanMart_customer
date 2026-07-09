import '../api_models/coupon_apply_response.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';
import 'coupon_cache_repository.dart';

class CouponRepository {
  final CouponService _couponService = CouponService();
  final CouponCacheRepository _cache = CouponCacheRepository();

  Future<List<Coupon>> getAvailableCoupons() async {
    try {
      final remote = await _couponService.getAvailableCoupons();
      await _cache.cacheCoupons(remote);
      return remote;
    } catch (_) {
      final cached = await _cache.getCachedCoupons();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<CouponApplyResponse> applyCoupon({
    required String code,
    required double orderAmount,
  }) {
    return _couponService.applyCoupon(code: code, orderAmount: orderAmount);
  }
}
