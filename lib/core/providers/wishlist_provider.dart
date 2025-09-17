import 'dart:async';
import 'package:ecommerce_app/data/models/wishlist_item.dart';
import 'package:ecommerce_app/data/services/wishlist_service.dart';
import 'package:flutter/foundation.dart';

class WishlistProvider with ChangeNotifier {
  final _svc = WishlistService();

  List<WishlistItem> _items = [];
  bool _loading = false;
  String? _error;
  StreamSubscription? _sub;

  List<WishlistItem> get items => _items;
  bool get isLoading => _loading;
  String? get error => _error;

  void initialize() {
    _loading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _svc.stream().listen(
      (list) {
        _items = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  bool isInWishlist(int productId) {
    return _items.any((w) => w.productId == productId);
  }

  Future<void> toggle(dynamic product) async {
    try {
      await _svc.toggle(product);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> add(dynamic product) async {
    try {
      await _svc.add(WishlistItem.fromProduct(product));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(int productId) async {
    try {
      await _svc.remove(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
