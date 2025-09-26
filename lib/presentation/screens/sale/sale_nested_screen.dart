// lib/presentation/screens/sale/sale_nested_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../widgets/shimmer_skeletons.dart';

class SaleNestedScreen extends StatefulWidget {
  final ProductRepository productRepository;

  const SaleNestedScreen({super.key, required this.productRepository});

  @override
  State<SaleNestedScreen> createState() => _SaleNestedScreenState();
}

class _SaleNestedScreenState extends State<SaleNestedScreen>
    with TickerProviderStateMixin {
  List<Product> _allSaleProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> _displayedProducts = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMoreProducts = true;
  bool _showSortFilters = false;

  String _selectedDiscountFilter = 'All';
  List<String> _selectedSortFilters = [];

  int _currentPage = 1;
  static const int _productsPerPage = 12;

  final List<String> _discountFilterOptions = [
    'All',
    '10%',
    '20%',
    '30%',
    '40%',
    '50%',
  ];
  final List<String> _sortFilterOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Newest First',
    'Popular',
  ];

  late AnimationController _sortAnimationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _sortAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sortAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadSaleProducts();
  }

  @override
  void dispose() {
    _sortAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSaleProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await widget.productRepository.fetchSaleProducts(
        limit: 100,
      );
      setState(() {
        _allSaleProducts = products;
        _applyAllFilters();
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

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final startIndex = _displayedProducts.length;
      final endIndex = (startIndex + _productsPerPage).clamp(
        0,
        _filteredProducts.length,
      );

      final newProducts = _filteredProducts.sublist(startIndex, endIndex);

      setState(() {
        _displayedProducts.addAll(newProducts);
        _isLoadingMore = false;
        _hasMoreProducts = _displayedProducts.length < _filteredProducts.length;
      });
    });
  }

  void _applyDiscountFilter(String filter) {
    setState(() {
      _selectedDiscountFilter = filter;
      _currentPage = 1;
      _applyAllFilters();
    });
  }

  void _toggleSortFilters() {
    setState(() {
      _showSortFilters = !_showSortFilters;
    });
    if (_showSortFilters) {
      _sortAnimationController.forward();
    } else {
      _sortAnimationController.reverse();
    }
  }

  void _toggleSortFilter(String filter) {
    setState(() {
      if (_selectedSortFilters.contains(filter)) {
        _selectedSortFilters.remove(filter);
      } else {
        _selectedSortFilters = [filter]; // Only allow one sort filter
      }
      _applyAllFilters();
    });
  }

  void _applyAllFilters() {
    List<Product> filtered = List.from(_allSaleProducts);

    // Apply discount filter
    if (_selectedDiscountFilter != 'All') {
      final minDiscount = int.parse(
        _selectedDiscountFilter.replaceAll('%', ''),
      );
      filtered = filtered.where((product) {
        final discount = product.discountPercentage ?? 0;
        return discount >= minDiscount;
      }).toList();
    }

    // Apply sorting filters
    for (String filter in _selectedSortFilters) {
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
    _displayedProducts = _filteredProducts.take(_productsPerPage).toList();
    _hasMoreProducts = _filteredProducts.length > _productsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Compact Discount Filter Buttons
          _buildDiscountFilterSection(),

          // Active Filters Display with Sort Button
          _buildActiveFiltersSection(),

          // Animated Sort Filters Panel
          _buildSortFiltersPanel(),

          // Products Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                ? _buildErrorState()
                : _buildProductsContent(),
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
      title: Text(
        'Flash Sale',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDiscountFilterSection() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _discountFilterOptions.length,
        itemBuilder: (context, index) {
          final filter = _discountFilterOptions[index];
          final isSelected = filter == _selectedDiscountFilter;

          return Container(
            margin: EdgeInsets.only(right: 8), // Reduced gap
            child: _buildDiscountFilterButton(filter, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildDiscountFilterButton(String filter, bool isSelected) {
    return GestureDetector(
      onTap: () => _applyDiscountFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ), // Smaller padding
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20), // Smaller radius
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected
                ? AppColors.textWhite
                : Theme.of(context).textTheme.displayLarge?.color,
            fontSize: 12, // Smaller font
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Selected Sort Filters Display
          Expanded(
            child: _selectedSortFilters.isEmpty
                ? Text(
                    'Sort by',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    children: _selectedSortFilters.map((filter) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _toggleSortFilter(filter),
                              child: Icon(
                                Icons.close,
                                color: AppColors.textWhite,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // Sort Filter Button
          GestureDetector(
            onTap: _toggleSortFilters,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showSortFilters
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _showSortFilters
                      ? AppColors.primaryColor
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: _showSortFilters
                    ? AppColors.primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFiltersPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSortFilters ? null : 0,
      child: _showSortFilters
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
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
                  Text(
                    'Sort Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortFilterOptions.map((filter) {
                      final isSelected = _selectedSortFilters.contains(filter);
                      return GestureDetector(
                        onTap: () => _toggleSortFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Theme.of(
                                      context,
                                    ).textTheme.displayLarge?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildProductsContent() {
    if (_displayedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                color: Theme.of(context).textTheme.displayLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _displayedProducts[index];
              return _buildProductCard(product);
            }, childCount: _displayedProducts.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
          ),
        ),

        // See More Button
        if (_hasMoreProducts)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ), // Added bottom gap
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

  Widget _buildProductCard(Product product) {
    final hasDiscount =
        product.discountPercentage != null && product.discountPercentage! > 0;
    final discountedPrice = hasDiscount
        ? (product.price ?? 0) -
              ((product.price ?? 0) * (product.discountPercentage! / 100))
        : product.price ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
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
            // Product Image with Discount Badge
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
                      child: _buildProductImage(product),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage!.toInt()}%',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Text(
                            '\$${(product.price ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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

  Widget _buildProductImage(Product product) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : product.thumbnail;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Icon(
          Icons.local_offer_outlined,
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
              'Failed to Load Sale Products',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSaleProducts,
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
