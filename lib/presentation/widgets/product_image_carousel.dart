import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final String? thumbnail;

  const ProductImageCarousel({super.key, required this.images, this.thumbnail});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _allImages {
    List<String> allImages = [];
    if (widget.images.isNotEmpty) {
      allImages.addAll(widget.images);
    } else if (widget.thumbnail != null && widget.thumbnail!.isNotEmpty) {
      allImages.add(widget.thumbnail!);
    }
    return allImages;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;

    if (images.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        // Image PageView
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return _buildImageItem(images[index]);
          },
        ),

        // Dots Indicator
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildDotsIndicator(images.length),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingImage();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
                ? AppColors.primaryColor
                : AppColors.textTertiary,
          ),
        );
      }),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.inputFillColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No Image Available',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
