import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2B2B2B),
    body: SafeArea(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Card(margin: const EdgeInsets.all(18), color: kBg, child: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [IconButton.filled(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down)), const Spacer(), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.favorite_border)), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.search)), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.share))]),
        Container(height: 260, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Center(child: Text(product.image, style: const TextStyle(fontSize: 130)))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [infoChip(product.tag), infoChip('Shelf life 90 days'), infoChip(product.type), infoChip(product.store)]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.timer_outlined, size: 18), const Text(' 15 mins'), const SizedBox(width: 18), const Icon(Icons.star, color: Colors.amber, size: 18), Text(' ${product.rating} (${product.reviews})')]),
          const SizedBox(height: 10),
          Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(product.unit, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(width: 8), Text('MRP ₹${product.mrp.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black54))]),
          Text('${discount(product)}% OFF on MRP', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900)),
          const Divider(height: 28),
          const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          detailRow('Category', '${product.category} / ${product.subCategory}'),
          detailRow('Origin', product.origin),
          detailRow('Farmer Name', product.farmer),
          detailRow('Process', product.process),
          detailRow('Organic', product.organic ? 'Yes' : 'No'),
        ]))),
      ])),
      Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(product.unit, style: const TextStyle(fontWeight: FontWeight.bold)), Text('₹${product.price.toStringAsFixed(0)}  MRP ₹${product.mrp.toStringAsFixed(0)}') ])), SizedBox(width: 170, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen, padding: const EdgeInsets.all(16)), onPressed: () => appState.add(product), child: Text(appState.qty(product) == 0 ? 'Add to cart' : 'Added: ${appState.qty(product)}')))])),
    ]))))),
  );
}

Widget infoChip(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
Widget detailRow(String a, String b) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text(a, style: const TextStyle(color: Colors.black54))), Expanded(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w700)))]));