import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductActionButtons extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onWishlistTap;
  final bool isFavorite;

  const ProductActionButtons({
    super.key,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onWishlistTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Wishlist / Favorite Icon
          InkWell(
            onTap: onWishlistTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
                color: isFavorite
                    ? AppColors.errorColor
                    : Theme.of(context).iconTheme.color,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Add to Cart Button
          Expanded(
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add to Cart'),
            ),
          ),

          const SizedBox(width: 12),

          // Buy Now Button
          Expanded(
            child: ElevatedButton(
              onPressed: onBuyNow,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}
