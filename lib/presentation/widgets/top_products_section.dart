import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product.dart';

// Product data model for the widget
class ProductItem {
  final String id;
  final String name;
  final String? imageUrl;
  const ProductItem({required this.id, required this.name, this.imageUrl});
}

class TopProductsSection extends StatefulWidget {
  final ProductRepository productRepository;
  final String title;
  final int productLimit;
  final VoidCallback? onSeeAllTap; // No longer used but kept for compatibility
  final Function(ProductItem)? onProductTap;
  const TopProductsSection({
    super.key,
    required this.productRepository,
    this.title = 'Top Products',
    this.productLimit = 8,
    this.onSeeAllTap,
    this.onProductTap,
  });
  @override
  State<TopProductsSection> createState() => _TopProductsSectionState();
}

class _TopProductsSectionState extends State<TopProductsSection> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.productRepository.fetchTopProducts(
      limit: widget.productLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState();
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const SizedBox.shrink(); // Hide if no products
        }
        // Convert Product to ProductItem
        final productItems = products
            .map(
              (product) => ProductItem(
                id: product.id.toString(),
                name: product.title ?? 'Unknown Product',
                imageUrl: product.images.isNotEmpty
                    ? product.images.first
                    : product.thumbnail,
              ),
            )
            .toList();
        return _buildProductsSection(productItems);
      },
    );
  }

  Widget _buildProductsSection(List<ProductItem> products) {
    return Column(
      children: [
        // Section Header without "See All"
        SizedBox(height: 10),
        _buildSectionHeader(),
        // Products List
        SizedBox(height: 120, child: _buildProductsList(products)),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align title to start
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // "See All" removed as per request
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductItem> products) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(product, index, products.length);
      },
    );
  }

  Widget _buildProductItem(ProductItem product, int index, int totalItems) {
    return GestureDetector(
      onTap: () {
        // Add navigation route here to navigate to product details screen
        // For example:
        // Navigator.pushNamed(context, '/productDetails', arguments: product);
        widget.onProductTap?.call(product);
      },
      child: Container(
        width: 80, // controls overall size
        margin: EdgeInsets.only(right: index == totalItems - 1 ? 0 : 12),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                width: 70, // inner circle size
                height: 70,
                color: AppColors.surfaceColor,
                child:
                    (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover, // ensures image fills the circle
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textTertiary,
                          size: 28,
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textTertiary,
                        size: 28,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.errorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load products',
                    style: TextStyle(color: AppColors.errorColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = widget.productRepository
                            .fetchTopProducts(limit: widget.productLimit);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Retry', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
