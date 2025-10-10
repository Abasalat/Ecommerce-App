import 'package:flutter/material.dart';
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProductRepository _productRepo;
  List<Product> _newProducts = [];

  HomeViewModel(this._productRepo);

  List<Product> get newProducts => _newProducts;

  // Fetch new products from the repository
  Future<void> loadNewProducts() async {
    try {
      _newProducts = await _productRepo.fetchNewProducts(limit: 5, page: 1);
      notifyListeners(); // Notify UI when products are loaded
    } catch (e) {
      // Handle error if needed
      print("Error fetching products: $e");
    }
  }
}
