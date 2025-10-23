import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  // Basic properties - the data we store for each cart item
  final int productId; // Links to original product
  final String title; // Product name
  final double price; // Original price
  final String thumbnail; // Product image URL
  final double? discountPercentage; // Discount if available (can be null)
  final String category; // Product category
  final String brand; // Product brand
  int quantity; // How many items (can change)
  final DateTime addedAt; // When added to cart

  // Constructor - creates a new CartItem
  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.discountPercentage, // Optional with ?
    required this.category,
    required this.brand,
    required this.quantity,
    required this.addedAt,
  });

  // METHOD 1: Calculate discounted price
  // Why do we need this? Because we need to show the actual price after discount
  double get discountedPrice {
    if (discountPercentage != null) {
      // Formula: price - (price × discount ÷ 100)
      return price - (price * discountPercentage! / 100);
    }
    // If no discount, return original price
    return price;
  }

  // METHOD 2: Calculate total price for this item
  // Why do we need this? Because user can buy multiple quantities
  double get totalPrice {
    // Formula: discounted price × quantity
    return discountedPrice * quantity;
  }

  // METHOD 3: Convert CartItem to JSON (for saving to Firestore)
  // Why do we need this? Firestore stores data as JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'discountPercentage': discountPercentage,
      'category': category,
      'brand': brand,
      'quantity': quantity,
      // Convert DateTime to milliseconds for Firestore
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  // METHOD 4: Create CartItem from JSON (for loading from Firestore)
  // Why do we need this? When we read from Firestore, we get JSON/Map
  // FIXED: Now handles both Timestamp and int types from Firestore
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle addedAt field - can be Timestamp, int, or null
    DateTime addedAtDate;

    try {
      if (json['addedAt'] == null) {
        // If null, use current time
        addedAtDate = DateTime.now();
      } else if (json['addedAt'] is Timestamp) {
        // If it's a Firestore Timestamp, convert it to DateTime
        addedAtDate = (json['addedAt'] as Timestamp).toDate();
      } else if (json['addedAt'] is int) {
        // If it's milliseconds (int), convert to DateTime
        addedAtDate = DateTime.fromMillisecondsSinceEpoch(json['addedAt']);
      } else {
        // Fallback to current time
        addedAtDate = DateTime.now();
      }
    } catch (e) {
      print('Error parsing addedAt: $e');
      addedAtDate = DateTime.now();
    }

    return CartItem(
      productId: json['productId'] ?? 0, // Use 0 if null
      title: json['title'] ?? '', // Use empty string if null
      price: (json['price'] ?? 0.0).toDouble(), // Ensure it's double
      thumbnail: json['thumbnail'] ?? '',
      discountPercentage: json['discountPercentage']?.toDouble(),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      quantity: json['quantity'] ?? 1,
      addedAt: addedAtDate,
    );
  }

  // METHOD 5: Create CartItem from your Product object
  // Why do we need this? When user adds product to cart, we convert Product → CartItem
  factory CartItem.fromProduct(dynamic product, int quantity) {
    return CartItem(
      productId: product.id ?? 0,
      title: product.title ?? '',
      price: (product.price ?? 0.0).toDouble(),
      thumbnail: product.thumbnail ?? '',
      discountPercentage: product.discountPercentage?.toDouble(),
      category: product.category ?? '',
      brand: product.brand ?? '',
      quantity: quantity, // User-selected quantity
      addedAt: DateTime.now(), // Current timestamp
    );
  }

  // METHOD 6: Create a copy with updated quantity
  // Why do we need this? When user changes quantity, we need new CartItem
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      price: price,
      thumbnail: thumbnail,
      discountPercentage: discountPercentage,
      category: category,
      brand: brand,
      quantity: quantity ?? this.quantity, // Use new quantity or keep current
      addedAt: addedAt, // Keep original add time
    );
  }
}
