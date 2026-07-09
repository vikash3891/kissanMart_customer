import 'payment_gateway.dart';

/// Cash on Delivery gateway — always succeeds immediately.
class CodGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.cod;

  @override
  String get displayName => 'Cash on Delivery';

  @override
  String get iconAsset => 'assets/icons/cod.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // COD is always confirmed instantly on placement
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'COD_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Mock UPI gateway — simulates a UPI payment flow.
class UpiGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.upi;

  @override
  String get displayName => 'UPI';

  @override
  String get iconAsset => 'assets/icons/upi.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'UPI_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Mock Card gateway — simulates card payment.
class CardGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.card;

  @override
  String get displayName => 'Credit / Debit Card';

  @override
  String get iconAsset => 'assets/icons/card.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'CARD_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Mock Wallet gateway.
class WalletGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.wallet;

  @override
  String get displayName => 'Wallet';

  @override
  String get iconAsset => 'assets/icons/wallet.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'WAL_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Razorpay gateway — integrated abstraction ready for SDK.
class RazorpayGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.razorpay;

  @override
  String get displayName => 'Razorpay';

  @override
  String get iconAsset => 'assets/icons/razorpay.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // Under the hood, this will invoke Razorpay Flutter SDK:
    // _razorpay.open(options);
    // and wait for payment handler events.
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'RZP_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// PhonePe gateway — integrated API/SDK abstraction.
class PhonePeGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.phonepe;

  @override
  String get displayName => 'PhonePe';

  @override
  String get iconAsset => 'assets/icons/phonepe.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // Under the hood, this will construct the PhonePe payment request object
    // and call PhonePePg.startTransaction(...)
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'PPE_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Google Pay gateway — native Google Pay system sheet.
class GooglePayGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.googlepay;

  @override
  String get displayName => 'Google Pay';

  @override
  String get iconAsset => 'assets/icons/googlepay.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // Under the hood, this will call Google Pay API using pay package:
    // payClient.showPaymentSelector(...)
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'GPAY_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}

/// Net Banking gateway.
class NetBankingGateway extends AbstractPaymentGateway {
  @override
  PaymentMethod get method => PaymentMethod.netBanking;

  @override
  String get displayName => 'Net Banking';

  @override
  String get iconAsset => 'assets/icons/netbanking.png';

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId:
          'NET_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> checkStatus(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    );
  }
}
