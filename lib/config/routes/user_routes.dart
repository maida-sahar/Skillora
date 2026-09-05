import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../screens/app_shell.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/skill_assessment_screen.dart';

/// Builder for user feature routes
class UserRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.initial: (context) => const AuthGate(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.register: (context) => const SignupScreen(),
        RouteNames.forgotPassword: (context) => const ForgotPasswordScreen(),
        RouteNames.onboarding: (context) => const OnboardingScreen(),
        RouteNames.home: (context) => const AppShell(),
        RouteNames.profile: (context) => const ProfileScreen(),
        RouteNames.portfolio: (context) => const PortfolioScreen(),
        RouteNames.documents: (context) => const DocumentsScreen(),
        RouteNames.skillAssessment: (context) => const SkillAssessmentScreen(),
      };
}
