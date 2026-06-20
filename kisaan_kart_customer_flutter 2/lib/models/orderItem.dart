import 'package:kisaan_kart_customer_flutter/models/product.dart';

class OrderItem {
  final int id;
  final String status;
  final String date;
  final double total;
  final List<Product> products;
  const OrderItem({required this.id, required this.status, required this.date, required this.total, required this.products});
}