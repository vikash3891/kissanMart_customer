import 'package:flutter/material.dart';
import 'package:kisaan_kart_customer_flutter/features/products/productDetails.dart';

import '../../main.dart';
import '../../models/product.dart';

class ProductListScreen extends StatelessWidget {
  final String title;
  final List<Product> products;
  const ProductListScreen({super.key, required this.title, required this.products});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: [IconButton(onPressed: () => appState.setTab(2), icon: const Icon(Icons.shopping_cart_outlined))]),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, mainAxisExtent: 285, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
    child: Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: kLightGreen, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(product.image, style: const TextStyle(fontSize: 54))))),
      const SizedBox(height: 8),
      Row(children: [Text(product.unit, style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), QtyButton(p: product)]),
      Text('₹${product.price.toStringAsFixed(0)} ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      Text('${discount(product)}% OFF • MRP ₹${product.mrp.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w800)),
      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
      Text('${product.type} • ${product.store}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      Row(children: [const Icon(Icons.timer_outlined, size: 14, color: Colors.black54), const Text(' 15 mins', style: TextStyle(fontSize: 12)), const Spacer(), const Icon(Icons.star, size: 14, color: Colors.amber), Text(product.rating.toString(), style: const TextStyle(fontSize: 12))]),
    ]))),
  );
}