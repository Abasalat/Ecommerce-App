import 'package:flutter/material.dart';
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/presentation/widgets/custom_button.dart'; // <-- import your custom button

class ProductReviewsSection extends StatefulWidget {
  final Product product;
  final double? rating;

  const ProductReviewsSection({super.key, required this.product, this.rating});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  bool _showAllReviews = false;

  void _toggleShowReviews() {
    setState(() {
      _showAllReviews = !_showAllReviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = widget.product.reviews;
    final avg =
        widget.rating ??
        (widget.product.rating ?? _averageFromReviews(reviews));
    final displayedReviews = _showAllReviews
        ? reviews
        : reviews.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rating + Stars
          Row(
            children: [
              Text(
                'Rating & Reviews ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildStarRow(context, avg),
              const SizedBox(width: 8),
              Text(
                '(${(avg.isNaN ? 0.0 : avg).toStringAsFixed(1)})',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reviews List
          if (reviews.isEmpty)
            Text(
              'No reviews yet.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            )
          else
            Column(
              children: displayedReviews
                  .map((r) => _buildReviewTile(context, r))
                  .toList(),
            ),

          const SizedBox(height: 12),

          // Show More / Show Less Button
          if (reviews.length > 2)
            CustomButton(
              text: _showAllReviews ? 'Show Less' : 'See More Reviews',
              onPressed: _toggleShowReviews,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              height: 40,
            ),
        ],
      ),
    );
  }

  // --- Helpers ---

  double _averageFromReviews(List<Review> reviews) {
    if (reviews.isEmpty) return double.nan;
    final sum = reviews.fold<double>(0, (acc, r) => acc + (r.rating ?? 0));
    return sum / reviews.length;
  }

  Widget _buildStarRow(BuildContext context, double rating) {
    final safe = rating.isNaN ? 0.0 : rating.clamp(0.0, 5.0);
    final fullStars = safe.floor();
    final hasHalf = (safe - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    final iconColor = Theme.of(context).colorScheme.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, size: 18, color: iconColor),
        if (hasHalf) Icon(Icons.star_half, size: 18, color: iconColor),
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, size: 18, color: iconColor),
      ],
    );
  }

  Widget _buildReviewTile(BuildContext context, Review r) {
    final title = r.reviewerName?.trim().isNotEmpty == true
        ? r.reviewerName!
        : 'Anonymous';
    final dateStr = _formatDate(r.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + stars + date
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.displayLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStarRow(context, r.rating ?? 0),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if ((r.comment ?? '').isNotEmpty)
            Text(
              r.comment!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final d = date.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
