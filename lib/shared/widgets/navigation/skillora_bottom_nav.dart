import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SkilloraBottomNavItem {
  final IconData outlineIcon;
  final IconData activeIcon;
  final String label;

  const SkilloraBottomNavItem({
    required this.outlineIcon,
    required this.activeIcon,
    required this.label,
  });
}

class SkilloraBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SkilloraBottomNavItem> items;

  const SkilloraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      SkilloraBottomNavItem(
        outlineIcon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.search_rounded,
        activeIcon: Icons.search_rounded,
        label: 'Explore',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
        label: 'Applications',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.business_center_outlined,
        activeIcon: Icons.business_center_rounded,
        label: 'Portfolio',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.navBackgroundDark,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDark,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final item = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.outlineIcon,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.textMutedDark,
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textMutedDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
