class ApiBanner {
  final int id;
  final String title;
  final String imageUrl;
  final String? redirectType;
  final int? redirectId;
  final bool isActive;

  ApiBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.redirectType,
    this.redirectId,
    required this.isActive,
  });

  factory ApiBanner.fromJson(Map<String, dynamic> json) {
    return ApiBanner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      redirectType: json['redirect_type'],
      redirectId: json['redirect_id'] != null
          ? int.tryParse(json['redirect_id'].toString())
          : null,
      isActive: json['is_active'] ?? true,
    );
  }
}
