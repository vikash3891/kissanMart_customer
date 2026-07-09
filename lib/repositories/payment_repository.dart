import '../core/payment/payment_gateway.dart';
import '../core/payment/payment_gateway_factory.dart';
import '../core/logging/logger_service.dart';

class PaymentRepository {
  /// Processes payment using the appropriate gateway.
  /// The caller never needs to know which gateway is used.
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required PaymentMethod method,
    String? upiId,
    String? cardToken,
  }) async {
    try {
      final gateway = PaymentGatewayFactory.getGateway(method);
      LoggerService.info(
          'Processing payment via ${gateway.displayName} for order $orderId');

      final request = PaymentRequest(
        orderId: orderId,
        amount: amount,
        method: method,
        upiId: upiId,
        cardToken: cardToken,
      );

      final result = await gateway.pay(request);
      LoggerService.info(
          'Payment result: ${result.status} txn: ${result.transactionId}');
      return result;
    } catch (e) {
      LoggerService.error('Payment failed', e);
      return PaymentResult(
        status: PaymentStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Check status of an existing transaction.
  Future<PaymentResult> checkStatus({
    required PaymentMethod method,
    required String transactionId,
  }) async {
    final gateway = PaymentGatewayFactory.getGateway(method);
    return gateway.checkStatus(transactionId);
  }

  /// Returns all available payment options for the UI.
  List<AbstractPaymentGateway> getAvailableGateways() {
    return PaymentGatewayFactory.availableGateways;
  }
}
