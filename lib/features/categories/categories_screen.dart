import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../products/product_list_screen.dart';

/// Categories tab.
///
/// Displays all API categories as a list.
/// Tapping a category navigates to [ProductListScreen] with the selected category filter.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: Center(child: Text(provider.error!)),
      );
    }

    if (provider.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: const Center(child: Text('No categories found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(category.imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(category.description),
                trailing: const Icon(Icons.chevron_right),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
