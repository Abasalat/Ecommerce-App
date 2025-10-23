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

  // Debug method to check authentication
  void checkAuthStatus() {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ NO USER LOGGED IN!');
    } else {
      print('✅ User logged in: ${user.uid}');
      print('✅ Email: ${user.email}');
    }
  }

  // ==========================================
  // FIRESTORE OPERATIONS
  // ==========================================

  // Add item to cart in Firestore
  Future<void> addToCart(CartItem cartItem) async {
    checkAuthStatus(); // Debug

    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if item already exists in cart
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: cartItem.productId)
          .limit(1)
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
        final data = cartItem.toJson();
        data['addedAt'] = FieldValue.serverTimestamp();
        await _cartCollection!.add(data);
      }

      // Update SharedPreferences totals
      await _updateCartTotals();
    } catch (e) {
      print('❌ Add to cart error: $e');
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
      print('❌ Get cart items error: $e');
      throw Exception('Failed to get cart items: $e');
    }
  }

  // Update item quantity in Firestore
  Future<void> updateItemQuantity(int productId, int newQuantity) async {
    checkAuthStatus(); // Debug

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
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'quantity': newQuantity,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Update SharedPreferences totals
        await _updateCartTotals();
      } else {
        print('⚠️ Product not found in cart');
      }
    } catch (e) {
      print('❌ Update quantity error: $e');
      throw Exception('Failed to update item quantity: $e');
    }
  }

  // Remove item from cart in Firestore
  Future<void> removeFromCart(int productId) async {
    checkAuthStatus(); // Debug

    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No items found to remove');
        return;
      }

      // Use batch for multiple deletions
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ Item removed successfully');

      // Update SharedPreferences totals
      await _updateCartTotals();
    } catch (e) {
      print('❌ Remove from cart error: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    checkAuthStatus(); // Debug

    if (_cartCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _cartCollection!.get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Cart is already empty');
        await _clearCartTotals();
        return;
      }

      // Use batch delete for better performance and reliability
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ Cart cleared successfully (${querySnapshot.docs.length} items)');

      // Clear SharedPreferences
      await _clearCartTotals();
    } catch (e) {
      print('❌ Clear cart error: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Get cart stream for real-time updates
  Stream<List<CartItem>> getCartStream() {
    checkAuthStatus(); // Debug

    if (_cartCollection == null) {
      print('⚠️ No user authenticated, returning empty stream');
      return Stream.value([]);
    }

    return _cartCollection!
        .orderBy('addedAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Cart stream error: $error');
          return <CartItem>[];
        })
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) {
                try {
                  return CartItem.fromJson(doc.data());
                } catch (e) {
                  print('❌ Error parsing cart item: $e');
                  return null;
                }
              })
              .whereType<CartItem>()
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

      print(
        '✅ Cart totals updated: $itemCount items, \$${total.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('❌ Error updating cart totals: $e');
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
    print('✅ Cart totals cleared from SharedPreferences');
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
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if product in cart: $e');
      return false;
    }
  }

  // Get product quantity in cart
  Future<int> getProductQuantityInCart(int productId) async {
    if (_cartCollection == null) return 0;

    try {
      final querySnapshot = await _cartCollection!
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final item = CartItem.fromJson(querySnapshot.docs.first.data());
        return item.quantity;
      }

      return 0;
    } catch (e) {
      print('❌ Error getting product quantity: $e');
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
      print('❌ Error calculating discount: $e');
      return 0.0;
    }
  }
}
