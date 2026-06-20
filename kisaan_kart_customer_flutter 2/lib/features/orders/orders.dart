import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/orderItem.dart';
import '../products/productDetails.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Your orders', children: appState.orders.map((o) => Card(child: ListTile(leading: const CircleAvatar(backgroundColor: kLightGreen, child: Icon(Icons.check, color: kGreen)), title: Text(o.status, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('₹${o.total.toStringAsFixed(0)} • ${o.date}\n${o.products.map((p) => p.image).join('  ')}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)))))).toList());
}

class OrderDetailScreen extends StatelessWidget {
  final OrderItem order;
  const OrderDetailScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Order #${order.id}', children: [
    Text(order.status, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    Text(order.date),
    const SizedBox(height: 12),
    ...order.products.map((p) => Card(child: ListTile(leading: Text(p.image, style: const TextStyle(fontSize: 32)), title: Text(p.name), subtitle: Text('${p.unit} • ${p.store}',), trailing: Text('₹${p.price.toStringAsFixed(0)}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)))))),
    FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen), onPressed: () { for (final p in order.products) { appState.add(p); } appState.setTab(2); Navigator.pop(context); }, child: const Text('Reorder')),
    OutlinedButton(onPressed: () {}, child: const Text('Rate order')),
  ]);
}