import 'package:ecommerce_app/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../widgets/shimmer_skeletons.dart';
import '../../widgets/search_bar_widget.dart';

class NewItemsProductsScreen extends StatefulWidget {
  const NewItemsProductsScreen({super.key});

  @override
  State<NewItemsProductsScreen> createState() => _NewItemsProductsScreenState();
}

class _NewItemsProductsScreenState extends State<NewItemsProductsScreen> {
  late final ProductRepository _productRepo;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String _searchQuery = '';
  List<String> _activeFilters = [];
  bool _hasMoreProducts = true;

  // Enhanced search with filters
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
    List<Product> filtered = List.from(_allProducts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.title?.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
            false;
      }).toList();
    }

    // Apply sorting filters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Price: Low to High':
          filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case 'Price: High to Low':
          filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case 'Rating: High to Low':
          filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
        case 'Newest First':
          filtered.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          break;
        case 'Popular':
          filtered.sort((a, b) {
            final scoreA = (a.rating ?? 0) * (a.stock ?? 1).toDouble();
            final scoreB = (b.rating ?? 0) * (b.stock ?? 1).toDouble();
            return scoreB.compareTo(scoreA);
          });
          break;
      }
    }

    _filteredProducts = filtered;
  }

  // Load products with pagination
  Future<void> _loadProducts() async {
    try {
      final newProducts = await _productRepo.fetchNewProducts(
        limit: 12,
        page: _currentPage,
      );

      setState(() {
        _isLoading = false;
        _allProducts.addAll(newProducts);
        _applyFiltersAndSearch();
        _hasMoreProducts = newProducts.length == 12;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _productRepo = ProductRepository(context.read<ApiClient>());
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 2,
        shadowColor: AppColors.lightShadow,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'New Items',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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

  // Shimmer effect grid - Show shimmer cards instead of generic shimmer
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
          return const _ShimmerProductCard();
        },
      ),
    );
  }

  // Build the grid view with actual products
  Widget _buildProductContent() {
    if (_filteredProducts.isEmpty &&
        (_searchQuery.isNotEmpty || _activeFilters.isNotEmpty)) {
      return const Center(
        child: Text('No products found for your search/filters'),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(child: Text('No new items available'));
    }

    return CustomScrollView(
      slivers: [
        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _filteredProducts[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: _NewItemCard(product: product),
              );
            }, childCount: _filteredProducts.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),

        // See More Button
        if (_searchQuery.isEmpty &&
            _activeFilters.isEmpty &&
            _hasMoreProducts &&
            _filteredProducts.length >= 12)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final newProducts = await _productRepo.fetchNewProducts(
        limit: 12,
        page: _currentPage,
      );

      final newUniqueProducts = newProducts.where((newProduct) {
        return !_allProducts.any(
          (existingProduct) => existingProduct.id == newProduct.id,
        );
      }).toList();

      setState(() {
        _allProducts.addAll(newUniqueProducts);
        _applyFiltersAndSearch();
        _isLoadingMore = false;
        _hasMoreProducts = newUniqueProducts.length == 12;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
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

// Simplified product card without shimmer logic
class _NewItemCard extends StatelessWidget {
  final Product product;

  const _NewItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final img =
        (product.images.isNotEmpty
            ? product.images.first
            : product.thumbnail) ??
        '';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputFillColor,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: img.isEmpty
                ? const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textTertiary,
                    size: 40,
                  )
                : Image.network(
                    img,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      // Show shimmer while image is loading
                      return Shimmer.fromColors(
                        baseColor: const Color(0xFFE9EDF1),
                        highlightColor: const Color(0xFFF5F7F9),
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textTertiary,
                        size: 40,
                      );
                    },
                  ),
          ),
          // Title + Price
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    product.title ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.displayLarge?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
