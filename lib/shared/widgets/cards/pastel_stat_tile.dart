import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

enum PastelTileVariant { mint, orange, pink, blue }

class PastelStatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final PastelTileVariant variant;
  final VoidCallback? onTap;

  const PastelStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.variant = PastelTileVariant.mint,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (variant) {
      case PastelTileVariant.mint:
        return AppColors.pastelMintBg;
      case PastelTileVariant.orange:
        return AppColors.pastelOrangeBg;
      case PastelTileVariant.pink:
        return AppColors.pastelPinkBg;
      case PastelTileVariant.blue:
        return AppColors.pastelBlueBg;
    }
  }

  Color get _textColor {
    switch (variant) {
      case PastelTileVariant.mint:
        return AppColors.pastelMintText;
      case PastelTileVariant.orange:
        return AppColors.pastelOrangeText;
      case PastelTileVariant.pink:
        return AppColors.pastelPinkText;
      case PastelTileVariant.blue:
        return AppColors.pastelBlueText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTypography.displayMedium.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: _textColor.withValues(alpha: 0.8),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: _textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
