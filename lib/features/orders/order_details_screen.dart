import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../api_models/api_order.dart';
import '../../providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/product_utils.dart';

/// Order detail screen — shows order status, address, items, summary, and cancel button.
class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrderProvider>().loadOrder(widget.orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.selectedOrder == null) {
      return const Scaffold(
        body: Center(child: Text('Order not found')),
      );
    }

    final ApiOrder order = provider.selectedOrder!;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Order Timeline Progress ──────────────────────────────────────
          const Text(
            'Order Track Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OrderStatusTimeline(currentStatus: order.orderStatus),
            ),
          ),

          const SizedBox(height: 20),

          // ── Delivery Address ─────────────────────────────────────────────
          const Text(
            'Delivery Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.address.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Phone: ${order.address.phone}'),
                  const SizedBox(height: 4),
                  Text(
                    '${order.address.houseNo}, ${order.address.area}, ${order.address.city}, ${order.address.state} - ${order.address.pincode}',
                  ),
                  if (order.address.landmark != null &&
                      order.address.landmark!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Landmark: ${order.address.landmark}'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Products list ───────────────────────────────────────────────
          const Text(
            'Items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.imageUrl.isEmpty
                      ? const Icon(Icons.image, size: 40)
                      : CachedNetworkImage(
                          imageUrl: sanitizeImageUrl(item.product.imageUrl),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.image, size: 40),
                        ),
                ),
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Text(
                  '₹${(item.quantity * item.price).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Price details summary ────────────────────────────────────────
          const Text(
            'Price Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _priceRow('Price (Total)', order.totalAmount),
                  const SizedBox(height: 8),
                  if (order.couponCode != null &&
                      order.couponCode!.isNotEmpty) ...[
                    _priceRow('Coupon Discount (${order.couponCode})',
                        -order.discountAmount,
                        isDiscount: true),
                    const SizedBox(height: 8),
                  ] else if (order.discountAmount > 0) ...[
                    _priceRow('Discount', -order.discountAmount,
                        isDiscount: true),
                    const SizedBox(height: 8),
                  ],
                  const Divider(height: 24),
                  _priceRow('Final Amount', order.finalAmount, isBold: true),
                  const Divider(height: 24),
                  _infoRow('Payment Method', order.paymentMethod.toUpperCase()),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Payment Status',
                    order.paymentStatus.toUpperCase(),
                    valueColor: order.paymentStatus.toLowerCase() == 'paid'
                        ? context.colors.primary
                        : Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Cancel button (visible only for cancellable statuses)
          if (order.orderStatus.toLowerCase() == 'pending' ||
              order.orderStatus.toLowerCase() == 'confirmed')
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () async {
                final success = await provider.cancelOrder(order.id);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Order Cancelled successfully'
                          : provider.error ?? 'Failed to cancel order',
                    ),
                  ),
                );
              },
              child: const Text('Cancel Order'),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String val, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double val,
      {bool isDiscount = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          isDiscount && val == 0 ? '₹0.00' : '₹${val.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : Colors.black87,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderStatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final status = currentStatus.toLowerCase();

    if (status == 'cancelled') {
      return Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cancelled',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red),
              ),
              Text(
                'Your order was cancelled successfully.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      );
    }

    final steps = [
      'pending',
      'confirmed',
      'packed',
      'out for delivery',
      'delivered'
    ];
    final labels = [
      'Pending',
      'Confirmed',
      'Packed',
      'Out For Delivery',
      'Delivered'
    ];
    final icons = [
      Icons.hourglass_empty,
      Icons.check_circle_outline,
      Icons.inventory_2_outlined,
      Icons.local_shipping_outlined,
      Icons.home_outlined
    ];

    final currentIndex = steps.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final color = isCompleted ? Colors.green : Colors.grey[300]!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isCurrent ? Colors.green : color,
                  child: Icon(
                    icons[index],
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color:
                        index < currentIndex ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                      color: isCurrent
                          ? Colors.black87
                          : isCompleted
                              ? context.colors.primary
                              : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
