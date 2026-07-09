import 'product.dart';

class OrderItem {
  final int id;
  final int quantity;
  final double price;
  final Product product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json["id"],
      quantity: json["quantity"],
      price: double.tryParse(json["price"].toString()) ?? 0,
      product: Product.fromJson(json["product"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "quantity": quantity,
      "price": price,
      "product": product.toJson(),
    };
  }
}
