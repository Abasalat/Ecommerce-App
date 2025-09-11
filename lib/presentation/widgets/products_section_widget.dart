import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product.dart';
import 'product_grid_widget.dart';

class ProductsSectionWidget extends StatefulWidget {
  final Future<List<Product>> Function(String filter) fetchProducts;
  final String selectedFilter;
  final String searchQuery;
  final Function(Product) onProductTap;

  const ProductsSectionWidget({
    super.key,
    required this.fetchProducts,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onProductTap,
  });

  @override
  State<ProductsSectionWidget> createState() => _ProductsSectionWidgetState();
}

class _ProductsSectionWidgetState extends State<ProductsSectionWidget> {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant ProductsSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload products only if filter or search query changes
    if (oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await widget.fetchProducts(widget.selectedFilter);

      // Apply search filter
      List<Product> filtered = products;
      if (widget.searchQuery.isNotEmpty) {
        filtered = products.where((product) {
          return (product.title?.toLowerCase().contains(
                    widget.searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              (product.category.toLowerCase().contains(
                    widget.searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }

      setState(() {
        _products = filtered;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(child: Text('Failed to load products: $_errorMessage'));
    }

    return ProductGridWidget(
      products: _products,
      onProductTap: widget.onProductTap,
    );
  }
}
