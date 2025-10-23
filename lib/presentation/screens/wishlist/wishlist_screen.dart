import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/widgets/new_items_section.dart';
import 'package:ecommerce_app/presentation/widgets/just_for_you_section.dart';
import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import 'package:ecommerce_app/core/providers/wishlist_provider.dart';

import '../../../data/repositories/product_repository.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  late final ProductRepository _productRepo;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  final _scroll = ScrollController();
  bool _firstBlockShown = false;
  bool _jfyReady = false;
  bool _postFrameChecked = false;

  @override
  void initState() {
    super.initState();
    _productRepo = context.read<ProductRepository>();
    _scroll.addListener(_maybeStartLazyJustForYou);

    // Heart animation setup
    _heartAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start heart animation
    _heartAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _maybeStartLazyJustForYou() {
    if (!_firstBlockShown) return;
    final offset = _scroll.position.pixels;
    final vp = _scroll.position.viewportDimension;

    // Trigger Just For You section when scrolled 40% of viewport
    if (!_jfyReady && offset > vp * 0.40) {
      setState(() => _jfyReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurfaceColor
            : AppColors.surfaceColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wish, _) {
              if (wish.items.isNotEmpty && !wish.isLoading) {
                return Row(
                  children: [
                    // Item count badge
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${wish.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wish, _) {
          if (!_firstBlockShown && !wish.isLoading) {
            _firstBlockShown = true;
          }

          if (!_postFrameChecked && !wish.isLoading) {
            _postFrameChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_scroll.hasClients) return;
              final pos = _scroll.position;
              final viewport = pos.viewportDimension;
              final needsScrollToGate = viewport * 0.40;
              final canReachGate = pos.maxScrollExtent >= needsScrollToGate;
              if (!canReachGate && !_jfyReady) {
                setState(() => _jfyReady = true);
              }
            });
          }

          return CustomScrollView(
            controller: _scroll,
            slivers: [
              if (wish.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingState(),
                )
              else ...[
                if (wish.items.isEmpty) ...[
                  // Empty state with heart icon
                  SliverToBoxAdapter(
                    child: _EmptyWishlistContent(
                      heartAnimation: _heartAnimation,
                      isDark: isDark,
                    ),
                  ),
                ] else ...[
                  // Wishlist items header
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceColor
                            : AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDark ? Colors.black : AppColors.lightShadow)
                                    .withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Saved Items (${wish.items.length})',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Wishlist items list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = wish.items[index];
                        return _WishlistListCard(
                          title: item.title,
                          price: item.price,
                          thumbnail: item.thumbnail,
                          isDark: isDark,
                          onRemove: () => _showRemoveDialog(
                            context,
                            item.productId,
                            item.title,
                            isDark,
                          ),
                          onOpen: () {
                            // TODO: Navigate to product detail
                          },
                        );
                      }, childCount: wish.items.length),
                    ),
                  ),
                ],

                // Just For You Section - Always shows when ready
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 20),
                    child: !_firstBlockShown || !_jfyReady
                        ? const SizedBox.shrink()
                        : JustForYouSection(
                            productRepository: _productRepo,
                            title: 'Just For You',
                            onProductTap: (product) {
                              // TODO: Navigate to product detail
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

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    int productId,
    String productTitle,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardColor
            : AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.favorite_border, color: AppColors.errorColor, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Remove from Wishlist?',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$productTitle" from your wishlist?',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WishlistProvider>().remove(productId);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Removed from wishlist')),
                    ],
                  ),
                  backgroundColor: AppColors.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _EmptyWishlistContent extends StatelessWidget {
  const _EmptyWishlistContent({
    required this.heartAnimation,
    required this.isDark,
  });

  final Animation<double> heartAnimation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: heartAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 60,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Your Wishlist is Empty',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save items you love to find them easily later',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Home tab (index 0)
                  context.read<NavProvider>().setIndex(0);
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Start Shopping'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your wishlist...',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistListCard extends StatelessWidget {
  const _WishlistListCard({
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.isDark,
    required this.onRemove,
    required this.onOpen,
  });

  final String title;
  final double price;
  final String thumbnail;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.lightShadow)
                    .withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Remove from wishlist',
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Add to cart functionality
                    },
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    tooltip: 'Add to cart',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
