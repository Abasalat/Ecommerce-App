import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:ecommerce_app/core/providers/theme_provider.dart';
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/category_repository.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/presentation/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/screens/category/category_products_screen.dart';
import 'package:ecommerce_app/presentation/screens/mostPopular/most_popular_products_screen.dart';
import 'package:ecommerce_app/presentation/screens/newitem/new_items_products_screen.dart';
import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/screens/search/search_results_screen.dart';
import 'package:ecommerce_app/presentation/screens/userprofile/profile_screen.dart';
import 'package:ecommerce_app/presentation/widgets/flash_sale_section.dart';
import 'package:ecommerce_app/presentation/widgets/just_for_you_section.dart';
import 'package:ecommerce_app/presentation/widgets/most_popular_section.dart';
import 'package:ecommerce_app/presentation/widgets/new_items_section.dart';
import 'package:ecommerce_app/presentation/widgets/top_products_section.dart';
import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:ecommerce_app/viewmodels/home_viewmodel.dart';
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
  // late final Future<List<Product>> _topProductsFuture;
  // late final Future<List<Product>> _flashSaleProductsFuture;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

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
    // Load products when screen initializes
    context.read<HomeViewModel>().loadNewProducts();
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
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  // ALTERNATIVE DESIGN - More Minimal & Clean
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      elevation: 1,
      shadowColor: AppColors.lightShadow,
      centerTitle: false,
      title: Row(
        children: [
          // Gradient App Name
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
            ).createShader(bounds),
            child: const Text(
              'E-Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Theme Toggle - Minimal
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.nights_stay_outlined,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
            );
          },
        ),

        // Cart with Badge - Minimal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                onPressed: () {
                  // CHANGE THIS: Switch to Cart tab instead of pushing
                  context.read<NavProvider>().setIndex(
                    3,
                  ); // 3 is Cart tab index
                },
              ),

              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile - Minimal
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: AppColors.primaryColor,
              size: 24,
            ),
            onPressed: () {
              // Switch to Profile tab instead of pushing
              context.read<NavProvider>().setIndex(4); // 4 is Profile tab index
            },
          ),
        ),
      ],
    );
  }

  // NEW: Separate SliverAppBar ONLY for Search

  Widget _buildSearchSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      floating: true,
      snap: true,
      pinned: true, // Keep it pinned at top
      automaticallyImplyLeading: false,
      toolbarHeight: 75,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: GestureDetector(
              onTap: () {
                // Navigate to search results screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(
                      searchQuery: _searchController.text,
                      productRepository: _productRepo,
                    ),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    // Search Text
                    Expanded(
                      child: Text(
                        'Search products, categories, prices...',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    // Filter Icon (optional)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Search functionality
  // IMPORTANT: Update your _performSearch method to navigate properly
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: query,
          productRepository: _productRepo,
        ),
      ),
    );
  }

  // MODIFY YOUR _buildBody() METHOD
  // Replace your existing _buildBody with this:
  Widget _buildBody() {
    final physics = _firstSectionLoaded
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    return SafeArea(
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final newProducts = viewModel.newProducts;

          if (newProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Wrap CustomScrollView with RefreshIndicator
          return RefreshIndicator(
            color: AppColors.primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              controller: _scroll,
              physics: physics,
              slivers: [
                _buildSearchSliverAppBar(), // Your search sliver

                SliverToBoxAdapter(child: _buildWelcomeBanner()),
                SliverToBoxAdapter(child: _buildCarousel(newProducts)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildSectionHeader(),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: _buildCategoriesGrid(),
                ),

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

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: !_firstSectionLoaded || !_newReady
                        ? const SizedBox.shrink()
                        : NewItemsSection(
                            productRepository: _productRepo,
                            title: 'New Items',
                            productLimit: 8,
                            onSeeAllTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NewItemsProductsScreen(),
                                ),
                              );
                            },
                            onProductTapFull: (Product p) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: p),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: !_firstSectionLoaded || !_flashReady
                        ? const SizedBox.shrink()
                        : FlashSaleSection(productRepository: _productRepo),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: !_firstSectionLoaded || !_popularReady
                        ? const SizedBox.shrink()
                        : MostPopularSection(
                            productRepository: _productRepo,
                            title: 'Most Popular',
                            productLimit: 8,
                            onSeeAllTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => MostPopularProductsScreen(),
                                ),
                              );
                            },
                            onProductTapFull: (Product p) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: p),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: !_firstSectionLoaded || !_jfyReady
                        ? const SizedBox.shrink()
                        : JustForYouSection(
                            productRepository: _productRepo,
                            title: 'Just For You',
                            onProductTap: (product) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildCarousel(List<Product> newProducts) {
    return Container(
      margin: const EdgeInsets.all(16),

      height: 200, // Adjust the height as per your design
      child: CarouselSlider.builder(
        itemCount: newProducts.length,
        itemBuilder: (context, index, realIndex) {
          // Fetch the image URL for the carousel
          final product = newProducts[index];
          final imageUrl = product.images.isNotEmpty
              ? product.images.first
              : product.thumbnail; // Use thumbnail if no images

          return InkWell(
            onTap: () {
              // Navigate to the product details screen and pass the selected product
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                16,
              ), // Makes the card circular
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(
                        0.9,
                      ), // Shadow color with opacity
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // Adjust shadow position
                    ),
                  ],
                ),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16 / 10,
          enableInfiniteScroll: true,
          initialPage: 0,
        ),
      ),
    );
  }

  // Add this method after your existing methods
  Future<void> _handleRefresh() async {
    try {
      // Refresh products cache
      await _productRepo.refreshProducts();

      // Refresh categories cache and get new data
      final newCategories = await _categoryRepo.refreshPreviews(
        categoryLimit: 6,
        productPerCategory: 4,
      );

      // Reload new products in ViewModel
      await context.read<HomeViewModel>().loadNewProducts();

      // Update categories future with fresh data
      setState(() {
        _categoriesFuture = Future.value(newCategories);
        _topReady = false;
        _newReady = false;
        _flashReady = false;
        _popularReady = false;
        _jfyReady = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.textWhite),
                const SizedBox(width: 8),
                const Text('Content refreshed successfully!'),
              ],
            ),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
