import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/payment/payment_gateway.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/notification_provider.dart';
import '../address/address_screen.dart';
import 'coupons_bottom_sheet.dart';
import 'payment_method_sheet.dart';

/// Checkout screen — delivery address, payment method, coupon, order summary, place order.
/// Supports both Cart Checkout and single-product "Buy Now" Checkout.
class CheckoutScreen extends StatefulWidget {
  final int? buyNowProductId;
  final int? buyNowQuantity;
  final double? buyNowProductPrice;
  final List<int>? cartItemIds;

  const CheckoutScreen({
    super.key,
    this.buyNowProductId,
    this.buyNowQuantity,
    this.buyNowProductPrice,
    this.cartItemIds,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool get _isBuyNow => widget.buyNowProductId != null;

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final couponProvider = context.watch<CouponProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

    final double orderTotal = _isBuyNow
        ? (widget.buyNowProductPrice! * widget.buyNowQuantity!)
        : cartProvider.total;

    final discount = couponProvider.appliedCoupon != null
        ? couponProvider.appliedCoupon!.discount
        : 0.0;
    final finalPayable = couponProvider.appliedCoupon != null
        ? couponProvider.appliedCoupon!.finalAmount
        : orderTotal;

    final gateways = paymentProvider.availableGateways;
    final activeGateway = gateways.firstWhere(
      (g) => g.method == paymentProvider.selectedMethod,
      orElse: () => gateways.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Deliver to ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Deliver to',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),

          if (addressProvider.selectedAddress != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, color: context.colors.primary),
                  title: Row(
                    children: [
                      Text(
                        addressProvider.selectedAddress!.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          addressProvider.selectedAddress!.addressType
                              .toUpperCase(),
                          style: TextStyle(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${addressProvider.selectedAddress!.houseNo}, ${addressProvider.selectedAddress!.area}, ${addressProvider.selectedAddress!.city}\nPhone: ${addressProvider.selectedAddress!.phone}',
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressScreen()),
                    ),
                    child: const Text('Change'),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.warning, color: context.colors.offer),
                  title: const Text('No Address Selected'),
                  subtitle:
                      const Text('Add an address to proceed with checkout.'),
                  trailing: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressScreen()),
                    ),
                    child: const Text('Add Address'),
                  ),
                ),
              ),
            ),

          // ── Delivery type ─────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Delivery Type',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.delivery_dining, color: context.colors.primary),
                title: const Text('Home delivery'),
                subtitle: const Text('Expected in 15-30 minutes'),
              ),
            ),
          ),

          // ── Payment ───────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Payment Mode',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: Icon(_getIconForMethod(activeGateway.method),
                    color: context.colors.primary),
                title: Text(
                  activeGateway.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  activeGateway.method == PaymentMethod.cod
                      ? 'Pay cash/UPI at the door'
                      : 'Mock gateway ready',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        PaymentMethodSheet(amount: finalPayable),
                  );
                },
              ),
            ),
          ),

          // ── Coupon section (Only for Cart orders) ─────────────────────────
          if (!_isBuyNow) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Coupons & Offers',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.confirmation_number, color: context.colors.primary),
                  title: Text(
                    couponProvider.appliedCoupon == null
                        ? 'Apply Coupon'
                        : 'Applied: ${couponProvider.appliedCoupon!.couponCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    couponProvider.appliedCoupon == null
                        ? 'Select a coupon code to get discount'
                        : 'Saved ₹${couponProvider.appliedCoupon!.discount.toStringAsFixed(2)} on this order',
                    style: TextStyle(
                      color: couponProvider.appliedCoupon == null
                          ? context.colors.textSecondary
                          : context.colors.primary,
                      fontWeight: couponProvider.appliedCoupon == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  trailing: couponProvider.appliedCoupon == null
                      ? const Icon(Icons.chevron_right)
                      : TextButton(
                          onPressed: () {
                            couponProvider.removeCoupon();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coupon removed')),
                            );
                          },
                          child: Text('Remove',
                              style: TextStyle(color: context.colors.danger)),
                        ),
                  onTap: couponProvider.appliedCoupon == null
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                CouponsBottomSheet(orderAmount: orderTotal),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],

          // ── Total payable ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _billRow(
                      'Total payable',
                      orderTotal,
                    ),
                    if (discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Coupon Discount',
                            style: TextStyle(
                                color: context.colors.primary, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '-₹${discount.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: context.colors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    _billRow(
                      'Final amount to pay',
                      finalPayable,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Place order CTA ───────────────────────────────────────────────
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: (orderProvider.placingOrder ||
                    orderProvider.loading ||
                    addressProvider.loading ||
                    paymentProvider.loading)
                ? null
                : () async {
                    // Validations
                    if (!_isBuyNow && cartProvider.items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your cart is empty.')),
                      );
                      return;
                    }

                    if (addressProvider.selectedAddress == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please select or add a delivery address.')),
                      );
                      return;
                    }

                    // Stock validation before placing order
                    if (!_isBuyNow) {
                      final itemIds = widget.cartItemIds ??
                          cartProvider.items.map((e) => e.id).toList();
                      for (final id in itemIds) {
                        final idx = cartProvider.items
                            .indexWhere((item) => item.id == id);
                        if (idx != -1) {
                          final item = cartProvider.items[idx];
                          if (item.quantity > item.stock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${item.name} is out of stock or has insufficient availability. (Stock: ${item.stock})'),
                              ),
                            );
                            return;
                          }
                        }
                      }
                    }

                    final addressId = addressProvider.selectedAddress!.id;
                    final paymentMethodStr = paymentProvider.selectedMethod
                        .toString()
                        .split('.')
                        .last
                        .toUpperCase();

                    // Step 1: Process Payment via PaymentProvider
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Initiating ${activeGateway.displayName}...')),
                    );

                    final paymentResult = await paymentProvider.processPayment(
                      orderId: 'TEMP_${DateTime.now().millisecondsSinceEpoch}',
                      amount: finalPayable,
                    );

                    if (!context.mounted) return;

                    if (!paymentResult.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(paymentResult.errorMessage ??
                              'Payment failed. Please try again.'),
                          backgroundColor: context.colors.danger,
                        ),
                      );
                      return;
                    }

                    // Step 2: Place order on backend database
                    if (_isBuyNow) {
                      final success = await orderProvider.buyNow(
                        productId: widget.buyNowProductId!,
                        quantity: widget.buyNowQuantity!,
                        addressId: addressId,
                        paymentMethod: paymentMethodStr,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Order placed successfully!')),
                        );

                        // Push order notification
                        final orderId = orderProvider.orders.isNotEmpty
                            ? orderProvider.orders.first.id.toString()
                            : 'new';
                        context.read<NotificationProvider>().notifyOrderUpdate(
                            orderId: orderId, status: 'RECEIVED');

                        couponProvider.removeCoupon();
                        await orderProvider.loadOrders();
                        if (!context.mounted) return;
                        context.read<NavigationProvider>().setTab(3);
                        Navigator.pop(context);
                      } else {
                        final errMsg =
                            orderProvider.error ?? 'Failed to place order';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errMsg)),
                        );
                        if (errMsg.contains('Session Expired') ||
                            errMsg.toLowerCase().contains('unauthorized')) {
                          context.read<AuthProvider>().logout();
                        }
                      }
                    } else {
                      final couponCode =
                          couponProvider.appliedCoupon?.couponCode;
                      final success = await orderProvider.placeOrder(
                        addressId: addressId,
                        paymentMethod: paymentMethodStr,
                        couponCode:
                            (couponCode != null && couponCode.isNotEmpty)
                                ? couponCode
                                : null,
                        cartItemIds: widget.cartItemIds,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Order placed successfully!')),
                        );

                        // Push order notification
                        final orderId = orderProvider.orders.isNotEmpty
                            ? orderProvider.orders.first.id.toString()
                            : 'new';
                        context.read<NotificationProvider>().notifyOrderUpdate(
                            orderId: orderId, status: 'RECEIVED');

                        couponProvider.removeCoupon();
                        cartProvider.clear();
                        await orderProvider.loadOrders();
                        if (!context.mounted) return;
                        context.read<NavigationProvider>().setTab(3);
                        Navigator.pop(context);
                      } else {
                        final errMsg =
                            orderProvider.error ?? 'Failed to place order';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errMsg)),
                        );
                        if (errMsg.contains('Session Expired') ||
                            errMsg.toLowerCase().contains('unauthorized')) {
                          context.read<AuthProvider>().logout();
                        }
                      }
                    }
                  },
            child: (orderProvider.placingOrder || paymentProvider.loading)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMethod(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cod:
        return Icons.handshake_outlined;
      case PaymentMethod.upi:
        return Icons.account_balance_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.wallet:
        return Icons.wallet_outlined;
      default:
        return Icons.payment;
    }
  }

  Widget _billRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value == 0 ? 'FREE' : '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
