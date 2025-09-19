import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
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
  final VoidCallback? onSeeAllTap;
  final Function(Product)? onProductTap; // Pass the full Product object
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
          return Column(
            children: const [
              SizedBox(height: 10),
              ShimmerSectionHeader(),
              ShimmerAvatarRow(count: 8),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildProductsSection(products); // Pass full Product
      },
    );
  }

  Widget _buildProductsSection(List<Product> products) {
    return Column(
      children: [
        SizedBox(height: 10),
        _buildSectionHeader(),
        SizedBox(height: 125, child: _buildProductsList(products)),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).textTheme.displayLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
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

  Widget _buildProductItem(Product product, int index, int totalItems) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailScreen using rootNavigator to hide the bottom navigation bar
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 80,
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
                width: 70,
                height: 70,
                color: Theme.of(context).cardColor,
                child: (product.images.isNotEmpty)
                    ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
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

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).textTheme.displayLarge?.color,
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
