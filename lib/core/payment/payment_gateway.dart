enum PaymentMethod {
  cod,
  upi,
  card,
  wallet,
  netBanking,
  razorpay,
  phonepe,
  googlepay
}

enum PaymentStatus { pending, processing, success, failure, cancelled }

class PaymentRequest {
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final String? upiId;
  final String? cardToken;

  PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.method,
    this.upiId,
    this.cardToken,
  });
}

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;
  final DateTime timestamp;

  PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => status == PaymentStatus.success;
}

/// Abstract payment gateway interface.
/// Each concrete gateway implements this for a specific payment provider.
abstract class AbstractPaymentGateway {
  PaymentMethod get method;
  String get displayName;
  String get iconAsset;

  /// Initiates the payment. Returns a result when complete.
  Future<PaymentResult> pay(PaymentRequest request);

  /// Checks the status of an existing transaction.
  Future<PaymentResult> checkStatus(String transactionId);
}
