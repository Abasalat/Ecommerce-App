import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product.dart';

// Product data model for the widget
class NewProductItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  const NewProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}

class NewItemsSection extends StatefulWidget {
  final ProductRepository productRepository;
  final String title;
  final int productLimit;
  final VoidCallback? onSeeAllTap;
  final Function(NewProductItem)? onProductTap;

  // NEW: full product callback (optional)
  final Function(Product)? onProductTapFull;

  const NewItemsSection({
    super.key,
    required this.productRepository,
    this.title = 'New Items',
    this.productLimit = 8,
    this.onSeeAllTap,
    this.onProductTap,
    this.onProductTapFull, // NEW
  });

  @override
  State<NewItemsSection> createState() => _NewItemsSectionState();
}

class _NewItemsSectionState extends State<NewItemsSection> {
  late Future<List<Product>> _productsFuture;

  // NEW: keep originals to pass full Product on tap
  List<Product> _originalProducts = const [];

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.productRepository.fetchNewProducts(
      limit: widget.productLimit,
      page: 1,
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
              ShimmerHorizontalCards(count: 6),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        _originalProducts = products; // ⬅️ keep originals

        final newProductItems = products
            .map(
              (p) => NewProductItem(
                id: p.id.toString(),
                name: p.title ?? 'Unknown Product',
                price: p.price ?? 0.0,
                imageUrl: p.images.isNotEmpty ? p.images.first : p.thumbnail,
              ),
            )
            .toList();

        return _buildNewItemsSection(newProductItems);
      },
    );
  }

  Widget _buildNewItemsSection(List<NewProductItem> products) {
    return Column(
      children: [
        // Section Header
        _buildSectionHeader(),

        const SizedBox(height: 12),

        // Products List
        SizedBox(
          height: 240, // Increased height for card layout
          child: _buildProductsList(products),
        ),
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
              color: Theme.of(context).textTheme.displayLarge?.color,
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

  Widget _buildProductsList(List<NewProductItem> products) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, index, products.length);
      },
    );
  }

  Widget _buildProductCard(NewProductItem product, int index, int totalitems) {
    return GestureDetector(
      onTap: () {
        // Prefer full product if handler provided
        if (widget.onProductTapFull != null) {
          final full = _originalProducts[index];
          widget.onProductTapFull!(full);
        } else {
          widget.onProductTap?.call(product);
        }
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: index == totalitems - 1 ? 0 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
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
            // Product Image
            Container(
              height: 140,
              margin: EdgeInsets.all(5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFillColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: _buildProductImage(product.imageUrl),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Product Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
          Icons.inventory_2_outlined,
          color: AppColors.textTertiary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return LayoutBuilder(
      builder: (context, constraints) => ShimmerBox(
        w: constraints.maxWidth,
        h: constraints.maxHeight,
        r: const BorderRadius.all(Radius.circular(12)),
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
          size: 40,
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
  //           height: 280,
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
              color: Theme.of(context).textTheme.displayLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
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
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load new items',
                    style: TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Retry', style: TextStyle(fontSize: 12)),
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
