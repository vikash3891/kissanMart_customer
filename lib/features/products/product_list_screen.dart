import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/product_utils.dart';
import '../../core/widgets/qty_button.dart';
import '../../core/widgets/search_box.dart';
import '../../core/widgets/shimmer_placeholder.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/compact_product_card.dart';
import '../../models/product.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../api_models/category.dart';
import '../../services/product_analytics_service.dart';
import '../../core/widgets/product_helpers.dart';
import 'product_details_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Product list screen
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen grid of products with an AppBar.
class ProductListScreen extends StatefulWidget {
  final String title;
  final int? initialCategoryId;

  const ProductListScreen({
    super.key,
    required this.title,
    this.initialCategoryId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.clearFilters(notify: false);
      if (widget.initialCategoryId != null) {
        provider.applyCategory(widget.initialCategoryId);
      } else {
        provider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SortBottomSheet(),
    );
  }

  void _showPriceFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PriceFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final hasError = productProvider.error != null;
    final isQueryEmpty = productProvider.searchQuery.isEmpty;

    final activeFilterCount = (productProvider.searchQuery.isNotEmpty ? 1 : 0) +
        (productProvider.categoryId != null ? 1 : 0) +
        (productProvider.minPrice != null || productProvider.maxPrice != null
            ? 1
            : 0) +
        (productProvider.sort != null ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => context.read<NavigationProvider>().setTab(2),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBox(
              initial: productProvider.searchQuery,
              onChanged: productProvider.searchProducts,
            ),
          ),
          // Category chips
          const CategoryChips(),
          const Divider(height: 1),
          // Sort / Filter buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.sort, color: kGreen),
                  label: Text(
                    productProvider.sort != null ? 'Sorted' : 'Sort',
                    style: const TextStyle(
                        color: kGreen, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showSortBottomSheet(context),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              Expanded(
                child: TextButton.icon(
                  icon: Badge(
                    label: Text('$activeFilterCount'),
                    isLabelVisible: activeFilterCount > 0,
                    child: const Icon(Icons.filter_alt, color: kGreen),
                  ),
                  label: Text(
                    (productProvider.minPrice != null ||
                            productProvider.maxPrice != null)
                        ? 'Filtered'
                        : 'Filter',
                    style: const TextStyle(
                        color: kGreen, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showPriceFilterBottomSheet(context),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          // Active filter badges row (Feature 6)
          const ActiveFiltersRow(),
          // Body content
          Expanded(
            child: hasError
                ? ErrorView(
                    error: productProvider.error!,
                    onRetry: () => productProvider.loadProducts(),
                  )
                : (productProvider.isLoading && products.isEmpty)
                    ? const ProductGridSkeleton()
                    : isQueryEmpty
                        ? const AdvancedSearchView()
                        : products.isEmpty
                            ? EmptyStateView(
                                onClear: () => productProvider.clearFilters(),
                              )
                            : RefreshIndicator(
                                onRefresh: productProvider.refresh,
                                color: kGreen,
                                child: CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    SliverPadding(
                                      padding: const EdgeInsets.all(16),
                                      sliver: SliverGrid(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) => ProductCard(
                                            product: products[index],
                                            heroTagPrefix: 'grid_${index}_',
                                          ),
                                          childCount: products.length,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 230,
                                          mainAxisExtent: 285,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                      ),
                                    ),
                                    if (productProvider.isLoadingMore)
                                      const SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                color: kGreen),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chips Widget
// ─────────────────────────────────────────────────────────────────────────────

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categories = categoryProvider.categories;
    final selectedId = productProvider.categoryId;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.applyCategory(null);
                  }
                },
                selectedColor: kGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  productProvider.applyCategory(category.id);
                } else {
                  productProvider.applyCategory(null);
                }
              },
              selectedColor: kGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Filters Row Widget
// ─────────────────────────────────────────────────────────────────────────────

class ActiveFiltersRow extends StatelessWidget {
  const ActiveFiltersRow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final chips = <Widget>[];

    if (provider.searchQuery.isNotEmpty) {
      chips.add(_filterChip(
        'Search: ${provider.searchQuery}',
        () => provider.searchProducts(''),
      ));
    }

    if (provider.categoryId != null) {
      final matchingCategory = categoryProvider.categories.firstWhere(
        (c) => c.id == provider.categoryId,
        orElse: () => Category(id: 0, name: '', description: '', imageUrl: ''),
      );
      if (matchingCategory.name.isNotEmpty) {
        chips.add(_filterChip(
          'Category: ${matchingCategory.name}',
          () => provider.applyCategory(null),
        ));
      }
    }

    if (provider.minPrice != null || provider.maxPrice != null) {
      chips.add(_filterChip(
        'Price: ₹${provider.minPrice?.toStringAsFixed(0) ?? '0'} - ₹${provider.maxPrice?.toStringAsFixed(0) ?? '∞'}',
        () => provider.applyPriceFilter(null, null),
      ));
    }

    if (provider.sort != null) {
      final sortLabel = SortBottomSheet.sortOptions.firstWhere(
        (opt) => opt['value'] == provider.sort,
        orElse: () => {'label': 'Sort', 'value': ''},
      )['label'];
      chips.add(_filterChip(
        'Sort: $sortLabel',
        () => provider.applySorting(null),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...chips,
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Clear All', style: TextStyle(color: Colors.red)),
            onPressed: () => provider.clearFilters(),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onRemove,
        deleteIconColor: Colors.black54,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price Filter Bottom Sheet Widget
// ─────────────────────────────────────────────────────────────────────────────

class PriceFilterBottomSheet extends StatefulWidget {
  const PriceFilterBottomSheet({super.key});

  @override
  State<PriceFilterBottomSheet> createState() => _PriceFilterBottomSheetState();
}

class _PriceFilterBottomSheetState extends State<PriceFilterBottomSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _minController = TextEditingController(
      text: provider.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: provider.maxPrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Price',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min Price (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Price (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<ProductProvider>()
                        .applyPriceFilter(null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kGreen),
                  onPressed: () {
                    final min = double.tryParse(_minController.text);
                    final max = double.tryParse(_maxController.text);
                    context.read<ProductProvider>().applyPriceFilter(min, max);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort Bottom Sheet Widget
// ─────────────────────────────────────────────────────────────────────────────

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  static const List<Map<String, String>> sortOptions = [
    {'label': 'Popularity', 'value': 'popularity'},
    {'label': 'Newest', 'value': 'newest'},
    {'label': 'Price: Low to High', 'value': 'price_asc'},
    {'label': 'Price: High to Low', 'value': 'price_desc'},
    {'label': 'Discount', 'value': 'discount'},
    {'label': 'Name: A-Z', 'value': 'name_asc'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final currentSort = provider.sort;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortOptions.map((opt) {
            final isSelected = currentSort == opt['value'];
            return ListTile(
              title: Text(
                opt['label']!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? kGreen : Colors.black87,
                ),
              ),
              trailing:
                  isSelected ? const Icon(Icons.check, color: kGreen) : null,
              onTap: () {
                context.read<ProductProvider>().applySorting(opt['value']);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Search View Widget
// ─────────────────────────────────────────────────────────────────────────────

class AdvancedSearchView extends StatelessWidget {
  const AdvancedSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final history = provider.searchHistory;
    final recents = provider.recentProducts;

    final trending = ['Wheat', 'Rice', 'Mustard', 'Apple', 'Onion', 'Potato'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Recent Searches
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: provider.clearAllSearchHistory,
                child: const Text('Clear All',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...history.map((q) => Dismissible(
                key: Key('search_history_$q'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteSearchQuery(q),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(q),
                  trailing: const Icon(Icons.north_west, size: 18),
                  onTap: () => provider.searchProducts(q),
                ),
              )),
          const Divider(height: 32),
        ],

        // 2. Trending Searches
        const Text(
          'Trending Searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trending
              .map((tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () => provider.searchProducts(tag),
                  ))
              .toList(),
        ),
        const Divider(height: 32),

        // 3. Recently Viewed
        if (recents.isNotEmpty) ...[
          const Text(
            'Recently Viewed Products',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 130,
                  child: CompactProductCard(product: recents[index]),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card  (shared by HomeScreen and ProductListScreen)
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable product tile shown in grid layouts.
class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroTagPrefix;

  const ProductCard({super.key, required this.product, this.heroTagPrefix});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
            heroTagPrefix: heroTagPrefix ?? 'list_',
          ),
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product image with Hero (Feature 15) ────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kLightGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: '${heroTagPrefix ?? 'list_'}product_image_${product.id}',
                          child: product.image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: sanitizeImageUrl(product.image),
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: ShimmerPlaceholder(
                                      width: double.infinity,
                                      height: double.infinity,
                                      borderRadius: 18,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.image, size: 60),
                                )
                              : const Icon(Icons.image, size: 60),
                        ),
                        // Badge (Feature 11)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: ProductBadge(id: product.id),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Consumer<WishlistProvider>(
                            builder: (context, provider, _) {
                              final isFav = provider.isFavorite(product.id);
                              return CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.9),
                                child: IconButton(
                                  iconSize: 16,
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFav ? Colors.red : Colors.grey[700],
                                  ),
                                  onPressed: () =>
                                      provider.toggleWishlist(product.id),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.9),
                            child: IconButton(
                              iconSize: 16,
                              icon: Icon(Icons.share, color: Colors.grey[700]),
                              onPressed: () {
                                Share.share(
                                    'Check out ${product.name} on Kisaan Kart for ₹${product.price.toStringAsFixed(0)}');
                                ProductAnalyticsService.instance
                                    .shareProduct(product.id, product.name);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Unit + qty button ─────────────────────────────────────────
              Row(
                children: [
                  Text(
                    product.unit,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  QtyButton(p: product),
                ],
              ),

              // ── Price with Hero (Feature 15) ───────────────────────────────
              Hero(
                tag: '${heroTagPrefix ?? 'list_'}product_price_${product.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '₹${product.price.toStringAsFixed(0)} ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              Text(
                '${discount(product)}% OFF • MRP ₹${product.mrp.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // ── Product name with Hero (Feature 15) ────────────────────────
              Hero(
                tag: '${heroTagPrefix ?? 'list_'}product_name_${product.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              Text(
                '${product.type} • ${product.store}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),

              const SizedBox(height: 4),
              // Stock Indicator (Feature 9)
              StockIndicator(
                  stock: product.stock, isAvailable: product.isAvailable),
              const SizedBox(height: 4),

              // ── Delivery time + rating (Feature 10) ────────────────────────
              Row(
                children: [
                  // Delivery ETA Widget
                  Expanded(
                    child: DeliveryEtaWidget(id: product.id),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toString(),
                    style: const TextStyle(fontSize: 12),
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
