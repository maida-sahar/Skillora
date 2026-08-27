import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';

/// Builder for user feature routes
class UserRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.initial: (context) => const AuthGate(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.register: (context) => const SignupScreen(),
        RouteNames.forgotPassword: (context) => const ForgotPasswordScreen(),
        RouteNames.home: (context) => const HomeScreen(),
        RouteNames.profile: (context) => const ProfileScreen(),
        RouteNames.portfolio: (context) => const PortfolioScreen(),
      };
}
