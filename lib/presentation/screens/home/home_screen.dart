import 'package:ecommerce_app/core/providers/theme_provider.dart';
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/category_repository.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/presentation/screens/category/category_products_screen.dart';
import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/widgets/flash_sale_section.dart';
import 'package:ecommerce_app/presentation/widgets/just_for_you_section.dart';
import 'package:ecommerce_app/presentation/widgets/most_popular_section.dart';
import 'package:ecommerce_app/presentation/widgets/new_items_section.dart';
import 'package:ecommerce_app/presentation/widgets/top_products_section.dart';
import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final _scroll = ScrollController();

  bool _firstSectionLoaded = false;
  bool _topReady = false;
  bool _newReady = false;
  bool _flashReady = false;
  bool _popularReady = false;
  bool _jfyReady = false;

  @override
  void initState() {
    super.initState();
    // Create repositories
    //final apiClient = const ApiClient();
    //_categoryRepo = CategoryRepository(apiClient);
    //_productRepo = ProductRepository(apiClient);

    // If you kept CategoryRepository local, keep this line:
    final apiClient = context.read<ApiClient>(); // reuse global client
    _categoryRepo = CategoryRepository(apiClient);

    _productRepo = context.read<ProductRepository>();
    // Start data fetching
    _categoriesFuture = _categoryRepo.fetchTopCategoriesWithPreviews(
      categoryLimit: 6,
      productPerCategory: 4,
    );

    // when categories resolve (success OR error), unlock scroll
    _categoriesFuture.whenComplete(() {
      if (mounted) setState(() => _firstSectionLoaded = true);
    });

    _scroll.addListener(_maybeStartLazySections);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeStartLazySections() {
    if (!_firstSectionLoaded) return;
    final offset = _scroll.position.pixels;
    final vp = _scroll.position.viewportDimension;

    if (!_topReady && offset > vp * 0.10) setState(() => _topReady = true);
    if (!_newReady && offset > vp * 0.45) setState(() => _newReady = true);
    if (!_flashReady && offset > vp * 0.80) setState(() => _flashReady = true);
    if (!_popularReady && offset > vp * 1.10)
      setState(() => _popularReady = true);
    if (!_jfyReady && offset > vp * 1.20)
      setState(() => _jfyReady = true); // was 1.80
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
      backgroundColor: Theme.of(
        context,
      ).appBarTheme.backgroundColor, // Theme-aware
      automaticallyImplyLeading: false,
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
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.primaryColor,
                size: 26,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            );
          },
        ),
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

  Widget _buildBody() {
    final physics = _firstSectionLoaded
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    return SafeArea(
      child: CustomScrollView(
        controller: _scroll,
        physics: physics,
        slivers: [
          SliverToBoxAdapter(child: _buildWelcomeBanner()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSectionHeader(),
            ),
          ),

          // Categories Grid (with shimmer while waiting)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: _buildCategoriesGrid(),
          ),

          // ---- Top Products ----
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 20),
          //     child: !_firstSectionLoaded || !_topReady
          //         ? const SizedBox.shrink() // was: _TopProductsShimmer()
          //         : TopProductsSection(
          //             productRepository: _productRepo,
          //             title: 'Top Products',
          //             productLimit: 8,
          //             onSeeAllTap: () {},
          //             onProductTap: (p) {},
          //           ),
          //   ),
          // ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: !_firstSectionLoaded || !_topReady
                  ? const SizedBox.shrink()
                  : TopProductsSection(
                      productRepository: _productRepo,
                      title: 'Top Products',
                      productLimit: 8,
                      onSeeAllTap: () {},
                      onProductTap: (product) {
                        // Navigate to ProductDetailScreen and pass the selected product
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // ---- New Items ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: !_firstSectionLoaded || !_newReady
                  ? const SizedBox.shrink() // was: _NewItemsShimmer()
                  : NewItemsSection(
                      productRepository: _productRepo,
                      title: 'New Items',
                      productLimit: 8,
                      onSeeAllTap: () {},
                      onProductTap: (p) {},
                    ),
            ),
          ),

          // ---- Flash Sale ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: !_firstSectionLoaded || !_flashReady
                  ? const SizedBox.shrink() // was: _FlashSaleShimmer()
                  : FlashSaleSection(productRepository: _productRepo),
            ),
          ),

          // ---- Most Popular ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: !_firstSectionLoaded || !_popularReady
                  ? const SizedBox.shrink() // was: _MostPopularShimmer()
                  : MostPopularSection(
                      productRepository: _productRepo,
                      title: 'Most Popular',
                      productLimit: 8,
                      onSeeAllTap: () {},
                      onProductTap: (p) {},
                    ),
            ),
          ),

          // ---- Just For You ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: !_firstSectionLoaded || !_jfyReady
                  ? const SizedBox.shrink() // was: _JustForYouShimmer()
                  : JustForYouSection(
                      productRepository: _productRepo,
                      title: 'Just For You',
                      onProductTap: (p) {},
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
            color: Theme.of(
              context,
            ).textTheme.displayLarge?.color, // Theme-aware
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: _navigateToAllCategories, // Trigger the navigation here
          child: Container(
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
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.accentColor,
                  size: 16,
                ),
              ],
            ),
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
          // Sliver shimmer grid for categories
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ShimmerCategoryCard(),
              childCount: 6,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
          );
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
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color, // Theme-aware
                fontSize: 14,
              ),
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
          color: Theme.of(context).cardColor, // Theme-aware
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor, // Theme-aware
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color, // Theme-aware
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Found',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.displayLarge?.color, // Theme-aware
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color, // Theme-aware
                fontSize: 14,
              ),
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
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          selectedCategorySlug: category.slug,
          selectedCategoryName: category.name,
        ),
      ),
    );
  }

  void _navigateToAllCategories() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(
          showAllCategories: true, // Show all categories
        ),
      ),
    );
  }
}
