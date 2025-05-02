import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable shimmer widget that can be used to show loading states
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

/// Rectangular shimmer placeholder for images, cards, etc.
class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer effect for list items with customizable layout
class ShimmerListItem extends StatelessWidget {
  final double height;
  final bool hasLeadingCircle;
  final bool hasTrailingBox;
  final int lines;
  final EdgeInsets padding;

  const ShimmerListItem({
    super.key,
    this.height = 80,
    this.hasLeadingCircle = true,
    this.hasTrailingBox = false,
    this.lines = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ShimmerLoading(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasLeadingCircle)
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 16),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  lines,
                  (index) => Container(
                    width: index == 0 ? double.infinity : 150,
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            if (hasTrailingBox)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grid of shimmer containers
class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final double itemHeight;
  final double itemWidth;
  final int itemCount;
  final double spacing;
  
  const ShimmerGrid({
    super.key, 
    this.crossAxisCount = 2,
    this.itemHeight = 100, 
    this.itemWidth = 150,
    this.itemCount = 4,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerContainer(
          width: itemWidth,
          height: itemHeight,
        );
      },
    );
  }
}

/// Dashboard-specific shimmer loading layout
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerContainer(width: 200, height: 30),
              ShimmerContainer(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
            ],
          ),
          const SizedBox(height: 24),
          
          // Statistics grid shimmer
          const ShimmerGrid(),
          
          const SizedBox(height: 24),
          
          // List items
          ...List.generate(
            4, 
            (index) => const ShimmerListItem(),
          ),
        ],
      ),
    );
  }
}