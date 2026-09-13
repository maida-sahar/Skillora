import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../shared/widgets/navigation/skillora_bottom_nav.dart';
import '../features/auth/presentation/screens/home_screen.dart';
import '../admin/admin_dashboard/presentation/screens/explore/explore_screen.dart';
import '../features/applications/presentation/screens/applications_screen.dart';
import '../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

/// Post-login shell for students: Premium Dark Bottom Navigation Bar
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    ApplicationsScreen(),
    PortfolioScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SkilloraBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

