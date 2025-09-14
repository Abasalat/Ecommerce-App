// lib/presentation/widgets/product_info_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.displayLarge?.color;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            product.title.isNotEmpty ? product.title : 'Product Title',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          if ((product.description ?? '').isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: TextStyle(color: bodyColor, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],

          // Details
          _buildDetailsList(context),

          // Tags
          if (product.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildTagsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    final details = _getProductDetails(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...details.map((d) => _buildDetailRow(context, d)),
      ],
    );
  }

  List<MapEntry<String, String>> _getProductDetails(BuildContext context) {
    final items = <MapEntry<String, String>>[];

    if ((product.brand ?? '').isNotEmpty) {
      items.add(MapEntry('Brand', product.brand!));
    }

    if (product.category.isNotEmpty) {
      items.add(MapEntry('Category', _formatCategory(product.category)));
    }

    // Prefer API-provided availability; otherwise derive from stock
    if ((product.availabilityStatus ?? '').isNotEmpty) {
      items.add(MapEntry('Availability', product.availabilityStatus!));
    } else if (product.stock != null) {
      items.add(
        MapEntry(
          'Availability',
          product.stock! > 0 ? 'In Stock (${product.stock})' : 'Out of Stock',
        ),
      );
    }

    if ((product.sku ?? '').isNotEmpty) {
      items.add(MapEntry('SKU', product.sku!));
    }

    if (product.weight != null) {
      // Unit is not specified by API; use "kg" only if you know it's kilograms
      items.add(MapEntry('Weight', '${product.weight}'));
    }

    if (product.dimensions != null) {
      final d = product.dimensions!;
      final w = d.width?.toStringAsFixed(2) ?? '-';
      final h = d.height?.toStringAsFixed(2) ?? '-';
      final dep = d.depth?.toStringAsFixed(2) ?? '-';
      items.add(MapEntry('Dimensions', '$w × $h × $dep cm'));
    }

    // Use API fields for warranty/shipping if available
    if ((product.warrantyInformation ?? '').isNotEmpty) {
      items.add(MapEntry('Warranty', product.warrantyInformation!));
    }
    if ((product.shippingInformation ?? '').isNotEmpty) {
      items.add(MapEntry('Shipping', product.shippingInformation!));
    }

    if ((product.returnPolicy ?? '').isNotEmpty) {
      items.add(MapEntry('Return Policy', product.returnPolicy!));
    }

    if (product.minimumOrderQuantity != null) {
      items.add(MapEntry('Min. Order Qty', '${product.minimumOrderQuantity}'));
    }

    if (product.meta?.barcode != null && product.meta!.barcode!.isNotEmpty) {
      items.add(MapEntry('Barcode', product.meta!.barcode!));
    }

    return items;
  }

  Widget _buildDetailRow(
    BuildContext context,
    MapEntry<String, String> detail,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${detail.key}:',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail.value,
              style: TextStyle(
                color: Theme.of(context).textTheme.displayLarge?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatCategory(String category) {
    return category
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
              : w,
        )
        .join(' ');
  }
}
