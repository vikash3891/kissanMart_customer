import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/order_provider.dart';
import 'order_details_screen.dart';

/// Orders tab — fetches and displays the user's order history.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrderProvider>().loadOrders(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'packed':
        return Colors.purple;
      case 'out for delivery':
      case 'delivered':
        return kGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final local = dt.toLocal();
    final hour =
        local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Your Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: kDark,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : provider.orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text('No orders found yet!',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text(
                              'Grab some fresh groceries to get started.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: provider.loadOrders,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: provider.orders.length,
                        itemBuilder: (context, index) {
                          final order = provider.orders[index];
                          final statusColor =
                              _getStatusColor(order.orderStatus);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(color: Colors.grey[100]!),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailsScreen(orderId: order.id),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Row 1: Order ID and Amount
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${order.id}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          '₹${order.finalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: kDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Row 2: Date
                                    Text(
                                      _formatDate(order.createdAt),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    // Row 3: Product image list / previews
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: order.items.take(4).map((item) {
                                            return Container(
                                              width: 54,
                                              height: 54,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFF3F4F8)),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: item.product.imageUrl
                                                        .isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl: item
                                                            .product.imageUrl,
                                                        fit: BoxFit.cover,
                                                        placeholder: (_, __) =>
                                                            const Center(
                                                          child: SizedBox(
                                                            width: 14,
                                                            height: 14,
                                                            child:
                                                                CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1.5),
                                                          ),
                                                        ),
                                                        errorWidget: (_, __,
                                                                ___) =>
                                                            const Icon(
                                                                Icons.image,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey),
                                                      )
                                                    : const Icon(Icons.image,
                                                        size: 20,
                                                        color: Colors.grey),
                                              ),
                                            );
                                          }).toList() +
                                          [
                                            if (order.items.length > 4)
                                              Container(
                                                width: 54,
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF3F4F8),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFE5E7EB)),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '+${order.items.length - 4}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                              )
                                          ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    // Row 4: Statuses badges
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                                alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            order.orderStatus.toUpperCase(),
                                            style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Text(
                                          'Payment: ${order.paymentMethod.toUpperCase()} (${order.paymentStatus.toUpperCase()})',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
