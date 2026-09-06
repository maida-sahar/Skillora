import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes/app_router.dart';
import '../config/theme/app_theme.dart';
import '../config/constants/app_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/profile/presentation/providers/profile_provider.dart';
import '../features/portfolio/presentation/providers/portfolio_provider.dart';
import '../features/documents/presentation/providers/documents_provider.dart';
import '../admin/document_verification/presentation/providers/document_verification_provider.dart';
import '../features/skills/presentation/providers/skills_provider.dart';
import '../features/skill_assessment/presentation/providers/skill_assessment_provider.dart';
import '../features/skill_gap_analysis/presentation/providers/skill_gap_provider.dart';
import '../features/career_recommendations/presentation/providers/career_recommendations_provider.dart';
import '../features/scholarship_eligibility/presentation/providers/eligibility_provider.dart';
import '../features/learning_roadmap/presentation/providers/roadmap_provider.dart';
import '../features/courses_resources/presentation/providers/courses_provider.dart';
import '../admin/reports_analytics/presentation/providers/reports_provider.dart';

class SkilloraApp extends StatelessWidget {
  const SkilloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()),
        ChangeNotifierProvider(create: (_) => DocumentVerificationProvider()),
        ChangeNotifierProvider(create: (_) => SkillsProvider()),
        ChangeNotifierProvider(create: (_) => SkillAssessmentProvider()),
        ChangeNotifierProvider(create: (_) => SkillGapProvider()),
        ChangeNotifierProvider(create: (_) => CareerRecommendationsProvider()),
        ChangeNotifierProvider(create: (_) => EligibilityProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
