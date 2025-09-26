import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../widgets/shimmer_skeletons.dart';
import '../../widgets/search_bar_widget.dart';

class PopularProductItem {
  final String id;
  final String name;
  final String? imageUrl;
  final int loveCount;
  final List<String> tags;
  final double price;

  const PopularProductItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.loveCount,
    required this.tags,
    required this.price,
  });
}

class MostPopularProductsScreen extends StatefulWidget {
  const MostPopularProductsScreen({super.key});

  @override
  State<MostPopularProductsScreen> createState() =>
      _MostPopularProductsScreenState();
}

class _MostPopularProductsScreenState extends State<MostPopularProductsScreen> {
  late final ProductRepository _productRepo;
  List<Product> _allProducts = [];
  List<PopularProductItem> _displayedProducts = [];
  List<PopularProductItem> _filteredProducts = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMoreProducts = true;
  int _currentPage = 1;
  static const int _productsPerPage = 12;
  String _searchQuery = '';
  List<String> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _productRepo = ProductRepository(context.read<ApiClient>());
    _loadPopularProducts();
  }

  Future<void> _loadPopularProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await _productRepo.fetchMostPopularProducts(limit: 100);

      final popularItems = products
          .map(
            (product) => PopularProductItem(
              id: product.id.toString(),
              name: product.title ?? 'Unknown Product',
              imageUrl: product.images.isNotEmpty
                  ? product.images.first
                  : product.thumbnail,
              loveCount: _generateLoveCount(product),
              tags: _generateTags(product),
              price: (product.price ?? 0).toDouble(),
            ),
          )
          .toList();

      setState(() {
        _allProducts = products;
        _displayedProducts = popularItems.take(_productsPerPage).toList();
        _filteredProducts = List.from(_displayedProducts);
        _hasMoreProducts = popularItems.length > _productsPerPage;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore || !_hasMoreProducts) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final startIndex = _displayedProducts.length;
      final endIndex = (startIndex + _productsPerPage).clamp(
        0,
        _allProducts.length,
      );

      final newProducts = _allProducts
          .sublist(startIndex, endIndex)
          .map(
            (product) => PopularProductItem(
              id: product.id.toString(),
              name: product.title ?? 'Unknown Product',
              imageUrl: product.images.isNotEmpty
                  ? product.images.first
                  : product.thumbnail,
              loveCount: _generateLoveCount(product),
              tags: _generateTags(product),
              price: (product.price ?? 0).toDouble(),
            ),
          )
          .toList();

      setState(() {
        _displayedProducts.addAll(newProducts);
        _isLoadingMore = false;
        _hasMoreProducts = _displayedProducts.length < _allProducts.length;
      });
    });
  }

  // Apply search and filters on products
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSearch();
    });
  }

  void _onFiltersChanged(List<String> filters) {
    setState(() {
      _activeFilters = filters;
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    List<PopularProductItem> filtered = List.from(
      _allProducts.map(
        (product) => PopularProductItem(
          id: product.id.toString(),
          name: product.title ?? 'Unknown Product',
          imageUrl: product.images.isNotEmpty
              ? product.images.first
              : product.thumbnail,
          loveCount: _generateLoveCount(product),
          tags: _generateTags(product),
          price: (product.price ?? 0).toDouble(),
        ),
      ),
    );

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting filters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Price: Low to High':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Rating: High to Low':
          filtered.sort((a, b) => b.loveCount.compareTo(a.loveCount));
          break;
        case 'Newest First':
          filtered.sort((a, b) => a.id.compareTo(b.id));
          break;
      }
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  // Generate love count based on rating and stock
  int _generateLoveCount(Product product) {
    final rating = product.rating ?? 0;
    final stock = product.stock ?? 0;
    return ((rating * 100) + (stock * 0.5)).round();
  }

  // Generate tags based on product properties
  List<String> _generateTags(Product product) {
    final tags = <String>[];

    if ((product.discountPercentage ?? 0) > 15) {
      tags.add('Sale');
    }

    if ((product.rating ?? 0) >= 4.5) {
      tags.add('Hot');
    }

    if ((product.id ?? 0) > 25) {
      tags.add('New');
    }

    return tags.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Enhanced Search Bar with Filters
          EnhancedSearchBarWidget(
            onSearchChanged: _onSearchChanged,
            onFiltersChanged: _onFiltersChanged,
          ),
          // Products Content
          Expanded(
            child: _isLoading ? _buildShimmerGrid() : _buildProductContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      title: const Text(
        'Most Popular',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.64,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6, // Show 6 shimmer cards
        itemBuilder: (context, index) {
          return _ShimmerProductCard();
        },
      ),
    );
  }

  Widget _buildProductContent() {
    if (_filteredProducts.isEmpty &&
        (_searchQuery.isNotEmpty || _activeFilters.isNotEmpty)) {
      return const Center(
        child: Text('No products found for your search/filters'),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(child: Text('No popular items available'));
    }

    return CustomScrollView(
      slivers: [
        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _filteredProducts[index];
              return _buildPopularProductCard(product);
            }, childCount: _filteredProducts.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
          ),
        ),
        // See More Button
        if (_hasMoreProducts)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: ElevatedButton(
                onPressed: _isLoadingMore ? null : _loadMoreProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.expand_more, size: 20),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularProductCard(PopularProductItem product) {
    return GestureDetector(
      onTap: () {
        final originalProduct = _allProducts.firstWhere(
          (p) => p.id.toString() == product.id,
        );

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: originalProduct),
          ),
        );
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
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : AppColors.inputFillColor,
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
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    const SizedBox(height: 8),
                    // Price
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
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'loves',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
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
      return Center(
        child: Icon(
          Icons.favorite_outline,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 32,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).textTheme.bodySmall?.color,
            size: 32,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerSectionHeader(),
          SizedBox(height: 12),
          Expanded(child: ShimmerJFYGrid(count: 8)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.errorColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Popular Products',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPopularProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dedicated shimmer card widget
class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE9EDF1),
        highlightColor: const Color(0xFFF5F7F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer - 2 lines
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price shimmer
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
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
}
