import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final List<String> imageUrls;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrls,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare image URLs for 2x2 grid
    final gridImages = List<String?>.from(imageUrls);
    while (gridImages.length < 4) {
      gridImages.add(null);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Product Images Grid (2x2)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.inputFillColor,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildProductImagesGrid(gridImages),
              ),
            ),

            // Category Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCategoryName(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${imageUrls.length} items',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Container(
                  //   padding: const EdgeInsets.all(6),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primaryColor.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Icon(
                  //     Icons.arrow_forward_ios,
                  //     size: 12,
                  //     color: AppColors.primaryColor,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImagesGrid(List<String?> gridImages) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final imageUrl = gridImages[index];
        return _buildSingleProductImage(imageUrl, index);
      },
    );
  }

  Widget _buildSingleProductImage(String? imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl.isEmpty
          ? _buildPlaceholderImage(index)
          : Image.network(
              imageUrl,
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingImage();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorImage();
              },
            ),
    );
  }

  Widget _buildPlaceholderImage(int index) {
    // Different placeholder icons for variety
    final icons = [
      Icons.inventory_2_outlined,
      Icons.shopping_bag_outlined,
      Icons.store_outlined,
      Icons.local_offer_outlined,
    ];

    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: Icon(
          icons[index % icons.length],
          color: AppColors.textTertiary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return LayoutBuilder(
      builder: (context, constraints) => ShimmerBox(
        w: constraints.maxWidth,
        h: constraints.maxHeight,
        r: const BorderRadius.all(Radius.circular(8)),
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
          size: 24,
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    // Convert "beauty" to "Beauty"
    // Convert "mens-watches" to "Mens Watches"
    return category
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }
}
