import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class _C {
  static const base = Color(0xFFE9EDF1);
  static const hi = Color(0xFFF5F7F9);
}

class ShimmerBox extends StatelessWidget {
  final double w, h;
  final BorderRadius? r;
  const ShimmerBox({super.key, required this.w, required this.h, this.r});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _C.base,
      highlightColor: _C.hi,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _C.base,
          borderRadius: r ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, this.size = 50});
  @override
  Widget build(BuildContext context) =>
      ShimmerBox(w: size, h: size, r: BorderRadius.circular(size / 2));
}

/// ---- Section skeletons ----

class ShimmerSectionHeader extends StatelessWidget {
  const ShimmerSectionHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [ShimmerBox(w: 140, h: 18), ShimmerBox(w: 60, h: 14)],
      ),
    );
  }
}

class ShimmerCategoryCard extends StatelessWidget {
  const ShimmerCategoryCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.hi,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 4,
                itemBuilder: (_, __) =>
                    const ShimmerBox(w: double.infinity, h: double.infinity),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(w: 120, h: 12),
                SizedBox(height: 6),
                ShimmerBox(w: 70, h: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerAvatarRow extends StatelessWidget {
  final int count;
  const ShimmerAvatarRow({super.key, this.count = 8});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const ShimmerCircle(size: 70),
      ),
    );
  }
}

class ShimmerHorizontalCards extends StatelessWidget {
  final int count;
  const ShimmerHorizontalCards({super.key, this.count = 6});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(5),
                child: ShimmerBox(
                  w: double.infinity,
                  h: 140,
                  r: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ShimmerBox(w: 130, h: 14),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ShimmerBox(w: 80, h: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerSquareGrid extends StatelessWidget {
  final int count, cross;
  const ShimmerSquareGrid({super.key, this.count = 6, this.cross = 3});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, __) => const ShimmerBox(
          w: double.infinity,
          h: double.infinity,
          r: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

class ShimmerPopularRow extends StatelessWidget {
  final int count;
  const ShimmerPopularRow({super.key, this.count = 8});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: ShimmerBox(
                  w: double.infinity,
                  h: 100,
                  r: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ShimmerBox(w: 120, h: 12),
              ),
              SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ShimmerBox(w: 60, h: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerJFYGrid extends StatelessWidget {
  final int count;
  const ShimmerJFYGrid({super.key, this.count = 4});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ShimmerBox(
                    w: double.infinity,
                    h: double.infinity,
                    r: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: ShimmerBox(w: 120, h: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
