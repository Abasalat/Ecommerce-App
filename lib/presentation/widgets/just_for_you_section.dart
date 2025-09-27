import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product.dart';
import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';

// Just For You product data model
class JustForYouItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  const JustForYouItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}

class JustForYouSection extends StatefulWidget {
  final ProductRepository productRepository;
  final String title;
  final Function(Product)? onProductTap;

  const JustForYouSection({
    super.key,
    required this.productRepository,
    this.title = 'Just For You',
    this.onProductTap,
  });

  @override
  State<JustForYouSection> createState() => _JustForYouSectionState();
}

class _JustForYouSectionState extends State<JustForYouSection> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;

  // Add this line - the missing variable
  List<Product> _originalProducts = [];

  List<JustForYouItem> _allProducts = [];
  List<JustForYouItem> _displayedProducts = [];
  int _currentPage = 0;

  static const int _initialLoadCount = 12;
  static const int _loadMoreCount = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
  }

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await widget.productRepository.fetchJustForYouProducts(
        limit: 50, // Load more products to have data for pagination
      );

      // Store the original products
      _originalProducts = products;

      final justForYouItems = products
          .map(
            (product) => JustForYouItem(
              id: product.id.toString(),
              name: product.title ?? 'Unknown Product',
              price: product.price ?? 0.0,
              imageUrl: product.images.isNotEmpty
                  ? product.images.first
                  : product.thumbnail,
            ),
          )
          .toList();

      setState(() {
        _allProducts = justForYouItems;
        _displayedProducts = _allProducts.take(_initialLoadCount).toList();
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _displayedProducts.length >= _allProducts.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading

    final startIndex =
        _currentPage * _initialLoadCount + (_currentPage - 1) * _loadMoreCount;
    final moreProducts = _allProducts
        .skip(startIndex)
        .take(_loadMoreCount)
        .toList();

    setState(() {
      _displayedProducts.addAll(moreProducts);
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerSectionHeader(),
          SizedBox(height: 8),
          ShimmerJFYGrid(count: 4),
        ],
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_displayedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildJustForYouSection();
  }

  Widget _buildJustForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(),

        const SizedBox(height: 16),

        // Products Grid
        _buildProductsGrid(),

        // See More Button
        if (_displayedProducts.length < _allProducts.length)
          _buildSeeMoreButton(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.title,
        style: TextStyle(
          color: Theme.of(context).textTheme.displayLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75, // Height slightly more than width
        ),
        itemCount: _displayedProducts.length,
        itemBuilder: (context, index) {
          final product = _displayedProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(JustForYouItem product) {
    return GestureDetector(
      onTap: () {
        // Find the original product
        final originalProduct = _originalProducts.firstWhere(
          (p) => p.id.toString() == product.id,
        );

        if (widget.onProductTap != null) {
          widget.onProductTap!(originalProduct);
        }
      },
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
                  color: AppColors.inputFillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product.imageUrl),
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
                      product.name,
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
                        '\$${product.price.toStringAsFixed(2)}',
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

  Widget _buildSeeMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                    'See More',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more, size: 20),
                ],
              ),
      ),
    );
  }

  // ---- image helpers: shimmer only (no spinner)
  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _imageShimmer();
      },
      errorBuilder: (_, __, ___) => _buildErrorImage(),
    );
  }

  Widget _imageShimmer() {
    return LayoutBuilder(
      builder: (context, c) => ShimmerBox(
        w: c.maxWidth,
        h: c.maxHeight,
        r: const BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 32,
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
          size: 32,
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
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.errorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.errorColor,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load products',
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadInitialProducts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
