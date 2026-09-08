import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qty_button.dart';
import '../../core/widgets/compact_product_card.dart';
import '../../core/utils/product_utils.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../products/product_details_screen.dart';
import 'checkout_screen.dart';

/// Cart tab — shows cart items, bill summary, and checkout CTA.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _showClearCartConfirm(
      BuildContext context, CartProvider cartProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: context.colors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await cartProvider.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartItems = cartProvider.items;

    // ── Empty state ─────────────────────────────────────────────────────────
    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const Center(
              child: Column(
                children: [
                  Text('🛒', style: TextStyle(fontSize: 72)),
                  Text(
                    'Your cart is empty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Add organic staples and fresh groceries.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary),
                onPressed: () => context.read<NavigationProvider>().setTab(0),
                child: const Text('Start Shopping'),
              ),
            ),
            const SizedBox(height: 24),
            _savedForLaterSection(context, cartProvider),
          ],
        ),
      );
    }

    // ── Cart with items ─────────────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.delete_sweep, color: context.colors.danger),
            label: Text('Clear Cart',
                style: TextStyle(color: context.colors.danger)),
            onPressed: () => _showClearCartConfirm(context, cartProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => cartProvider.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (cartProvider.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                color: context.colors.danger.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: context.colors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartProvider.error!,
                        style: TextStyle(color: context.colors.danger),
                      ),
                    ),
                  ],
                ),
              ),

            // Cart item rows
            ...cartItems.map(
              (item) {
                // Map ApiCartItem back to Product class for QtyButton compatibility
                final p = Product(
                  id: item.productId,
                  store: '',
                  name: item.name,
                  category: '',
                  subCategory: '',
                  type: '',
                  image: item.imageUrl,
                  unit: 'Unit',
                  price: item.discountPrice,
                  mrp: item.price,
                  rating: 4.5,
                  reviews: 0,
                  tag: '',
                  origin: '',
                  farmer: '',
                  process: '',
                  organic: true,
                  stock: item.stock,
                  isAvailable: item.stock > 0,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: cartProvider.selectedCartItemIds
                                .contains(item.id),
                            onChanged: (_) =>
                                cartProvider.toggleSelection(item.id),
                            activeColor: context.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          item.imageUrl.isEmpty
                              ? const Icon(Icons.image)
                              : CachedNetworkImage(
                                  imageUrl: sanitizeImageUrl(item.imageUrl),
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) =>
                                      const CircularProgressIndicator(
                                          strokeWidth: 2),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.image),
                                ),
                        ],
                      ),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${item.discountPrice.toStringAsFixed(0)} x ${item.quantity}',
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => cartProvider.saveForLater(p),
                            child: Text(
                              'Save for later',
                              style: TextStyle(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: QtyButton(p: p),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Bill summary
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _billRow(
                        'Item total',
                        cartProvider.subtotal,
                      ),
                      _billRow(
                        'Delivery fee',
                        cartProvider.deliveryFee,
                      ),
                      _billRow(
                        'Handling charge',
                        cartProvider.handling,
                      ),
                      _billRow(
                        'GST 5%',
                        cartProvider.gst,
                      ),
                      const Divider(),
                      _billRow(
                        'To pay',
                        cartProvider.total,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Proceed to Checkout CTA
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: cartProvider.selectedCartItemIds.isEmpty
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItemIds:
                                cartProvider.selectedCartItemIds.toList(),
                          ),
                        ),
                      ),
              child: const Text('Proceed to Checkout'),
            ),

            // Continue Shopping Section (Feature 7)
            if (productProvider.recentProducts.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProvider.recentProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 130,
                      child: CompactProductCard(
                        product: productProvider.recentProducts[index],
                      ),
                    );
                  },
                ),
              ),
            ],

            // Saved For Later list under the items
            _savedForLaterSection(context, cartProvider),
          ],
        ),
      ),
    );
  }

  Widget _savedForLaterSection(
      BuildContext context, CartProvider cartProvider) {
    if (cartProvider.savedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Saved For Later',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...cartProvider.savedProducts.map(
          (p) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: p.image.isEmpty
                  ? const Icon(Icons.image)
                  : CachedNetworkImage(
                      imageUrl: sanitizeImageUrl(p.image),
                      width: 55,
                      height: 55,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    ),
              title: Text(p.name),
              subtitle: Text('${p.unit} • ₹${p.price.toStringAsFixed(0)}'),
              trailing: TextButton.icon(
                icon: Icon(Icons.add_shopping_cart,
                    color: context.colors.primary, size: 18),
                label: Text(
                  'Move to Cart',
                  style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () => cartProvider.moveToCart(p),
              ),
            ),
          ),
        ),
      ],
    );
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
