import 'package:ecommerce_app/presentation/widgets/new_items_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/text_utils.dart';
import 'package:ecommerce_app/core/providers/wishlist_provider.dart';

// read shared repo provided in main.dart
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
  bool _newReady = false;
  bool _postFrameChecked = false;

  @override
  void initState() {
    super.initState();
    _productRepo = context.read<ProductRepository>();
    _scroll.addListener(_maybeStartLazyNewItems);

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

  void _maybeStartLazyNewItems() {
    if (!_firstBlockShown) return;
    final offset = _scroll.position.pixels;
    final vp = _scroll.position.viewportDimension;

    if (!_newReady && offset > vp * 0.40) {
      setState(() => _newReady = true);
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
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryColor,
            fontSize: 24,
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
              if (!canReachGate && !_newReady) {
                setState(() => _newReady = true);
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
                  // Empty state with heart icon and some items section
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

                  // Wishlist items -d and list
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
                          onRemove: () => context
                              .read<WishlistProvider>()
                              .remove(item.productId),
                          onOpen: () {
                            // TODO: Navigate to product detail
                          },
                        );
                      }, childCount: wish.items.length),
                    ),
                  ),
                ],

                // New Items Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: (wish.items.isEmpty || _newReady)
                        ? NewItemsSection(
                            productRepository: _productRepo,
                            title: 'Discover New Items',
                            productLimit: 8,
                            onSeeAllTap: () {},
                            onProductTap: (p) {},
                          )
                        : const SizedBox.shrink(),
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
    return Column(
      children: [
        // Empty state with animated heart
        Container(
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
                    onPressed: () => Navigator.of(context).maybePop(),
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
        ),
      ],
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
