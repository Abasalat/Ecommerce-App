import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Product data model
class ProductItem {
  final String id;
  final String name;
  final String? imageUrl;

  const ProductItem({required this.id, required this.name, this.imageUrl});
}

class TopProducts extends StatelessWidget {
  final String title;
  final List<ProductItem> products;
  final VoidCallback? onSeeAllTap;
  final Function(ProductItem)? onProductTap;

  const TopProducts({
    super.key,
    required this.title,
    required this.products,
    this.onSeeAllTap,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Header
        _buildSectionHeader(),

        const SizedBox(height: 12),

        // Products List
        SizedBox(height: 120, child: _buildProductsList()),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAllTap != null)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.accentColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(product, index);
      },
    );
  }

  Widget _buildProductItem(ProductItem product, int index) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: index == products.length - 1 ? 0 : 12),
        child: Column(
          children: [
            // Product Image Circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceColor,
                border: Border.all(
                  color: AppColors.borderColor.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(child: _buildProductImage(product.imageUrl)),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingImage();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.textTertiary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textTertiary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 32,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No products available',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
