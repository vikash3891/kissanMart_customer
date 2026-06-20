class Product {
  final int id;
  final String store;
  final String name;
  final String category;
  final String subCategory;
  final String type;
  final String image;
  final String unit;
  final double price;
  final double mrp;
  final double rating;
  final int reviews;
  final String tag;
  final String origin;
  final String farmer;
  final String process;
  final bool organic;

  const Product({
    required this.id,
    required this.store,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.type,
    required this.image,
    required this.unit,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.origin,
    required this.farmer,
    required this.process,
    required this.organic,
  });
}