import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../products/product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.watch<CartProvider>();
    final favorites = wishlistProvider.wishlistItems;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Wishlist'),
                    content: const Text(
                        'Are you sure you want to remove all items from your wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await wishlistProvider.removeAll();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wishlist cleared')),
                          );
                        },
                        child: const Text('Clear All',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _buildBody(wishlistProvider, cartProvider, favorites),
    );
  }

  Widget _buildBody(WishlistProvider wishlistProvider,
      CartProvider cartProvider, List<Product> favorites) {
    if (wishlistProvider.loading) {
      return const LoadingWidget(message: 'Loading your favorites...');
    }

    if (favorites.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'Your wishlist is empty',
        subtitle:
            'Explore products and tap the heart icon to save your favorites here!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => wishlistProvider.loadWishlist(),
      color: kGreen,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 310,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final product = favorites[index];
          return _WishlistProductCard(
            product: product,
            wishlistProvider: wishlistProvider,
            cartProvider: cartProvider,
          );
        },
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final Product product;
  final WishlistProvider wishlistProvider;
  final CartProvider cartProvider;

  const _WishlistProductCard({
    required this.product,
    required this.wishlistProvider,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kLightGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        product.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.image,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.image, size: 40),
                              )
                            : const Center(child: Icon(Icons.image, size: 40)),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.9),
                            child: IconButton(
                              iconSize: 16,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => _removeFromWishlist(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),

              // Unit
              Text(
                product.unit,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 8),

              // Price and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kDark),
                      ),
                      if (product.mrp > product.price)
                        Text(
                          '₹${product.mrp.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _moveToCart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(60, 32),
                    ),
                    child: const Text('Move to Cart',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeFromWishlist(BuildContext context) async {
    final success = await wishlistProvider.removeFromWishlist(product.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${product.name} from wishlist'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.orange[300],
            onPressed: () {
              wishlistProvider.addToWishlist(product.id);
            },
          ),
        ),
      );
    }
  }

  void _moveToCart(BuildContext context) async {
    final added = await cartProvider.addToCart(
      productId: product.id,
      quantity: 1,
      name: product.name,
      price: product.mrp,
      discountPrice: product.price,
      imageUrl: product.image,
      stock: product.stock,
    );
    if (added) {
      await wishlistProvider.removeFromWishlist(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved ${product.name} to Cart'),
            backgroundColor: kGreen,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                await cartProvider.addToCart(
                  productId: product.id,
                  quantity: -1, // Subtract quantity
                );
                await wishlistProvider.addToWishlist(product.id);
              },
            ),
          ),
        );
      }
    }
  }
}
