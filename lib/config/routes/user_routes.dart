import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/applications/presentation/screens/applications_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../admin/admin_dashboard/presentation/screens/explore/explore_screen.dart';
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
        RouteNames.careers: (context) => const ExploreScreen(),
        RouteNames.scholarships: (context) => const ExploreScreen(),
        RouteNames.applications: (context) => const ApplicationsScreen(),
        RouteNames.notifications: (context) => const NotificationsScreen(),
        RouteNames.settings: (context) => const SettingsScreen(),
      };
}

