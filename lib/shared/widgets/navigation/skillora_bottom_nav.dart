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
        outlineIcon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard_rounded,
        label: 'Home',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.auto_graph_outlined,
        activeIcon: Icons.auto_graph_rounded,
        label: 'Pathways',
      ),
      SkilloraBottomNavItem(
        outlineIcon: Icons.workspace_premium_outlined,
        activeIcon: Icons.workspace_premium_rounded,
        label: 'Skills',
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
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.outlineIcon,
                    size: 24,
                    color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    width: isSelected ? 16 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
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
