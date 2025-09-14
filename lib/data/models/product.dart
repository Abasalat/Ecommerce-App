// lib/data/models/product.dart

class Product {
  // Core
  final int id;
  final String title;
  final String category;
  final List<String> images;
  final String? thumbnail;

  // Commerce
  final double? price;
  final double? discountPercentage;
  final double? rating;
  final int? stock;
  final String? brand;
  final String? sku;

  // NEW FIELDS
  final List<String>? sizes;
  final List<String>? colors;

  // Details
  final String? description;
  final List<String> tags;
  final int? weight; // the API shows an int (e.g., 4)
  final Dimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;
  final int? minimumOrderQuantity;

  // Nested
  final List<Review> reviews;
  final ProductMeta? meta;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    this.thumbnail,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.brand,
    this.sku,
    this.description,
    this.tags = const [],
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.reviews = const [],
    this.meta,
    this.colors,
    this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // images
    final imgs = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final i in rawImages) {
        if (i is String) imgs.add(i);
      }
    }

    // tags
    final tagList = <String>[];
    final rawTags = json['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String) tagList.add(t);
      }
    }

    // reviews
    final reviewList = <Review>[];
    final rawReviews = json['reviews'];
    if (rawReviews is List) {
      for (final r in rawReviews) {
        if (r is Map<String, dynamic>) {
          reviewList.add(Review.fromJson(r));
        }
      }
    }

    // dimensions
    Dimensions? dims;
    if (json['dimensions'] is Map<String, dynamic>) {
      dims = Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>);
    }

    // meta
    ProductMeta? m;
    if (json['meta'] is Map<String, dynamic>) {
      m = ProductMeta.fromJson(json['meta'] as Map<String, dynamic>);
    }

    // numbers are sometimes ints or doubles in APIs, normalize safely
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Product(
      id: _toInt(json['id']) ?? 0,
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      images: imgs,
      thumbnail: json['thumbnail']?.toString(),

      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discountPercentage']),
      rating: _toDouble(json['rating']),
      stock: _toInt(json['stock']),
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString(),

      description: json['description']?.toString(),
      tags: tagList,
      weight: _toInt(json['weight']),
      dimensions: dims,
      warrantyInformation: json['warrantyInformation']?.toString(),
      shippingInformation: json['shippingInformation']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString(),
      returnPolicy: json['returnPolicy']?.toString(),
      minimumOrderQuantity: _toInt(json['minimumOrderQuantity']),
      colors: json['colors'],
      sizes: json['sizes'],
      reviews: reviewList,
      meta: m,
    );
  }
}

class Dimensions {
  final double? width;
  final double? height;
  final double? depth;

  Dimensions({this.width, this.height, this.depth});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return Dimensions(
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
      depth: _toDouble(json['depth']),
    );
  }
}

class Review {
  final double? rating;
  final String? comment;
  final DateTime? date;
  final String? reviewerName;
  final String? reviewerEmail;

  Review({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return Review(
      rating: _toDouble(json['rating']),
      comment: json['comment']?.toString(),
      date: _toDate(json['date']),
      reviewerName: json['reviewerName']?.toString(),
      reviewerEmail: json['reviewerEmail']?.toString(),
    );
  }
}

class ProductMeta {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? barcode;
  final String? qrCode;

  ProductMeta({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return ProductMeta(
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      barcode: json['barcode']?.toString(),
      qrCode: json['qrCode']?.toString(),
    );
  }
}
