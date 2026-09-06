import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

enum AppChipVariant { primary, secondary, success, warning, error, info }

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppChipVariant variant;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppChipVariant.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case AppChipVariant.primary:
        bg = AppColors.softBlue;
        fg = AppColors.primaryDark;
        break;
      case AppChipVariant.secondary:
        bg = AppColors.lavenderLight;
        fg = AppColors.lavender;
        break;
      case AppChipVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case AppChipVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case AppChipVariant.error:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case AppChipVariant.info:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
