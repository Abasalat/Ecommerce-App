import 'package:ecommerce_app/presentation/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';

class _TopProductsShimmer extends StatelessWidget {
  const _TopProductsShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerSectionHeader(),
        SizedBox(height: 8),
        ShimmerAvatarRow(count: 8),
      ],
    );
  }
}

class _NewItemsShimmer extends StatelessWidget {
  const _NewItemsShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerSectionHeader(),
        SizedBox(height: 8),
        ShimmerHorizontalCards(count: 6),
      ],
    );
  }
}

class _FlashSaleShimmer extends StatelessWidget {
  const _FlashSaleShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerSectionHeader(),
        SizedBox(height: 12),
        ShimmerSquareGrid(count: 6, cross: 3),
      ],
    );
  }
}

class _MostPopularShimmer extends StatelessWidget {
  const _MostPopularShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerSectionHeader(),
        SizedBox(height: 8),
        ShimmerPopularRow(count: 8),
      ],
    );
  }
}

class _JustForYouShimmer extends StatelessWidget {
  const _JustForYouShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerSectionHeader(),
        SizedBox(height: 8),
        ShimmerJFYGrid(count: 4),
      ],
    );
  }
}
