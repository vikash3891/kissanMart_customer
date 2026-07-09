import 'payment_gateway.dart';
import 'payment_gateways.dart';

class PaymentGatewayFactory {
  static final Map<PaymentMethod, AbstractPaymentGateway> _gateways = {
    PaymentMethod.cod: CodGateway(),
    PaymentMethod.upi: UpiGateway(),
    PaymentMethod.card: CardGateway(),
    PaymentMethod.wallet: WalletGateway(),
    PaymentMethod.netBanking: NetBankingGateway(),
    PaymentMethod.razorpay: RazorpayGateway(),
    PaymentMethod.phonepe: PhonePeGateway(),
    PaymentMethod.googlepay: GooglePayGateway(),
  };

  static AbstractPaymentGateway getGateway(PaymentMethod method) {
    final gateway = _gateways[method];
    if (gateway == null) {
      throw Exception('Payment method $method is not configured');
    }
    return gateway;
  }

  static List<AbstractPaymentGateway> get availableGateways =>
      _gateways.values.toList();
}
