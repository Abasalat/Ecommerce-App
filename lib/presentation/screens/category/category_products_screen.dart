import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/widgets/products_section_widget.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_filter_widget.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String? selectedCategorySlug;
  final String? selectedCategoryName;
  final bool showAllCategories;

  const CategoryProductsScreen({
    super.key,
    this.selectedCategorySlug,
    this.selectedCategoryName,
    this.showAllCategories = false,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final CategoryRepository _categoryRepo;
  late final ProductRepository _productRepo;

  List<CategoryItem> _allCategories = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();

    // Set initial filter
    _selectedFilter = widget.showAllCategories
        ? 'All'
        : widget.selectedCategoryName ?? 'All';

    // Set initial title
    _currentTitle = widget.showAllCategories
        ? 'All Categories'
        : widget.selectedCategoryName ?? 'Products';

    final apiClient = const ApiClient();
    _categoryRepo = CategoryRepository(apiClient);
    _productRepo = ProductRepository(apiClient);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      _allCategories = await _categoryRepo.fetchAllCategories();
      setState(() {});
    } catch (error) {
      // Optionally handle category fetch error
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterSelected(String filter) async {
    setState(() {
      _selectedFilter = filter;
      // Update title when filter changes
      _currentTitle = filter == 'All' ? 'All Categories' : filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      title: Text(
        _formatCategoryName(_currentTitle), // Format the title,
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

  String _formatCategoryName(String category) {
    if (category == 'All Categories' || category == 'All') return category;

    // Convert "beauty" to "Beauty" or "mens-watches" to "Mens Watches"
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

  Widget _buildBody() {
    return Column(
      children: [
        // Search Bar
        SearchBarWidget(onSearchChanged: _onSearchChanged),

        // Category Filters
        CategoryFilterWidget(
          categories: _allCategories,
          selectedFilter: _selectedFilter,
          onFilterSelected: _onFilterSelected,
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ProductsSectionWidget(
            fetchProducts: (filter) async {
              if (filter == 'All') {
                return await _productRepo.fetchAllProducts(limit: 50);
              } else {
                String? slug;

                // Priority 1: use selectedCategorySlug from Home navigation
                if (widget.selectedCategorySlug != null &&
                    widget.selectedCategoryName?.toLowerCase() ==
                        filter.toLowerCase()) {
                  slug = widget.selectedCategorySlug;
                }
                // Priority 2: find slug from loaded categories (for filters inside the screen)
                else if (_allCategories.isNotEmpty) {
                  final category = _allCategories.firstWhere(
                    (cat) => cat.name.toLowerCase() == filter.toLowerCase(),
                    orElse: () => _allCategories.first,
                  );
                  slug = category.slug;
                }

                // If slug is still null, fallback
                if (slug == null) {
                  return [];
                }

                return await _productRepo.fetchProductsByCategory(
                  slug,
                  limit: 50,
                );
              }
            },
            selectedFilter: _selectedFilter,
            searchQuery: _searchQuery,
            onProductTap: _onProductTap,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _onProductTap(Product product) {
    // TODO: Navigate to product details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
