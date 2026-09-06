import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/home_screen.dart';
import '../features/applications/presentation/screens/applications_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../shared/widgets/navigation/skillora_bottom_nav.dart';

/// Post-login shell for students: Clean Modern White Bottom Navigation Bar
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ApplicationsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SkilloraBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          SkilloraBottomNavItem(
            outlineIcon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          SkilloraBottomNavItem(
            outlineIcon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'Applications',
          ),
          SkilloraBottomNavItem(
            outlineIcon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Messages',
          ),
          SkilloraBottomNavItem(
            outlineIcon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
