import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class FlashSaleSection extends StatefulWidget {
  final ProductRepository productRepository;

  const FlashSaleSection({super.key, required this.productRepository});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Future<List<Product>> _flashSaleProductsFuture;

  static const int flashSaleDurationSeconds = 3600; // 1 hour countdown
  late Timer _timer;
  int _secondsLeft = flashSaleDurationSeconds;

  @override
  void initState() {
    super.initState();
    _flashSaleProductsFuture = widget.productRepository.fetchSaleProducts(
      limit: 6,
    );
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = flashSaleDurationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formattedTime(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hoursStr = duration.inHours.toString().padLeft(2, '0');
    final minutesStr = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final secondsStr = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _flashSaleProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("Flash Sale Products: ${snapshot.data}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          print("Error fetching flash sale products: ${snapshot.error}");
          return _buildErrorState();
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildProductsGrid(products),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to full flash sale listing screen
          // Example: Navigator.pushNamed(context, '/flashSaleListing');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Flash Sale',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formattedTime(_secondsLeft),
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final imageUrl = (product.images.isNotEmpty)
              ? product.images.first
              : product.thumbnail;

          return GestureDetector(
            onTap: () {
              // Navigate to product detail screen passing product data
              // Example: Navigator.pushNamed(context, '/productDetails', arguments: product);
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.inputFillColor),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.discountColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.discountPercentage?.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text(
          'Failed to load flash sale products',
          style: TextStyle(color: AppColors.errorColor),
        ),
      ),
    );
  }
}
