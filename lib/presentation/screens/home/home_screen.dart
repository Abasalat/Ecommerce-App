import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/category_repository.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/presentation/widgets/flash_sale_section.dart';
import 'package:ecommerce_app/presentation/widgets/most_popular_section.dart';
import 'package:ecommerce_app/presentation/widgets/new_items_section.dart';
import 'package:ecommerce_app/presentation/widgets/top_products_section.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  late final CategoryRepository _categoryRepo;
  late final ProductRepository _productRepo;
  late final Future<List<CategoryPreview>> _categoriesFuture;
  late final Future<List<Product>> _topProductsFuture;
  late final Future<List<Product>> _flashSaleProductsFuture;

  @override
  void initState() {
    super.initState();
    // Create repositories
    final apiClient = const ApiClient();
    _categoryRepo = CategoryRepository(apiClient);
    _productRepo = ProductRepository(apiClient);

    // Start data fetching
    _categoriesFuture = _categoryRepo.fetchTopCategoriesWithPreviews(
      categoryLimit: 6,
      productPerCategory: 4,
    );

    _topProductsFuture = _productRepo.fetchTopProducts(limit: 8);

    _flashSaleProductsFuture = _productRepo.fetchSaleProducts(limit: 6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceColor,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      title: Text(
        'E-Shop',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.primaryColor, size: 26),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Search feature coming soon!'),
                backgroundColor: AppColors.infoColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.primaryColor,
            size: 26,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cart feature coming soon!'),
                backgroundColor: AppColors.infoColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.person_outline,
            color: AppColors.primaryColor,
            size: 26,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile feature coming soon!'),
                backgroundColor: AppColors.infoColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  // i have Updated your _buildBody method
  Widget _buildBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Welcome Banner Section
          SliverToBoxAdapter(child: _buildWelcomeBanner()),

          // Categories Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSectionHeader(),
            ),
          ),

          // Categories Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: _buildCategoriesGrid(),
          ),

          // Top Products Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TopProductsSection(
                productRepository: _productRepo,
                title: 'Top Products',
                productLimit: 8,
                onSeeAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('See all top products coming soon!'),
                      backgroundColor: AppColors.infoColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onProductTap: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product: ${product.name}'),
                      backgroundColor: AppColors.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ),

          // New Items Section - ADD THIS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: NewItemsSection(
                productRepository: _productRepo,
                title: 'New Items',
                productLimit: 8,
                onSeeAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('See all new items coming soon!'),
                      backgroundColor: AppColors.infoColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onProductTap: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'New Item: ${product.name} - \$${product.price}',
                      ),
                      backgroundColor: AppColors.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ),

          // Flash Sale Section - Added here
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FlashSaleSection(productRepository: _productRepo),
            ),
          ),

          // Most Popular Section - ADD THIS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: MostPopularSection(
                productRepository: _productRepo,
                title: 'Most Popular',
                productLimit: 8,
                onSeeAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'See all popular products coming soon!',
                      ),
                      backgroundColor: AppColors.infoColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onProductTap: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Popular: ${product.name} - ${product.loveCount} loves',
                      ),
                      backgroundColor: AppColors.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to E-Shop!',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover amazing products and deals',
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag,
              size: 32,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: AppColors.accentColor, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return FutureBuilder<List<CategoryPreview>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildLoadingState());
        }

        // Error State
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        // Success State
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return _buildCategoryGrid(categories);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Categories...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              'Failed to Load Categories',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _categoriesFuture = _categoryRepo
                      .fetchTopCategoriesWithPreviews(
                        categoryLimit: 6,
                        productPerCategory: 4,
                      );
                });
              },
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List categories) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final category = categories[index];
        return CategoryCard(
          title: category.name,
          imageUrls: category.imageUrls,
          onTap: () => _navigateToCategory(category),
        );
      }, childCount: categories.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
    );
  }

  void _navigateToCategory(CategoryPreview category) {
    // TODO: Navigate to category products screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${category.name} category'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
