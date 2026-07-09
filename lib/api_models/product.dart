class Product {
  final int id;
  final String name;
  final String imageUrl;
  final String brand;
  final String unit;
  final double price;
  final double discountPrice;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.brand,
    required this.unit,
    required this.price,
    required this.discountPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"] ?? "",
      imageUrl: json["image_url"] ?? "",
      brand: json["brand"] ?? "",
      unit: json["unit"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0,
      discountPrice: double.tryParse(json["discount_price"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image_url": imageUrl,
      "brand": brand,
      "unit": unit,
      "price": price,
      "discount_price": discountPrice,
    };
  }
}
