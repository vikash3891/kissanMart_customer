import '../api_models/coupon_apply_response.dart';
import '../models/coupon.dart';
import 'api_service.dart';

class CouponService {
  final ApiService _apiService = ApiService();

  static final List<Coupon> _mockCoupons = [
    Coupon(
      code: 'KISAAN100',
      description: 'Flat ₹100 off on orders of ₹599 or more',
      discountType: 'flat',
      discountValue: 100,
      minimumOrderAmount: 599,
      maximumDiscount: 100,
      expiryDate: DateTime.now().add(const Duration(days: 15)),
    ),
    Coupon(
      code: 'FRESH20',
      description: 'Get 20% off up to ₹150 on orders of ₹399 or more',
      discountType: 'percentage',
      discountValue: 20,
      minimumOrderAmount: 399,
      maximumDiscount: 150,
      expiryDate: DateTime.now().add(const Duration(days: 10)),
    ),
    Coupon(
      code: 'WELCOME50',
      description: 'Flat ₹50 off on orders of ₹199 or more',
      discountType: 'flat',
      discountValue: 50,
      minimumOrderAmount: 199,
      maximumDiscount: 50,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Coupon(
      code: 'SUPER50',
      description: 'Get 50% off up to ₹100 on orders of ₹299 or more',
      discountType: 'percentage',
      discountValue: 50,
      minimumOrderAmount: 299,
      maximumDiscount: 100,
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];

  Future<List<Coupon>> getAvailableCoupons() async {
    // Simulate minor network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCoupons;
  }

  Future<CouponApplyResponse> applyCoupon({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final response = await _apiService.post('/coupons/apply', {
        'code': code,
        'orderAmount': orderAmount,
      });
      if (response['success'] == true && response['data'] != null) {
        return CouponApplyResponse.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to apply coupon');
    } catch (e) {
      // Fallback to local calculation if backend is unavailable or fails
      final matched = _mockCoupons.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase() && c.isActive,
        orElse: () =>
            throw Exception('Coupon code "$code" is invalid or inactive'),
      );

      if (orderAmount < matched.minimumOrderAmount) {
        throw Exception(
            'Minimum order amount for code ${matched.code} is ₹${matched.minimumOrderAmount}');
      }

      final discount = matched.calculateDiscount(orderAmount);
      return CouponApplyResponse(
        couponCode: matched.code,
        discount: discount,
        finalAmount: orderAmount - discount,
      );
    }
  }
}
