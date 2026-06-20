import 'package:flutter/material.dart';
import 'package:kisaan_kart_customer_flutter/features/products/productListScreen.dart';

import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = ['Grains', 'Pulses', 'Vegetables', 'Fruits', 'Others'];
    final list = appState.filteredProducts;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5FFD8), Color(0xFFFFE5C8)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kisaan Kart in', style: TextStyle(fontWeight: FontWeight.w800)), Text('15 minutes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)), Text('HOME - Floor 4th, Room 403 ▼') ])),
            IconButton.filledTonal(onPressed: () => appState.setTab(2), icon: const Icon(Icons.shopping_cart_outlined)),
            IconButton.filledTonal(onPressed: () => appState.setTab(4), icon: const Icon(Icons.person_outline)),
          ]),
          const SizedBox(height: 14),
          SearchBox(initial: appState.searchQuery, onChanged: appState.setSearch),
          /*const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(
                      title: categories[i],
                      products: products.where((p) => p.category == categories[i]).toList(),
                    ),
                  ),
                ), // Added missing closing brackets here
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        categoryIcon(categories[i]),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categories[i],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),*/
        ]),
      )),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PromoBanner(),
        const SizedBox(height: 0),
        /*sectionTitle(appState.searchQuery.isEmpty ? 'Shop by Category' : 'Search Results'),
        if (appState.searchQuery.isEmpty) CategoryGrid(categories: categories),
        const SizedBox(height: 10),*/
        sectionTitle(appState.searchQuery.isEmpty ? 'Frequently bought' : '${list.length} products found'),
      ]))),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverGrid(delegate: SliverChildBuilderDelegate((context, index) => ProductCard(product: list[index]), childCount: list.length), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, mainAxisExtent: 285, crossAxisSpacing: 12, mainAxisSpacing: 12)),
      ),
    ]);
  }
}
