import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/personal_information_screen.dart';
import '../../features/profile/presentation/screens/education_screen.dart';
import '../../features/profile/presentation/screens/achievements_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/portfolio/presentation/screens/public_portfolio_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/applications/presentation/screens/applications_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../admin/admin_dashboard/presentation/screens/explore/explore_screen.dart';
import '../../features/skill_assessment/presentation/screens/skill_assessment_screen.dart';
import '../../features/skill_gap_analysis/presentation/screens/skill_gap_analysis_screen.dart';
import '../../features/career_recommendations/presentation/screens/career_recommendations_screen.dart';
import '../../features/scholarship_eligibility/presentation/screens/scholarship_eligibility_screen.dart';
import '../../features/learning_roadmap/presentation/screens/learning_roadmap_screen.dart';
import '../../features/courses_resources/presentation/screens/courses_resources_screen.dart';
import '../../features/careers/presentation/screens/career_detail_screen.dart';
import '../../features/scholarships/presentation/screens/scholarship_detail_screen.dart';
import '../../features/mentors/presentation/screens/mentor_detail_screen.dart';
import '../../screens/app_shell.dart';
import '../../screens/onboarding_screen.dart';

import '../../features/profile/presentation/screens/saved_items_screen.dart';
import '../../features/profile/presentation/screens/work_experience_screen.dart';

/// Builder for user feature routes
class UserRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.initial: (context) => const AuthGate(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.register: (context) => const SignupScreen(),
        RouteNames.forgotPassword: (context) => const ForgotPasswordScreen(),
        RouteNames.onboarding: (context) => const OnboardingScreen(),
        RouteNames.home: (context) => const AppShell(),
        RouteNames.explore: (context) => const ExploreScreen(),
        RouteNames.profile: (context) => const ProfileScreen(),
        RouteNames.editProfile: (context) => const PersonalInformationScreen(),
        RouteNames.personalInformation: (context) => const PersonalInformationScreen(),
        RouteNames.education: (context) => const EducationScreen(),
        RouteNames.achievements: (context) => const AchievementsScreen(),
        RouteNames.workExperience: (context) => const WorkExperienceScreen(),
        RouteNames.savedItems: (context) => const SavedItemsScreen(),
        RouteNames.portfolio: (context) => const PortfolioScreen(),
        RouteNames.publicPortfolio: (context) => const PublicPortfolioScreen(),
        RouteNames.documents: (context) => const DocumentsScreen(),
        RouteNames.skillAssessment: (context) => const SkillAssessmentScreen(),
        RouteNames.skillGapAnalysis: (context) => const SkillGapAnalysisScreen(),
        RouteNames.careerRecommendations: (context) => const CareerRecommendationsScreen(),
        RouteNames.scholarshipEligibility: (context) => const ScholarshipEligibilityScreen(),
        RouteNames.learningRoadmap: (context) => const LearningRoadmapScreen(),
        RouteNames.coursesResources: (context) => const CoursesResourcesScreen(),
        RouteNames.careers: (context) => const ExploreScreen(),
        RouteNames.careerDetails: (context) => const CareerDetailScreen(),
        RouteNames.scholarships: (context) => const ExploreScreen(),
        RouteNames.scholarshipDetails: (context) => const ScholarshipDetailScreen(),
        RouteNames.mentors: (context) => const ExploreScreen(),
        RouteNames.mentorDetails: (context) => const MentorDetailScreen(),
        RouteNames.applications: (context) => const ApplicationsScreen(),
        RouteNames.notifications: (context) => const NotificationsScreen(),
        RouteNames.settings: (context) => const SettingsScreen(),
      };
}

