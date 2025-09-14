import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product.dart';
import '../../widgets/product_image_carousel.dart';
import '../../widgets/product_price_section.dart';
import '../../widgets/product_info_section.dart';
import '../../widgets/product_reviews_section.dart';
import '../../widgets/product_action_buttons.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

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
                  backgroundColor: Colors.white, // choose your app bar color
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
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      // Calculate the top position to know when it's collapsed
                      var top = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: top <= kToolbarHeight + 50
                              ? 1.0
                              : 0.0, // fade in title when collapsed
                          child: Text(
                            widget.product.title,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        background: ProductImageCarousel(
                          images: widget.product.images,
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
                        title: widget.product.title,
                        price: widget.product.price ?? 0,
                        discountPercentage: widget.product.discountPercentage,
                        rating: widget.product.rating ?? 0,
                        onShare: _shareProduct,
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
              child: ProductActionButtons(
                onAddToCart: () => _openBottomSheet(action: 'cart'),
                onBuyNow: () => _openBottomSheet(action: 'buy'),
                onWishlistTap: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                isFavorite: _isFavorite,
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

  // =========================
  // Open Bottom Sheet Popup
  // =========================
  void _openBottomSheet({required String action}) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    // Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    // Product Info Row
                    Row(
                      children: [
                        Image.network(
                          widget.product.thumbnail ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
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
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "\$${widget.product.price ?? 0}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              if (widget.product.discountPercentage != null)
                                Text(
                                  "${widget.product.discountPercentage}% Off",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Quantity
                    Row(
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
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
                        Text(
                          quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Final Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (action == 'cart') {
                          _performAddToCart(quantity);
                        } else {
                          _performBuyNow(quantity);
                        }
                      },
                      child: Text(action == 'cart' ? 'Add to Cart' : 'Buy Now'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // Bottom Sheet Actions
  // =========================
  void _performAddToCart(int quantity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.title} (Qty: $quantity) to cart'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _performBuyNow(int quantity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buying ${widget.product.title} (Qty: $quantity)'),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
