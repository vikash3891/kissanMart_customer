import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/widgets/search_box.dart';
import '../../core/widgets/shimmer_placeholder.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/compact_product_card.dart';
import '../../core/widgets/product_helpers.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/address_provider.dart';
import '../../api_models/api_banner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/product_utils.dart';
import '../products/product_list_screen.dart';
import '../address/address_screen.dart';

/// Home tab.
///
/// Shows:
///  • delivery header + search bar
///  • horizontal category scroller (API-driven)
///  • dynamic sliding promo banners (API-driven, auto-scrolling)
///  • trending & offer products (API-driven)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeProvider = context.read<HomeProvider>();
      await homeProvider.loadHomeData();

      // Pre-cache banners and category icons to eliminate flicker
      if (mounted) {
        final banners = homeProvider.banners;
        final categories = homeProvider.categories.where((category) =>
            category.name.toLowerCase() != 'grains').toList();

        for (final b in banners) {
          if (b.imageUrl.isNotEmpty) {
            precacheImage(
              CachedNetworkImageProvider(b.imageUrl),
              context,
            ).ignore();
          }
        }
        for (final c in categories) {
          if (c.imageUrl.isNotEmpty) {
            precacheImage(
              CachedNetworkImageProvider(c.imageUrl),
              context,
            ).ignore();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final categories = homeProvider.categories.where((category) =>
        category.name.toLowerCase() != 'grains').toList();
    final trendingProducts = homeProvider.trendingProducts;
    final offerProducts = homeProvider.offerProducts;
    final homeHasError = homeProvider.error != null;

    final isSearching = productProvider.searchQuery.isNotEmpty;
    final searchProducts = productProvider.products;
    final searchHasError = productProvider.error != null;

    return RefreshIndicator(
      onRefresh: () => isSearching
          ? productProvider.searchProducts(productProvider.searchQuery)
          : homeProvider.loadHomeData(),
      child: CustomScrollView(
        slivers: [
          // ── Header (gradient + search + category strip) ────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(18, topPadding + 18, 18, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [colors.card, colors.surface.withValues(alpha: 0.95)]
                      : const [Color(0xFFE5FFD8), Color(0xFFFFE5C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Branding + Address Row ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🛒 Kisaan Kart Branding
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_basket_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kisaan Kart',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // 📍 Deliver To — tappable address block
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressScreen(),
                            ),
                          );
                          // Auto-refresh: AddressProvider is global, state
                          // updates propagate automatically when returned.
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colors.surface
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Builder(builder: (context) {
                            final addr = addressProvider.selectedAddress;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 12, color: colors.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Deliver To',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    Text(
                                      addr != null
                                          ? (addr.addressType.isNotEmpty
                                              ? '${addr.addressType[0].toUpperCase()}${addr.addressType.substring(1)}'
                                              : 'Home')
                                          : 'Select Address',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: addr != null
                                            ? colors.textPrimary
                                            : colors.primary,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded,
                                        size: 16, color: colors.textSecondary),
                                  ],
                                ),
                                if (addr != null)
                                  Text(
                                    '${addr.houseNo}, ${addr.area}'.length > 20
                                        ? '${'${addr.houseNo}, ${addr.area}'.substring(0, 20)}…'
                                        : '${addr.houseNo}, ${addr.area}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Search — debounced + onSubmitted → ProductProvider.search() → API
                  SizedBox(
                    height: 44,
                    child: SearchBox(
                      initial: productProvider.searchQuery,
                      onChanged: productProvider.searchProducts,
                    ),
                  ),

                  // Only show Category strip on home if not searching
                  if (!isSearching) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Shop by Category',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Category horizontal scroll
                    SizedBox(
                      height: 120,
                      child: homeProvider.loading && categories.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return InkWell(
                                  onTap: () {
                                    context.read<ProductProvider>().applyCategory(category.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductListScreen(
                                          title: category.name,
                                          initialCategoryId: category.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colors.skeleton,
                                        ),
                                        child: ClipOval(
                                          child: category.imageUrl.isEmpty
                                              ? Icon(Icons.category,
                                                  color: context.colors.disabled)
                                              : CachedNetworkImage(
                                                  imageUrl: sanitizeImageUrl(category.imageUrl, category: category.name),
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Icon(Icons.category,
                                                          color: context.colors.disabled),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 75,
                                        child: Text(
                                          category.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Dashboard Sections (only if not searching) ──────────────────────
          if (!isSearching) ...[
            // ── Banners & Countdown ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (homeProvider.loading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerPlaceholder(
                          width: double.infinity,
                          height: 150,
                          borderRadius: 16),
                    )
                  else if (homeProvider.banners.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: BannerCarousel(banners: homeProvider.banners),
                    ),
                  // No whitespace padding or spacing reserved if banners list is empty
                  const SizedBox(height: 12),
                  const Center(child: FlashSaleTimer()),
                ],
              ),
            ),

            // ── Trending products list ──
            if (trendingProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trending Products',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 290,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: trendingProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 160,
                              child: ProductCard(
                                product: trendingProducts[index],
                                heroTagPrefix: 'trending_${index}_',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Special Offers list ──
            if (offerProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Offers',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: offerProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 210,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: offerProducts[index],
                              heroTagPrefix: 'offers_${index}_',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Buy Again Section ──
            if (orderProvider.recentPurchases.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buy Again',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderProvider.recentPurchases.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 130,
                              child: CompactProductCard(
                                product: orderProvider.recentPurchases[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

            // ── Main Content / Error Area ──
            if (homeHasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  error: homeProvider.error!,
                  onRetry: () => homeProvider.loadHomeData(),
                ),
              )
            else if (homeProvider.loading && categories.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: ProductGridSkeleton(isSliver: true),
              )
            else if (!homeProvider.loading && categories.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No data available'),
                ),
              ),
          ] else ...[
            // ── Search Results Slivers ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Search Results for "${productProvider.searchQuery}"',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (productProvider.isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.colors.primary),
                      ),
                  ],
                ),
              ),
            ),

            if (searchHasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  error: productProvider.error!,
                  onRetry: () => productProvider
                      .searchProducts(productProvider.searchQuery),
                ),
              )
            else if (productProvider.isLoading && searchProducts.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: ProductGridSkeleton(isSliver: true),
              )
            else if (searchProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  message:
                      'No products found matching "${productProvider.searchQuery}"',
                  onClear: () => productProvider.searchProducts(''),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 210,
                      mainAxisExtent: 280,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: searchProducts[index],
                          heroTagPrefix: 'search_${index}_',
                        );
                      },
                      childCount: searchProducts.length,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  final List<ApiBanner> banners;
  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;
  late PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
    _logBannerDiagnostics();
  }

  /// Logs each banner's URL to the debug console for diagnostics.
  void _logBannerDiagnostics() {
    debugPrint('[BannerCarousel] Loaded ${widget.banners.length} banner(s):');
    for (final b in widget.banners) {
      final isBroken = isBrokenImageUrl(b.imageUrl);
      final sanitized = sanitizeImageUrl(b.imageUrl, seed: b.id);
      debugPrint(
        '[BannerCarousel] id=${b.id} title="${b.title}" '
        'imageUrl="${b.imageUrl}" '
        'isBroken=$isBroken '
        'resolvedUrl="$sanitized"',
      );
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.banners.isEmpty) return;
      final nextPage = (_current + 1) % widget.banners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (idx) => setState(() => _current = idx),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                final resolvedUrl =
                    sanitizeImageUrl(banner.imageUrl, seed: banner.id);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    // Loading shimmer
                    placeholder: (context, url) => const ShimmerPlaceholder(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 16,
                    ),
                    // Error: show beautiful grocery-themed banner
                    errorWidget: (context, url, error) {
                      debugPrint(
                        '[BannerCarousel] ❌ Image load failed!\n'
                        '  banner.id    = ${banner.id}\n'
                        '  banner.title = "${banner.title}"\n'
                        '  original url = "${banner.imageUrl}"\n'
                        '  resolved url = "$url"\n'
                        '  error        = $error',
                      );
                      return _GroceryBannerPlaceholder(
                        title: banner.title,
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Animated page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: _current == index ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _current == index
                    ? context.colors.primary
                    : context.colors.primary.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Beautiful grocery-themed fallback banner shown when an image fails to load.
/// Displays a gradient background with the banner title and a grocery icon.
class _GroceryBannerPlaceholder extends StatelessWidget {
  final String title;
  final int index;

  const _GroceryBannerPlaceholder({
    required this.title,
    required this.index,
  });

  static const _gradients = [
    [Color(0xFF168A3A), Color(0xFF0D5C28)], // Deep green
    [Color(0xFF2E7D32), Color(0xFF1B5E20)], // Forest green
    [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Medium green
    [Color(0xFF1976D2), Color(0xFF0D47A1)], // Blue
    [Color(0xFFE65100), Color(0xFFBF360C)], // Orange
  ];

  static const _icons = [
    Icons.local_grocery_store_rounded,
    Icons.eco_rounded,
    Icons.breakfast_dining_rounded,
    Icons.spa_rounded,
    Icons.agriculture_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final gradientColors = _gradients[index % _gradients.length];
    final icon = _icons[index % _icons.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SPECIAL OFFER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title.isNotEmpty ? title : 'Fresh Groceries',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Fresh • Organic • Delivered Fast',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Shop Now →',
                          style: TextStyle(
                            color: gradientColors[0],
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  icon,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

