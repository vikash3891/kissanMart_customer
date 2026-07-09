class Coupon {
  final String code;
  final String description;
  final String discountType; // 'percentage' or 'flat'
  final double discountValue;
  final double minimumOrderAmount;
  final double maximumDiscount;
  final DateTime expiryDate;
  final bool isActive;

  Coupon({
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minimumOrderAmount,
    required this.maximumDiscount,
    required this.expiryDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscount': maximumDiscount,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Coupon.fromJson(Map<dynamic, dynamic> json) {
    return Coupon(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? 'flat',
      discountValue: double.tryParse(json['discountValue'].toString()) ?? 0.0,
      minimumOrderAmount:
          double.tryParse(json['minimumOrderAmount'].toString()) ?? 0.0,
      maximumDiscount:
          double.tryParse(json['maximumDiscount'].toString()) ?? 0.0,
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      isActive: json['isActive'] ?? true,
    );
  }

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minimumOrderAmount) return 0.0;
    if (discountType == 'percentage') {
      double discount = orderAmount * (discountValue / 100.0);
      if (maximumDiscount > 0 && discount > maximumDiscount) {
        discount = maximumDiscount;
      }
      return discount;
    } else {
      return discountValue;
    }
  }
}
