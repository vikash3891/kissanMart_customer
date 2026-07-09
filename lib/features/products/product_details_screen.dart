import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/product_utils.dart';
import '../../core/widgets/shimmer_placeholder.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/compact_product_card.dart';
import '../../core/widgets/product_helpers.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/product_analytics_service.dart';
import '../cart/checkout_screen.dart';
import '../../models/review.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';

/// Modern Full Screen Product Details Screen (Blinkit/Zepto/Flipkart style).
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? heroTagPrefix;

  const ProductDetailScreen({super.key, required this.product, this.heroTagPrefix});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadSingleProduct(widget.product.id);
      context.read<ReviewProvider>().fetchReviews(widget.product.id);
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final collapsed = _scrollController.offset > 240;
      if (collapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = collapsed;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isPageLoading = provider.isLoading &&
        (provider.selectedProduct == null ||
            provider.selectedProduct!.id != widget.product.id);

    final detailedProduct = provider.selectedProduct ?? widget.product;
    final wishlistProvider = context.watch<WishlistProvider>();
    final isFav = wishlistProvider.isFavorite(detailedProduct.id);

    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.product.name)),
        body: ErrorView(
          error: provider.error!,
          onRetry: () => provider.loadSingleProduct(widget.product.id),
        ),
      );
    }

    if (isPageLoading) {
      return const Scaffold(
        body: ProductDetailSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Slivers AppBar ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                elevation: _isCollapsed ? 1 : 0,
                backgroundColor:
                    _isCollapsed ? Colors.white : Colors.transparent,
                leading: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: _isCollapsed
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back,
                      color: _isCollapsed ? Colors.black87 : Colors.white,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: _isCollapsed
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Hero(
                        tag: '${widget.heroTagPrefix ?? ''}product_wish_${detailedProduct.id}',
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? Colors.red
                              : (_isCollapsed ? Colors.black87 : Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () =>
                        wishlistProvider.toggleWishlist(detailedProduct.id),
                  ),
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: _isCollapsed
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.share,
                        color: _isCollapsed ? Colors.black87 : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Share.share(
                          'Check out ${detailedProduct.name} on Kisaan Kart for ₹${detailedProduct.price.toStringAsFixed(0)}');
                      ProductAnalyticsService.instance.shareProduct(
                          detailedProduct.id, detailedProduct.name);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: '${widget.heroTagPrefix ?? ''}product_image_${detailedProduct.id}',
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(top: 80, bottom: 24),
                            child: detailedProduct.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl:
                                        sanitizeImageUrl(detailedProduct.image),
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) =>
                                        const ShimmerPlaceholder(
                                      width: double.infinity,
                                      height: double.infinity,
                                      borderRadius: 0,
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.image, size: 100),
                                  )
                                : const Icon(Icons.image, size: 100),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 16,
                        child: ProductBadge(id: detailedProduct.id),
                      ),
                      if (!_isCollapsed)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.25, 1.0],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable Details ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 100), // padding bottom for sticky bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag / Store name
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              detailedProduct.store.toUpperCase(),
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (detailedProduct.organic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kLightGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ORGANIC',
                                style: TextStyle(
                                  color: kGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Product Title
                      Hero(
                        tag: '${widget.heroTagPrefix ?? ''}product_name_${detailedProduct.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            detailedProduct.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detailedProduct.unit,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Rating & Delivery ETA Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${detailedProduct.rating}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${detailedProduct.reviews} reviews)',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          const VerticalDivider(width: 1, thickness: 1),
                          const SizedBox(width: 12),
                          DeliveryEtaWidget(id: detailedProduct.id),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price & Discount Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Hero(
                            tag: '${widget.heroTagPrefix ?? ''}product_price_${detailedProduct.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                '₹${detailedProduct.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MRP ₹${detailedProduct.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${discount(detailedProduct)}% OFF',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      StockIndicator(
                          stock: detailedProduct.stock,
                          isAvailable: detailedProduct.isAvailable),

                      const SizedBox(height: 20),

                      // Description Section
                      if (detailedProduct.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detailedProduct.description,
                          style: const TextStyle(
                              fontSize: 14, height: 1.4, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Product Details Table
                      const Text(
                        'Product Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              _detailRow('Shelf Life', '90 Days'),
                              const Divider(height: 16),
                              _detailRow('Weight / Unit', detailedProduct.unit),
                              const Divider(height: 16),
                              _detailRow(
                                  'Country of Origin', detailedProduct.origin),
                              const Divider(height: 16),
                              _detailRow('Brand', detailedProduct.store),
                              const Divider(height: 16),
                              _detailRow('Seller', detailedProduct.farmer),
                            ],
                          ),
                        ),
                      ),

                      // ── Frequently Bought Together ───────────────────────
                      _buildFrequentlyBoughtTogether(
                          context, detailedProduct, provider),

                      // ── Customers Also Bought ────────────────────────────
                      if (provider.customersAlsoBought.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Customers also bought',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.customersAlsoBought.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final p = provider.customersAlsoBought[index];
                              return SizedBox(
                                width: 130,
                                child: CompactProductCard(product: p),
                              );
                            },
                          ),
                        ),
                      ],

                      // ── Similar Products ──────────────────────────────────
                      if (provider.relatedProducts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Similar Products',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.relatedProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final relatedProduct =
                                  provider.relatedProducts[index];
                              return CarouselProductCard(
                                  product: relatedProduct);
                            },
                          ),
                        ),
                      ],

                      // ── Recently Viewed ───────────────────────────────────
                      if (provider.recentProducts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Recently Viewed Products',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.recentProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final recentProduct =
                                  provider.recentProducts[index];
                              return SizedBox(
                                width: 130,
                                child:
                                    CompactProductCard(product: recentProduct),
                              );
                            },
                          ),
                        ),
                      ],

                      // ── Ratings & Reviews ─────────────────────────────────
                      _buildReviewsSection(context, detailedProduct),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Bar ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final qty = cart.qty(detailedProduct);
                  final isOutOfStock = detailedProduct.stock <= 0 ||
                      !detailedProduct.isAvailable;

                  return Row(
                    children: [
                      // Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              detailedProduct.unit,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${detailedProduct.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: kGreen),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${detailedProduct.mrp.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Button CTA
                      if (isOutOfStock)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                          ),
                          onPressed: null,
                          child: const Text('Out of Stock'),
                        )
                      else if (qty == 0) ...[
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kGreen,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          onPressed: () {
                            cart.add(detailedProduct);
                            ProductAnalyticsService.instance.addToCart(
                                detailedProduct.id, detailedProduct.name, 1);
                          },
                          child: const Text('Add to Cart'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  buyNowProductId: detailedProduct.id,
                                  buyNowQuantity: 1,
                                  buyNowProductPrice: detailedProduct.price,
                                ),
                              ),
                            );
                          },
                          child: const Text('Buy Now'),
                        ),
                      ] else ...[
                        // Quantity Selector
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: kGreen, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: kGreen, size: 20),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    cart.removeItem(detailedProduct.id),
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: kGreen),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: kGreen, size: 20),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                constraints: const BoxConstraints(),
                                onPressed: () => cart.add(detailedProduct),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kGreen,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                          ),
                          onPressed: () {
                            context.read<NavigationProvider>().setTab(2);
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          child: const Text('Go to Cart'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FBT section helper (Feature 1) ────────────────────────────────────────

  Widget _buildFrequentlyBoughtTogether(
      BuildContext context, Product detailedProduct, ProductProvider provider) {
    final sameCategoryProducts = provider.products
        .where((p) =>
            p.id != detailedProduct.id &&
            p.category == detailedProduct.category)
        .take(2)
        .toList();

    if (sameCategoryProducts.isEmpty) return const SizedBox.shrink();

    final totalFbtPrice = detailedProduct.price +
        sameCategoryProducts.fold(0.0, (sum, p) => sum + p.price);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 24),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Bought Together',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _fbtItemImage(detailedProduct.image),
                const Icon(Icons.add, color: Colors.grey),
                ...sameCategoryProducts.expand((p) => [
                      _fbtItemImage(p.image),
                      if (p != sameCategoryProducts.last)
                        const Icon(Icons.add, color: Colors.grey),
                    ]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bundle price',
                        style: TextStyle(color: Colors.black54)),
                    Text(
                      '₹${totalFbtPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kGreen),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kGreen),
                  onPressed: () {
                    final cart = context.read<CartProvider>();
                    cart.add(detailedProduct);
                    for (final p in sameCategoryProducts) {
                      cart.add(p);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added bundle to cart!')),
                    );
                  },
                  child: const Text('Add Bundle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fbtItemImage(String url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: sanitizeImageUrl(url), fit: BoxFit.contain)
            : const Icon(Icons.image),
      ),
    );
  }

  // ─── Product Reviews Section ──────────────────────────────────────────────

  Widget _buildReviewsSection(BuildContext context, Product detailedProduct) {
    final reviewProvider = context.watch<ReviewProvider>();
    final authProvider = context.watch<AuthProvider>();
    final loggedIn = authProvider.loggedIn;
    final currentUserPhone = authProvider.currentUser?['phone'] as String?;
    final currentUserId = authProvider.currentUser?['id'] as int?;

    final response = reviewProvider.reviewsResponse;

    if (reviewProvider.loading && response == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ratings & Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    final avgRating = response?.averageRating ?? 0.0;
    final totalReviews = response?.totalReviews ?? 0;
    final reviewsList = response?.reviews ?? [];
    final filteredList = reviewProvider.filteredReviews;

    ReviewModel? userReview;
    for (final r in reviewsList) {
      if (loggedIn &&
          (r.phone == currentUserPhone || r.userId == currentUserId)) {
        userReview = r;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (loggedIn)
              TextButton.icon(
                onPressed: () => _openReviewSheet(context, detailedProduct.id,
                    review: userReview),
                icon: Icon(userReview != null ? Icons.edit : Icons.rate_review,
                    color: kGreen),
                label: Text(
                  userReview != null ? 'Edit Review' : 'Write Review',
                  style: const TextStyle(
                      color: kGreen, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews Reviews',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _starRow(
                        5,
                        totalReviews > 0
                            ? ((response?.starCounts[5] ?? 0) / totalReviews)
                            : 0.0),
                    _starRow(
                        4,
                        totalReviews > 0
                            ? ((response?.starCounts[4] ?? 0) / totalReviews)
                            : 0.0),
                    _starRow(
                        3,
                        totalReviews > 0
                            ? ((response?.starCounts[3] ?? 0) / totalReviews)
                            : 0.0),
                    _starRow(
                        2,
                        totalReviews > 0
                            ? ((response?.starCounts[2] ?? 0) / totalReviews)
                            : 0.0),
                    _starRow(
                        1,
                        totalReviews > 0
                            ? ((response?.starCounts[1] ?? 0) / totalReviews)
                            : 0.0),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Sort & Filter Row
        if (reviewsList.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PopupMenuButton<String>(
                  initialValue: reviewProvider.selectedFilter,
                  onSelected: reviewProvider.setFilter,
                  itemBuilder: (context) => [
                    'All Stars',
                    '5 Stars',
                    '4 Stars',
                    '3 Stars',
                    '2 Stars',
                    '1 Star',
                    'With Photos'
                  ]
                      .map((val) => PopupMenuItem(value: val, child: Text(val)))
                      .toList(),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Filter: ${reviewProvider.selectedFilter}'),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: reviewProvider.selectedSort,
                  onSelected: reviewProvider.setSort,
                  itemBuilder: (context) => [
                    'Most Recent',
                    'Highest Rating',
                    'Lowest Rating',
                    'Most Helpful'
                  ]
                      .map((val) => PopupMenuItem(value: val, child: Text(val)))
                      .toList(),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Sort: ${reviewProvider.selectedSort}'),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (filteredList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                reviewsList.isEmpty
                    ? 'No Reviews Yet'
                    : 'No matching reviews found',
                style: const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final r = filteredList[index];
              final isOwnReview = loggedIn &&
                  (r.phone == currentUserPhone || r.userId == currentUserId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (starIdx) {
                          return Icon(
                            starIdx < r.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      if (isOwnReview)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 18, color: Colors.blue),
                              onPressed: () => _openReviewSheet(
                                  context, detailedProduct.id,
                                  review: r),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              onPressed: () => _showDeleteReviewConfirm(
                                  context, r.id, detailedProduct.id),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        r.phone == currentUserPhone
                            ? 'Yash Sharma'
                            : (r.phone.length > 5
                                ? '${r.phone.substring(0, 5)}*****'
                                : r.phone),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (r.isVerified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.green[200]!, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 10, color: Colors.green[700]),
                              const SizedBox(width: 2),
                              Text(
                                'Verified Purchase',
                                style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatReviewDate(r.createdAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.comment,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (r.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: r.photoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        sanitizeImageUrl(r.photoUrls[idx]),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: sanitizeImageUrl(r.photoUrls[idx]),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => reviewProvider.upvoteReview(r.id),
                        icon: const Icon(Icons.thumb_up_outlined, size: 12),
                        label: Text('Helpful (${r.helpfulVotes})',
                            style: const TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _starRow(int stars, double fillPercent) {
    return Row(
      children: [
        Text('$stars',
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 10),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          height: 4,
          child: LinearProgressIndicator(
            value: fillPercent.isNaN ? 0.0 : fillPercent,
            backgroundColor: Colors.grey[200],
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  String _formatReviewDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _openReviewSheet(BuildContext context, int productId,
      {ReviewModel? review}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _ReviewFormSheet(productId: productId, review: review),
    );
  }

  void _showDeleteReviewConfirm(
      BuildContext context, int reviewId, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context
          .read<ReviewProvider>()
          .deleteReview(reviewId, productId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review Deleted'),
            backgroundColor: kGreen,
          ),
        );
      } else if (mounted) {
        final error =
            context.read<ReviewProvider>().error ?? 'Failed to delete review';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carousel Product Card (Feature 3)
// ─────────────────────────────────────────────────────────────────────────────

class CarouselProductCard extends StatelessWidget {
  final Product product;
  const CarouselProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        child: Container(
          width: 155,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kLightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: sanitizeImageUrl(product.image),
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const Center(
                                  child: ShimmerPlaceholder(
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: 12,
                                  ),
                                ),
                              )
                            : const Icon(Icons.image),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Consumer<WishlistProvider>(
                        builder: (context, provider, _) {
                          final isFav = provider.isFavorite(product.id);
                          return CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.9),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 14,
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey[700],
                              ),
                              onPressed: () =>
                                  provider.toggleWishlist(product.id),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: ProductBadge(id: product.id),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: kGreen),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 28,
                    child: Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        final qty = cart.qty(product);
                        return qty == 0
                            ? TextButton(
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => cart.add(product),
                                child: const Text('ADD',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Form Bottom Sheet Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewFormSheet extends StatefulWidget {
  final int productId;
  final ReviewModel? review;

  const _ReviewFormSheet({required this.productId, this.review});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  double _rating = 5.0;
  late final TextEditingController _commentController;
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 5.0;
    _commentController =
        TextEditingController(text: widget.review?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 600,
      );

      if (picked != null) {
        setState(() {
          _selectedImages.add(File(picked.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage(int idx) {
    setState(() {
      _selectedImages.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final isEdit = widget.review != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Review' : 'Write a Review',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Rating Selection Stars
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Comment
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Share details of your experience with this product...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Photos Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attach Photos (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedImages.length}/5',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Photos Selector / Previews
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  if (idx == _selectedImages.length) {
                    if (_selectedImages.length >= 5)
                      return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final file = _selectedImages[idx];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(idx),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: provider.submitting
                  ? null
                  : () async {
                      final comment = _commentController.text.trim();

                      // Submit review (backend receives the rating and comment; selected local images are stored/simulated)
                      final success = isEdit
                          ? await provider.updateReview(widget.review!.id,
                              _rating, comment, widget.productId)
                          : await provider.addReview(
                              widget.productId, _rating, comment);

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                isEdit ? 'Review Updated' : 'Review Added'),
                            backgroundColor: kGreen,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(provider.error ?? 'Submission failed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: provider.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Update Review' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
