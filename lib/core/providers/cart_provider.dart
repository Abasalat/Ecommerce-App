import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/data/models/cart_item.dart';
import 'package:ecommerce_app/data/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  // State variables
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _cartTotal = 0.0;
  double _cartSubtotal = 0.0;
  int _itemCount = 0;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get cartTotal => _cartTotal;
  double get cartSubtotal => _cartSubtotal;
  int get itemCount => _itemCount;
  bool get isEmpty => _cartItems.isEmpty;
  double get cartDiscount => _cartSubtotal - _cartTotal;

  // Initialize cart - load data from SharedPreferences and listen to Firestore
  Future<void> initializeCart() async {
    _setLoading(true);
    try {
      // Load cached totals from SharedPreferences
      await _loadCachedTotals();

      // Listen to real-time cart updates from Firestore
      _cartService.getCartStream().listen(
        (cartItems) {
          _cartItems = cartItems;
          _updateTotals();
          _setLoading(false);
        },
        onError: (error) {
          _setError(error.toString());
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Add product to cart
  Future<void> addToCart(dynamic product, int quantity) async {
    try {
      _clearError();

      final cartItem = CartItem.fromProduct(product, quantity);
      await _cartService.addToCart(cartItem);

      // Update cached totals
      await _loadCachedTotals();

      // The stream listener will automatically update _cartItems
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Update item quantity
  Future<void> updateQuantity(int productId, int newQuantity) async {
    try {
      _clearError();

      await _cartService.updateItemQuantity(productId, newQuantity);

      // Update cached totals
      await _loadCachedTotals();

      // The stream listener will automatically update _cartItems
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Increase quantity
  Future<void> increaseQuantity(int productId) async {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found in cart'),
    );

    await updateQuantity(productId, item.quantity + 1);
  }

  // Decrease quantity
  Future<void> decreaseQuantity(int productId) async {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found in cart'),
    );

    if (item.quantity > 1) {
      await updateQuantity(productId, item.quantity - 1);
    } else {
      await removeFromCart(productId);
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int productId) async {
    try {
      _clearError();

      await _cartService.removeFromCart(productId);

      // Update cached totals
      await _loadCachedTotals();

      // The stream listener will automatically update _cartItems
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      _clearError();

      await _cartService.clearCart();

      // Clear local state
      _cartItems.clear();
      _cartTotal = 0.0;
      _cartSubtotal = 0.0;
      _itemCount = 0;

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Check if product is in cart
  bool isProductInCart(int productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  // Get product quantity in cart
  int getProductQuantity(int productId) {
    try {
      final item = _cartItems.firstWhere((item) => item.productId == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Load cached totals from SharedPreferences
  Future<void> _loadCachedTotals() async {
    try {
      _cartTotal = await _cartService.getCartTotal();
      _cartSubtotal = await _cartService.getCartSubtotal();
      _itemCount = await _cartService.getCartItemCount();
      notifyListeners();
    } catch (e) {
      print('Error loading cached totals: $e');
    }
  }

  // Update totals from current cart items
  void _updateTotals() {
    _cartSubtotal = 0;
    _cartTotal = 0;
    _itemCount = 0;

    for (final item in _cartItems) {
      _cartSubtotal += item.price * item.quantity;
      _cartTotal += item.totalPrice;
      _itemCount += item.quantity;
    }

    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'items': _cartItems.map((item) => item?.toJson()).toList(),
      'itemCount': _itemCount,
      'subtotal': _cartSubtotal,
      'discount': cartDiscount,
      'total': _cartTotal,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Calculate delivery fee (you can customize this logic)
  double calculateDeliveryFee() {
    if (_cartTotal >= 50) return 0.0; // Free delivery over $50
    return 5.99; // Standard delivery fee
  }

  // Get final checkout total including delivery
  double getFinalTotal() {
    return _cartTotal + calculateDeliveryFee();
  }
}
