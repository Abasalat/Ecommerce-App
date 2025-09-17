import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final DateTime addedAt;

  WishlistItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.addedAt,
  });

  factory WishlistItem.fromProduct(dynamic product) {
    return WishlistItem(
      productId: (product.id ?? 0) as int,
      title: (product.title ?? '') as String,
      thumbnail: (product.thumbnail ?? '') as String,
      price: ((product.price ?? 0.0) as num).toDouble(),
      addedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'addedAt': FieldValue.serverTimestamp(), // server time for ordering
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    DateTime parseAddedAt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    return WishlistItem(
      productId: (json['productId'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      thumbnail: (json['thumbnail'] ?? '') as String,
      price: ((json['price'] ?? 0.0) as num).toDouble(),
      addedAt: parseAddedAt(json['addedAt']),
    );
  }
}
