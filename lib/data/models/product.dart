class Product {
  final int id;
  final String title;
  final String category;
  final double? price;
  final double? discountPercentage;
  final double? rating;
  final double? stock;
  final String? brand;
  final List<String> images;
  final String? thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    this.price,
    this.stock,
    this.discountPercentage,
    this.rating,
    this.brand,
    this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imgs = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final i in rawImages) {
        if (i is String) imgs.add(i);
      }
    }
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      images: imgs,
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      stock: json['stock'] is num ? (json['stock'] as num).toDouble() : null,
      brand: json['brand']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
