import 'package:flutter/material.dart';
import 'package:kisaan_kart_customer_flutter/features/products/productListScreen.dart';

import '../main.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = ['Grains', 'Pulses', 'Vegetables', 'Fruits', 'Others'];
    return ListScreen(title: 'Categories', children: [
      ...categories.map((c) {
        final sub = products.where((p) => p.category == c).map((p) => p.subCategory).toSet().toList();
        return Card(child: ExpansionTile(leading: Text(categoryIcon(c), style: const TextStyle(fontSize: 28)), title: Text(c, style: const TextStyle(fontWeight: FontWeight.w900)), children: [
          ...sub.map((s) => ListTile(title: Text(s), subtitle: Text('${products.where((p) => p.subCategory == s).length} products'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(title: s, products: products.where((p) => p.subCategory == s).toList()))))),
        ]));
      }),
    ]);
  }
}
