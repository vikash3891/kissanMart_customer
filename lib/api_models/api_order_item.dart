import 'product.dart';

class ApiOrderItem {
  final int id;
  final int quantity;
  final double price;
  final Product product;

  ApiOrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory ApiOrderItem.fromJson(Map<String, dynamic> json) {
    return ApiOrderItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'product': product.toJson(),
    };
  }
}
