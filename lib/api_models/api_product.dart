class ApiCategory {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  ApiCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      imageUrl: json["image_url"] ?? "",
    );
  }
}

class ApiProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final int stock;
  final String? imageUrl;
  final String brand;
  final String unit;
  final bool isAvailable;
  final String stockStatus;
  final DateTime createdAt;
  final ApiCategory category;

  ApiProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.imageUrl,
    required this.brand,
    required this.unit,
    required this.isAvailable,
    required this.stockStatus,
    required this.createdAt,
    required this.category,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0,
      discountPrice: double.tryParse(json["discount_price"].toString()) ?? 0,
      stock: json["stock"] ?? 0,
      imageUrl: json["image_url"],
      brand: json["brand"] ?? "",
      unit: json["unit"] ?? "",
      isAvailable: json["is_available"] ?? false,
      stockStatus: json["stock_status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
      category: ApiCategory.fromJson(json["category"] ?? {}),
    );
  }

  bool get hasDiscount => discountPrice < price;

  int get discountPercent {
    if (price == 0) return 0;
    return (((price - discountPrice) / price) * 100).round();
  }

  bool get inStock => stock > 0;
}

class PaginatedProducts {
  final List<ApiProduct> products;
  final int totalPages;
  final int currentPage;
  final int totalProducts;

  PaginatedProducts({
    required this.products,
    required this.totalPages,
    required this.currentPage,
    required this.totalProducts,
  });
}
