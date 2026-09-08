import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisaan_kart_customer/providers/product_provider.dart';
import 'package:kisaan_kart_customer/providers/category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = ProductProvider();
  
  print('Initial categoryId: ${provider.categoryId}');
  provider.clearFilters(notify: false);
  provider.applyCategory(2);
  print('After applyCategory(2), categoryId: ${provider.categoryId}');
}
