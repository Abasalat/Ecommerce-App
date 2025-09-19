import 'package:ecommerce_app/core/providers/cart_provider.dart';
import 'package:ecommerce_app/core/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product.dart';
import '../../widgets/product_image_carousel.dart';
import '../../widgets/product_price_section.dart';
import '../../widgets/product_info_section.dart';
import '../../widgets/product_reviews_section.dart';
import '../../widgets/product_action_buttons.dart';
import '../../../core/utils/text_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product; // Using dynamic to match your Product model

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Product Images with Custom App Bar
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 400,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    // Cart Badge
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Container(
                          margin: const EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  // Navigate to cart screen
                                  Navigator.pushNamed(context, '/cart');
                                },
                              ),
                              if (cartProvider.itemCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cartProvider.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;
                          return FlexibleSpaceBar(
                            centerTitle: true,
                            titlePadding: const EdgeInsets.symmetric(
                              horizontal: 48.0,
                              vertical: 16.0,
                            ),
                            title: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: top <= kToolbarHeight + 50 ? 1.0 : 0.0,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 120,
                                child: Text(
                                  TextUtils.truncateWords(
                                    widget.product.title ?? '',
                                    maxWords: 2,
                                    ellipsis: '...',
                                    alwaysEllipsis: true,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            background: ProductImageCarousel(
                              images: widget.product.images ?? [],
                              thumbnail: widget.product.thumbnail,
                            ),
                            collapseMode: CollapseMode.parallax,
                          );
                        },
                  ),
                ),

                // Product Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price and Share Section
                      ProductPriceSection(
                        title: widget.product.title ?? '',
                        price: widget.product.price ?? 0,
                        discountPercentage: widget.product.discountPercentage,
                        rating: widget.product.rating ?? 0,
                        onShare: _shareProduct,
                      ),

                      const SizedBox(height: 16),

                      // In Stock / Out of Stock Status
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (widget.product.stock ?? 0) > 0
                              ? AppColors.successColor.withOpacity(0.1)
                              : AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (widget.product.stock ?? 0) > 0
                                ? AppColors.successColor
                                : AppColors.errorColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (widget.product.stock ?? 0) > 0
                                  ? Icons.check_circle
                                  : Icons.warning,
                              size: 16,
                              color: (widget.product.stock ?? 0) > 0
                                  ? AppColors.successColor
                                  : AppColors.errorColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (widget.product.stock ?? 0) > 0
                                  ? 'In Stock (${widget.product.stock} available)'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: (widget.product.stock ?? 0) > 0
                                    ? AppColors.successColor
                                    : AppColors.errorColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reviews Section
                      ProductReviewsSection(
                        rating: widget.product.rating ?? 0,
                        product: widget.product,
                      ),

                      const SizedBox(height: 16),

                      // Product Info Section
                      ProductInfoSection(product: widget.product),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            // Fixed Bottom Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer2<CartProvider, WishlistProvider>(
                builder: (context, cart, wish, child) {
                  final productId = widget.product.id ?? 0;

                  final isInCart = cart.isProductInCart(productId);
                  final quantityInCart = cart.getProductQuantity(productId);
                  final isFav = wish.isInWishlist(productId);

                  return ProductActionButtons(
                    onAddToCart: (widget.product.stock ?? 0) > 0
                        ? () => _openBottomSheet(action: 'cart')
                        : null,
                    onBuyNow: (widget.product.stock ?? 0) > 0
                        ? () => _openBottomSheet(action: 'buy')
                        : null,

                    //  Wishlist toggle now goes through the provider (persists in Firestore)
                    onWishlistTap: () async {
                      await context.read<WishlistProvider>().toggle(
                        widget.product,
                      );
                    },

                    // UI state comes from providers
                    isFavorite: isFav,
                    isInCart: isInCart,
                    quantityInCart: quantityInCart,
                    isLoading: _isLoading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${widget.product.title}'),
        backgroundColor: AppColors.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Open Bottom Sheet for Add to Cart / Buy Now
  void _openBottomSheet({required String action}) {
    int quantity = 1;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentQuantityInCart = cartProvider.getProductQuantity(
      widget.product.id ?? 0,
    );
    final maxStock = widget.product.stock ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final totalQuantity = currentQuantityInCart + quantity;
            final canAddMore = totalQuantity <= maxStock;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          action == 'cart' ? 'Add to Cart' : 'Buy Now',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Product Info Row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.thumbnail ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (widget.product.discountPercentage !=
                                      null) ...[
                                    Text(
                                      '${((widget.product.price ?? 0) - ((widget.product.price ?? 0) * (widget.product.discountPercentage ?? 0) / 100)).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(widget.product.price ?? 0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      '${(widget.product.price ?? 0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                              if (widget.product.discountPercentage != null)
                                Text(
                                  '${widget.product.discountPercentage}% Off',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stock Info
                    if (currentQuantityInCart > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.infoColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.infoColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You already have $currentQuantityInCart in your cart',
                                style: TextStyle(
                                  color: AppColors.infoColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Quantity Selector
                    Row(
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 1
                                    ? () {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: canAddMore
                                    ? () {
                                        setState(() {
                                          quantity++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Stock warning
                    if (!canAddMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Maximum available: ${maxStock - currentQuantityInCart}',
                          style: const TextStyle(
                            color: AppColors.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Total Price
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(((widget.product.price ?? 0) - ((widget.product.price ?? 0) * (widget.product.discountPercentage ?? 0) / 100)) * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action == 'cart'
                              ? AppColors.primaryColor
                              : AppColors.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: canAddMore
                            ? () {
                                Navigator.pop(context);
                                if (action == 'cart') {
                                  _performAddToCart(quantity);
                                } else {
                                  _performBuyNow(quantity);
                                }
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              action == 'cart'
                                  ? Icons.shopping_cart
                                  : Icons.flash_on,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              action == 'cart' ? 'Add to Cart' : 'Buy Now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Safe area bottom padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Add to Cart Action
  Future<void> _performAddToCart(int quantity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(widget.product, quantity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added ${widget.product.title} (Qty: $quantity) to cart',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Buy Now Action
  Future<void> _performBuyNow(int quantity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First add to cart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(widget.product, quantity);

      if (mounted) {
        // Navigate to checkout or cart
        Navigator.pushNamed(context, '/cart');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Redirecting to checkout for ${widget.product.title}',
            ),
            backgroundColor: AppColors.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process order: $e'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
