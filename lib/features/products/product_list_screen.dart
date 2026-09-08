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
import '../../core/widgets/product_helpers.dart';
import 'product_details_screen.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Product list screen
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
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
    _searchFocusNode.dispose();
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
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: context.colors.textPrimary)),
        actions: [
          IconButton(
            onPressed: () => context.read<NavigationProvider>().setTab(2),
            icon: Icon(Icons.shopping_cart_outlined, color: context.colors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box - compact Flipkart style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: SizedBox(
              height: 40,
              child: SearchBox(
                initial: productProvider.searchQuery,
                focusNode: _searchFocusNode,
                onChanged: productProvider.searchProducts,
              ),
            ),
          ),
          // Category chips - compact
          const CompactCategoryChips(),
          // Sort & Filter bar (Flipkart style) — sits just above the grid
          _SortFilterBar(
            activeFilterCount: activeFilterCount,
            onSort: () => _showSortBottomSheet(context),
            onFilter: () => _showPriceFilterBottomSheet(context),
            isSorted: productProvider.sort != null,
            isFiltered: productProvider.minPrice != null || productProvider.maxPrice != null,
          ),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: hasError
                ? ErrorView(
                    error: productProvider.error!,
                    onRetry: () => productProvider.loadProducts(),
                  )
                : (productProvider.isLoading && products.isEmpty)
                    ? const ProductGridSkeleton()
                    // Show products if available — regardless of search state
                    : products.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: productProvider.refresh,
                            color: context.colors.primary,
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
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
                                      maxCrossAxisExtent: 210,
                                      mainAxisExtent: 280,
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                    ),
                                  ),
                                ),
                                if (productProvider.isLoadingMore)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: context.colors.primary),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        // No products: show search hints when focused, else empty state
                        : _isSearchFocused
                            ? const AdvancedSearchView()
                            : isQueryEmpty
                                ? EmptyStateView(
                                    onClear: () => productProvider.clearFilters(),
                                  )
                                : EmptyStateView(
                                    onClear: () => productProvider.clearFilters(),
                                  ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// Compact Sort & Filter Bar (Flipkart style — sits just above the product grid)
// ────────────────────────────────────────────────────────────────────────────────

class _SortFilterBar extends StatelessWidget {
  final int activeFilterCount;
  final VoidCallback onSort;
  final VoidCallback onFilter;
  final bool isSorted;
  final bool isFiltered;

  const _SortFilterBar({
    required this.activeFilterCount,
    required this.onSort,
    required this.onFilter,
    required this.isSorted,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          // Sort button
          Expanded(
            child: InkWell(
              onTap: onSort,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort,
                    size: 16,
                    color: isSorted ? colors.primary : colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSorted ? FontWeight.bold : FontWeight.w500,
                      color: isSorted ? colors.primary : colors.textSecondary,
                    ),
                  ),
                  if (isSorted) ...[
                    const SizedBox(width: 2),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Vertical divider
          Container(width: 1, height: 18, color: colors.border),
          // Filter button
          Expanded(
            child: InkWell(
              onTap: onFilter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: isFiltered ? colors.primary : colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isFiltered ? FontWeight.bold : FontWeight.w500,
                      color: isFiltered ? colors.primary : colors.textSecondary,
                    ),
                  ),
                  if (activeFilterCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$activeFilterCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// Compact Category Chips (smaller than original, Flipkart style)
// ────────────────────────────────────────────────────────────────────────────────

class CompactCategoryChips extends StatelessWidget {
  const CompactCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categories = categoryProvider.categories;
    final selectedId = productProvider.categoryId;
    final colors = context.colors;

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => productProvider.applyCategory(null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : colors.surface,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => productProvider.applyCategory(isSelected ? null : category.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surface,
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// Category Chips Widget (original — kept for other uses)
// ────────────────────────────────────────────────────────────────────────────────

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
            final colors = context.colors;
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
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedId == category.id;
          final colors = context.colors;

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
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ————————————————————————————————————————————————————————————————————————————————
// Active Filters Row Widget
// ————————————————————————————————————————————————————————————————————————————————

class ActiveFiltersRow extends StatelessWidget {
  const ActiveFiltersRow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final colors = context.colors;

    final chips = <Widget>[];

    if (provider.searchQuery.isNotEmpty) {
      chips.add(_filterChip(
        context,
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
          context,
          'Category: ${matchingCategory.name}',
          () => provider.applyCategory(null),
        ));
      }
    }

    if (provider.minPrice != null || provider.maxPrice != null) {
      chips.add(_filterChip(
        context,
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
        context,
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
            label: Text('Clear All', style: TextStyle(color: colors.danger)),
            onPressed: () => provider.clearFilters(),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, VoidCallback onRemove) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        onDeleted: onRemove,
        deleteIconColor: colors.textSecondary,
        padding: EdgeInsets.zero,
        backgroundColor: colors.surface,
      ),
    );
  }
}

// ————————————————————————————————————————————————————————————————————————————————
// Price Filter Bottom Sheet Widget
// ————————————————————————————————————————————————————————————————————————————————

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
                  child: Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: context.colors.primary),
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

// ————————————————————————————————————————————————————————————————————————————————
// Sort Bottom Sheet Widget
// ————————————————————————————————————————————————————————————————————————————————

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
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
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
                  color: isSelected ? context.colors.primary : context.colors.textPrimary,
                ),
              ),
              trailing:
                  isSelected ? Icon(Icons.check, color: context.colors.primary) : null,
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

// ————————————————————————————————————————————————————————————————————————————————
// Advanced Search View Widget
// ————————————————————————————————————————————————————————————————————————————————

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

// ————————————————————————————————————————————————————————————————————————————————
// Product card (shared by HomeScreen and ProductListScreen)
// Blinkit-inspired: compact image, tight padding, bottom-pinned price+ADD.
// ————————————————————————————————————————————————————————————————————————————————

/// Reusable product tile shown in grid layouts.
/// Blinkit-inspired: compact image, tight padding, bottom-pinned price+ADD.
class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroTagPrefix;

  const ProductCard({super.key, required this.product, this.heroTagPrefix});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cs = Theme.of(context).colorScheme;
    final discountPct = discount(product);
    final tag = heroTagPrefix ?? 'list_';

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 0.5,
      shadowColor: cs.shadow.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              heroTagPrefix: tag,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area (fixed height 140px) ──────────────────────
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background tint for image area
                  Container(
                    color: cs.surfaceContainerLow,
                    padding: const EdgeInsets.all(6),
                    child: Hero(
                      tag: '${tag}product_image_${product.id}',
                      child: product.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: sanitizeImageUrl(product.image, category: product.category),
                              fit: BoxFit.contain,
                              memCacheWidth: 300,
                              fadeInDuration:
                                  const Duration(milliseconds: 200),
                              placeholder: (context, url) =>
                                  const ShimmerPlaceholder(
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 8,
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 36,
                                  color: colors.disabled,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 36,
                                color: colors.disabled,
                              ),
                            ),
                    ),
                  ),
                  // Discount badge (top-left)
                  if (discountPct > 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPct% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist (top-right)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Consumer<WishlistProvider>(
                      builder: (context, provider, _) {
                        final isFav = provider.isFavorite(product.id);
                        return Material(
                          color: cs.surface.withValues(alpha: 0.85),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => provider.toggleWishlist(product.id),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: isFav
                                    ? colors.danger
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // ProductBadge (organic/flash/etc)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: ProductBadge(id: product.id),
                  ),
                ],
              ),
            ),

            // â”€â”€ Info area â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Hero(
                      tag: '${tag}product_name_${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.3,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Unit / weight
                    Text(
                      product.unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 12, color: const Color(0xFFF5A623)),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Price + ADD row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Hero(
                                tag: '${tag}product_price_${product.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              if (discountPct > 0)
                                Text(
                                  '₹${product.mrp.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        QtyButton(p: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
