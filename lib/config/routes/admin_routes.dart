import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../admin/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../admin/user_management/presentation/screens/user_management_screen.dart';
import '../../admin/career_management/presentation/screens/career_management_screen.dart';
import '../../admin/skill_management/presentation/screens/skill_management_screen.dart';
import '../../admin/scholarship_management/presentation/screens/scholarship_management_screen.dart';
import '../../admin/job_internship_management/presentation/screens/job_management_screen.dart';
import '../../admin/mentor_management/presentation/screens/mentor_management_screen.dart';
import '../../admin/application_management/presentation/screens/application_management_screen.dart';
import '../../admin/document_verification/presentation/screens/document_verification_screen.dart';
import '../../admin/notification_management/presentation/screens/notification_management_screen.dart';
import '../../admin/reports_analytics/presentation/screens/reports_analytics_screen.dart';
import '../../admin/admin_settings/presentation/screens/admin_settings_screen.dart';

/// Builder for admin feature routes
class AdminRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.adminDashboard: (context) => const AdminDashboardScreen(),
        RouteNames.adminUserManagement: (context) => const UserManagementScreen(),
        RouteNames.adminCareerManagement: (context) => const CareerManagementScreen(),
        RouteNames.adminSkillManagement: (context) => const SkillManagementScreen(),
        RouteNames.adminScholarshipManagement: (context) => const ScholarshipManagementScreen(),
        RouteNames.adminJobManagement: (context) => const JobManagementScreen(),
        RouteNames.adminMentorManagement: (context) => const MentorManagementScreen(),
        RouteNames.adminApplicationManagement: (context) => const ApplicationManagementScreen(),
        RouteNames.adminDocumentVerification: (context) => const DocumentVerificationScreen(),
        RouteNames.adminNotificationManagement: (context) => const NotificationManagementScreen(),
        RouteNames.adminReportsAnalytics: (context) => const ReportsAnalyticsScreen(),
        RouteNames.adminSettings: (context) => const AdminSettingsScreen(),
      };
}

