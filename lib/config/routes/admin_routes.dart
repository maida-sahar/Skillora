import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../admin/document_verification/presentation/screens/document_verification_screen.dart';

/// Builder for admin feature routes
class AdminRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.adminDashboard: (context) => const Scaffold(body: Center(child: Text('Admin Dashboard'))),
        RouteNames.adminUserManagement: (context) => const Scaffold(body: Center(child: Text('User Management'))),
        RouteNames.adminCareerManagement: (context) => const Scaffold(body: Center(child: Text('Career Management'))),
        RouteNames.adminSkillManagement: (context) => const Scaffold(body: Center(child: Text('Skill Management'))),
        RouteNames.adminScholarshipManagement: (context) => const Scaffold(body: Center(child: Text('Scholarship Management'))),
        RouteNames.adminDocumentVerification: (context) => const DocumentVerificationScreen(),
        RouteNames.adminMentorManagement: (context) => const Scaffold(body: Center(child: Text('Mentor Management'))),
        RouteNames.adminJobManagement: (context) => const Scaffold(body: Center(child: Text('Job/Internship Management'))),
        RouteNames.adminApplicationManagement: (context) => const Scaffold(body: Center(child: Text('Application Management'))),
        RouteNames.adminNotificationManagement: (context) => const Scaffold(body: Center(child: Text('Notification Management'))),
        RouteNames.adminReportsAnalytics: (context) => const Scaffold(body: Center(child: Text('Reports & Analytics'))),
        RouteNames.adminSettings: (context) => const Scaffold(body: Center(child: Text('Admin Settings'))),
      };
}
