// lib/presentation/widgets/product_price_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProductPriceSection extends StatefulWidget {
  final double price;
  final double? discountPercentage;
  final String title;
  final double rating; // From JSON

  final VoidCallback onShare;

  const ProductPriceSection({
    super.key,
    required this.price,
    this.discountPercentage,
    required this.title,
    required this.rating,
    required this.onShare,
  });

  @override
  State<ProductPriceSection> createState() => _ProductPriceSectionState();
}

class _ProductPriceSectionState extends State<ProductPriceSection> {
  bool _isLoved = false;

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        widget.discountPercentage != null && widget.discountPercentage! > 0;
    final discountedPrice = hasDiscount
        ? widget.price - (widget.price * widget.discountPercentage! / 100)
        : widget.price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Price ----------------
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 20, // reduced size
              fontWeight: FontWeight.bold,
            ),
          ),

          // Original price + discount
          if (hasDiscount)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '-${widget.discountPercentage!.toInt()}%',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ---------------- Product Title ----------------
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(height: 4),

          // ---------------- Rating + Wishlist + Share ----------------
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(
                '${widget.rating}', // only rating
                style: const TextStyle(fontSize: 12),
              ),

              const Spacer(),

              // Wishlist Icon
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isLoved
                        ? AppColors.errorColor.withOpacity(0.3)
                        : Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: _isLoved
                      ? AppColors.errorColor.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: IconButton(
                  icon: Icon(
                    _isLoved ? Icons.favorite : Icons.favorite_outline,
                    color: _isLoved
                        ? AppColors.errorColor
                        : Theme.of(context).textTheme.displayLarge?.color,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoved = !_isLoved;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isLoved
                              ? 'Added to wishlist'
                              : 'Removed from wishlist',
                        ),
                        backgroundColor: _isLoved
                            ? AppColors.successColor
                            : AppColors.infoColor,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: _isLoved
                      ? 'Remove from Wishlist'
                      : 'Add to Wishlist',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),

              // Share Icon
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: Icon(Icons.share_outlined, size: 18),
                  onPressed: widget.onShare,
                  tooltip: 'Share Product',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
