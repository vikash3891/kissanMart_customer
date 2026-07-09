class CouponApplyResponse {
  final String couponCode;
  final double discount;
  final double finalAmount;

  CouponApplyResponse({
    required this.couponCode,
    required this.discount,
    required this.finalAmount,
  });

  factory CouponApplyResponse.fromJson(Map<String, dynamic> json) {
    return CouponApplyResponse(
      couponCode: json['coupon'] ?? '',
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      finalAmount: double.tryParse(json['finalAmount'].toString()) ?? 0.0,
    );
  }
}
