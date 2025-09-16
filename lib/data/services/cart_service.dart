import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SharedPreferences keys
  static const String _cartTotalKey = 'cart_total';
  static const String _cartItemCountKey = 'cart_item_count';
  static const String _cartSubtotalKey = 'cart_subtotal';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get cart collection reference for current user
  CollectionReference<Map<String, dynamic>>? get _cartCollection {
    if (_currentUserId == null) return null;
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('cart');
  }

  // ==========================================
  // FIRESTORE OPERATIONS
  // ==========================================

  // Add item to cart in Firestore
  Future<void> addToCart(CartItem cartItem) async {
    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if item already exists in cart
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: cartItem.productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Item exists, update quantity
        final doc = querySnapshot.docs.first;
        final existingItem = CartItem.fromJson(doc.data());
        final updatedQuantity = existingItem.quantity + cartItem.quantity;

        await doc.reference.update({
          'quantity': updatedQuantity,
          'addedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Item doesn't exist, add new
        await _cartCollection!.add(cartItem.toJson());
      }

      // Update SharedPreferences totals
      await _updateCartTotals();
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Get all cart items from Firestore
  Future<List<CartItem>> getCartItems() async {
    if (_cartCollection == null) {
      return [];
    }

    try {
      final querySnapshot = await _cartCollection!
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CartItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  // Update item quantity in Firestore
  Future<void> updateItemQuantity(int productId, int newQuantity) async {
    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'quantity': newQuantity,
          'addedAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Update SharedPreferences totals
        await _updateCartTotals();
      }
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  // Remove item from cart in Firestore
  Future<void> removeFromCart(int productId) async {
    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Update SharedPreferences totals
      await _updateCartTotals();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _cartCollection!.get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear SharedPreferences
      await _clearCartTotals();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Get cart stream for real-time updates
  Stream<List<CartItem>> getCartStream() {
    if (_cartCollection == null) {
      return Stream.value([]);
    }

    return _cartCollection!
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => CartItem.fromJson(doc.data()))
              .toList();

          // Update SharedPreferences whenever cart changes
          _updateCartTotals();

          return items;
        });
  }

  // ==========================================
  // SHARED PREFERENCES OPERATIONS
  // ==========================================

  // Update cart totals in SharedPreferences
  Future<void> _updateCartTotals() async {
    try {
      final cartItems = await getCartItems();
      final prefs = await SharedPreferences.getInstance();

      double subtotal = 0;
      double total = 0;
      int itemCount = 0;

      for (final item in cartItems) {
        subtotal += item.price * item.quantity;
        total += item.totalPrice; // This includes discount
        itemCount += item.quantity;
      }

      await prefs.setDouble(_cartSubtotalKey, subtotal);
      await prefs.setDouble(_cartTotalKey, total);
      await prefs.setInt(_cartItemCountKey, itemCount);
    } catch (e) {
      print('Error updating cart totals: $e');
    }
  }

  // Get cart total from SharedPreferences
  Future<double> getCartTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_cartTotalKey) ?? 0.0;
  }

  // Get cart subtotal from SharedPreferences
  Future<double> getCartSubtotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_cartSubtotalKey) ?? 0.0;
  }

  // Get cart item count from SharedPreferences
  Future<int> getCartItemCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cartItemCountKey) ?? 0;
  }

  // Clear cart totals from SharedPreferences
  Future<void> _clearCartTotals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartTotalKey);
    await prefs.remove(_cartSubtotalKey);
    await prefs.remove(_cartItemCountKey);
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  // Check if product is in cart
  Future<bool> isProductInCart(int productId) async {
    if (_cartCollection == null) return false;

    try {
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get product quantity in cart
  Future<int> getProductQuantityInCart(int productId) async {
    if (_cartCollection == null) return 0;

    try {
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final item = CartItem.fromJson(querySnapshot.docs.first.data());
        return item.quantity;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Calculate cart discount
  Future<double> getCartDiscount() async {
    try {
      final subtotal = await getCartSubtotal();
      final total = await getCartTotal();
      return subtotal - total;
    } catch (e) {
      return 0.0;
    }
  }
}
