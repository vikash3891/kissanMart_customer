class ApiCartItem {
  final int id;
  final int productId;
  final int quantity;
  final String name;
  final double price;
  final double discountPrice;
  final String imageUrl;
  final int stock;

  ApiCartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.imageUrl,
    required this.stock,
  });

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    return ApiCartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: double.tryParse(json['discount_price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'name': name,
      'price': price.toStringAsFixed(2),
      'discount_price': discountPrice.toStringAsFixed(2),
      'image_url': imageUrl,
      'stock': stock,
    };
  }

  ApiCartItem copyWith({
    int? id,
    int? productId,
    int? quantity,
    String? name,
    double? price,
    double? discountPrice,
    String? imageUrl,
    int? stock,
  }) {
    return ApiCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }
}
