import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.child,
  });

  const AppShimmer.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        child = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.cardDark : AppColors.softBlue;
    final highlightColor = isDark ? const Color(0xFF2A2E46) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
    );
  }
}

class AppShimmerCardList extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  const AppShimmerCardList({
    super.key,
    this.itemCount = 4,
    this.cardHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return AppShimmer(
          width: double.infinity,
          height: cardHeight,
          borderRadius: 16,
        );
      },
    );
  }
}
