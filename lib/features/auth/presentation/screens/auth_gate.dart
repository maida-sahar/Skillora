import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../../screens/app_shell.dart';
import '../../../../admin/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Skillora...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          final role = authProvider.currentUser?.role ?? 'student';
          if (role == 'admin') {
            return const AdminDashboardScreen();
          }
          return const AppShell();
        }

        return const LoginScreen();
      },
    );
  }
}
