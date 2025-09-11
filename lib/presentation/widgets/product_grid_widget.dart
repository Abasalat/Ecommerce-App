import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';

class ProductGridWidget extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const ProductGridWidget({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<ProductGridWidget> createState() => _ProductGridWidgetState();
}

class _ProductGridWidgetState extends State<ProductGridWidget> {
  List<Product> _displayedProducts = [];
  int _currentPage = 1;
  static const int _productsPerPage = 12;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _updateDisplayedProducts();
  }

  @override
  void didUpdateWidget(ProductGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _currentPage = 1;
      _updateDisplayedProducts();
    }
  }

  void _updateDisplayedProducts() {
    final totalToShow = _currentPage * _productsPerPage;
    _displayedProducts = widget.products.take(totalToShow).toList();
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      _updateDisplayedProducts();
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _displayedProducts[index];
              return _buildProductCard(product);
            }, childCount: _displayedProducts.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
          ),
        ),

        // See More Button as sliver
        if (_displayedProducts.length < widget.products.length)
          SliverToBoxAdapter(child: _buildSeeMoreButton()),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => widget.onProductTap(product),
      child: Container(
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
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : AppColors.inputFillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.title ?? 'Unknown Product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

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
                        '\$${(product.price ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13,
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

  Widget _buildProductImage(Product product) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : product.thumbnail;

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
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : AppColors.inputFillColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : AppColors.inputFillColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : AppColors.inputFillColor,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: ElevatedButton(
        onPressed: _isLoadingMore ? null : _loadMoreProducts,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textWhite,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: _isLoadingMore
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See More Products',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more, size: 20),
                ],
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
            Icons.search_off,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              color: Theme.of(context).textTheme.displayLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
