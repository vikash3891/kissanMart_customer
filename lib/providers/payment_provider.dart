import 'package:flutter/material.dart';

import '../core/payment/payment_gateway.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  PaymentMethod _selectedMethod = PaymentMethod.cod;
  bool _loading = false;
  PaymentResult? _lastResult;
  String? _error;

  PaymentMethod get selectedMethod => _selectedMethod;
  bool get loading => _loading;
  PaymentResult? get lastResult => _lastResult;
  String? get error => _error;

  List<AbstractPaymentGateway> get availableGateways =>
      _repository.getAvailableGateways();

  void selectMethod(PaymentMethod method) {
    if (_selectedMethod != method) {
      _selectedMethod = method;
      notifyListeners();
    }
  }

  Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    String? upiId,
    String? cardToken,
  }) async {
    _loading = true;
    _error = null;
    _lastResult = null;
    notifyListeners();

    try {
      final res = await _repository.pay(
        orderId: orderId,
        amount: amount,
        method: _selectedMethod,
        upiId: upiId,
        cardToken: cardToken,
      );
      _lastResult = res;
      if (!res.isSuccess) {
        _error = res.errorMessage ?? 'Payment failed';
      }
      return res;
    } catch (e) {
      _error = e.toString();
      final errRes = PaymentResult(
        status: PaymentStatus.failure,
        errorMessage: e.toString(),
      );
      _lastResult = errRes;
      return errRes;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    _lastResult = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
