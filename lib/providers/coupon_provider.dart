import 'package:flutter/material.dart';

import '../api_models/coupon_apply_response.dart';
import '../models/coupon.dart';
import '../repositories/coupon_repository.dart';
import '../core/logging/logger_service.dart';

class CouponProvider extends ChangeNotifier {
  final CouponRepository _repository = CouponRepository();

  bool _loading = false;
  CouponApplyResponse? _appliedCoupon;
  String? _error;
  List<Coupon> _availableCoupons = [];

  bool get loading => _loading;
  CouponApplyResponse? get appliedCoupon => _appliedCoupon;
  String? get error => _error;
  List<Coupon> get availableCoupons => _availableCoupons;

  Future<void> loadAvailableCoupons() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _availableCoupons = await _repository.getAvailableCoupons();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      LoggerService.error('Failed to load available coupons', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> applyCoupon(String code, double orderAmount) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _appliedCoupon =
          await _repository.applyCoupon(code: code, orderAmount: orderAmount);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _appliedCoupon = null;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> autoApplyBest(double orderAmount) async {
    if (_availableCoupons.isEmpty) {
      await loadAvailableCoupons();
    }

    Coupon? bestCoupon;
    double maxDiscount = 0.0;

    for (final coupon in _availableCoupons) {
      if (coupon.isActive && orderAmount >= coupon.minimumOrderAmount) {
        final disc = coupon.calculateDiscount(orderAmount);
        if (disc > maxDiscount) {
          maxDiscount = disc;
          bestCoupon = coupon;
        }
      }
    }

    if (bestCoupon != null) {
      return applyCoupon(bestCoupon.code, orderAmount);
    }

    _error = 'No eligible coupons found for this order amount';
    notifyListeners();
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _error = null;
    notifyListeners();
  }
}
