import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product.dart';

// Popular product data model
class PopularProductItem {
  final String id;
  final String name;
  final String? imageUrl;
  final int loveCount;
  final List<String> tags; // New, Hot, Sale, etc.

  const PopularProductItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.loveCount,
    required this.tags,
  });
}

class MostPopularSection extends StatefulWidget {
  final ProductRepository productRepository;
  final String title;
  final int productLimit;
  final VoidCallback? onSeeAllTap;
  final Function(PopularProductItem)? onProductTap;

  const MostPopularSection({
    super.key,
    required this.productRepository,
    this.title = 'Most Popular',
    this.productLimit = 8,
    this.onSeeAllTap,
    this.onProductTap,
  });

  @override
  State<MostPopularSection> createState() => _MostPopularSectionState();
}

class _MostPopularSectionState extends State<MostPopularSection> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.productRepository.fetchMostPopularProducts(
      limit: widget.productLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              ShimmerSectionHeader(),
              SizedBox(height: 8),
              ShimmerPopularRow(count: 8),
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

        // Convert Product to PopularProductItem
        final popularItems = products
            .map(
              (product) => PopularProductItem(
                id: product.id.toString(),
                name: product.title ?? 'Unknown Product',
                imageUrl: product.images.isNotEmpty
                    ? product.images.first
                    : product.thumbnail,
                loveCount: _generateLoveCount(
                  product,
                ), // Generate based on rating
                tags: _generateTags(
                  product,
                ), // Generate tags based on product data
              ),
            )
            .toList();

        return _buildPopularSection(popularItems);
      },
    );
  }

  // Generate love count based on rating and stock
  int _generateLoveCount(Product product) {
    final rating = product.rating ?? 0;
    final stock = product.stock ?? 0;
    // Simple formula: higher rating and stock = more loves
    return ((rating * 100) + (stock * 0.5)).round();
  }

  // Generate tags based on product properties
  List<String> _generateTags(Product product) {
    final tags = <String>[];

    // Add tags based on discount
    if ((product.discountPercentage ?? 0) > 15) {
      tags.add('Sale');
    }

    // Add tags based on rating
    if ((product.rating ?? 0) >= 4.5) {
      tags.add('Hot');
    }

    // Add tags based on ID (simulate new products)
    if ((product.id ?? 0) > 25) {
      tags.add('New');
    }

    return tags.take(2).toList(); // Limit to 2 tags
  }

  Widget _buildPopularSection(List<PopularProductItem> products) {
    return Column(
      children: [
        // Section Header
        _buildSectionHeader(),

        const SizedBox(height: 12),

        // Products List
        SizedBox(height: 180, child: _buildProductsList(products)),
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
            widget.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.onSeeAllTap != null)
            GestureDetector(
              onTap: widget.onSeeAllTap,
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

  Widget _buildProductsList(List<PopularProductItem> products) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildPopularItem(product, index, products.length);
      },
    );
  }

  Widget _buildPopularItem(
    PopularProductItem product,
    int index,
    int totalitems,
  ) {
    return GestureDetector(
      onTap: () => widget.onProductTap?.call(product),
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: index == totalitems - 1 ? 0 : 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Tags
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.inputFillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProductImage(product.imageUrl),
                  ),
                ),

                // Tags
                if (product.tags.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: product.tags
                          .map((tag) => _buildTag(tag))
                          .toList(),
                    ),
                  ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Love Count
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppColors.errorColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.loveCount}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'loves',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    Color tagColor;
    Color textColor;

    switch (tag.toLowerCase()) {
      case 'new':
        tagColor = AppColors.successColor;
        textColor = AppColors.textWhite;
        break;
      case 'hot':
        tagColor = AppColors.errorColor;
        textColor = AppColors.textWhite;
        break;
      case 'sale':
        tagColor = AppColors.accentColor;
        textColor = AppColors.textWhite;
        break;
      default:
        tagColor = AppColors.primaryColor;
        textColor = AppColors.textWhite;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
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
      width: double.infinity,
      height: double.infinity,
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
          Icons.favorite_outline,
          color: AppColors.textTertiary,
          size: 32,
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
          size: 32,
        ),
      ),
    );
  }

  // Widget _buildLoadingState() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           widget.title,
  //           style: TextStyle(
  //             color: AppColors.textPrimary,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         SizedBox(
  //           height: 180,
  //           child: Center(
  //             child: CircularProgressIndicator(
  //               color: AppColors.primaryColor,
  //               strokeWidth: 2,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            height: 180,
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
                    'Failed to load popular products',
                    style: TextStyle(color: AppColors.errorColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = widget.productRepository
                            .fetchMostPopularProducts(
                              limit: widget.productLimit,
                            );
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
