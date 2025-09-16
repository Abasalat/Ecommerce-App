import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProductActionButtons extends StatelessWidget {
  const ProductActionButtons({
    super.key,
    required this.onWishlistTap,
    required this.isFavorite,
    this.onAddToCart,
    this.onBuyNow,
    this.isInCart = false,
    this.quantityInCart = 0,
    this.isLoading = false,
  });

  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback onWishlistTap;

  final bool isFavorite;
  final bool isInCart;
  final int quantityInCart;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Wishlist button
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightShadow),
              ),
              child: IconButton(
                onPressed: isLoading ? null : onWishlistTap,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.errorColor
                      : AppColors.textSecondary,
                ),
                tooltip: isFavorite
                    ? 'Remove from wishlist'
                    : 'Add to wishlist',
              ),
            ),
            const SizedBox(width: 12),

            // Add to Cart
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (onAddToCart == null || isLoading)
                      ? null
                      : onAddToCart,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart),
                  label: Text(
                    isInCart && quantityInCart > 0
                        ? 'Update Cart'
                        : 'Add to Cart',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Buy Now
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (onBuyNow == null || isLoading) ? null : onBuyNow,
                  icon: const Icon(Icons.flash_on),
                  label: const Text(
                    'Buy Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
