import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/chips/app_chip.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Skillora Admin Panel', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: authProvider.isLoading ? null : () async => await authProvider.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin User Badge Header
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Admin Account',
                            style: AppTypography.titleMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const AppChip(label: 'ADMINISTRATOR', variant: AppChipVariant.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Banner
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, userSnap) {
                  final userCount = userSnap.data?.docs.length ?? 0;
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('applications').snapshots(),
                    builder: (context, appSnap) {
                      final appCount = appSnap.data?.docs.length ?? 0;
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('documents').snapshots(),
                        builder: (context, docSnap) {
                          final pendingDocs = docSnap.data?.docs
                                  .where((d) => d.data()['status'] == 'pending')
                                  .length ??
                              0;

                          return Row(
                            children: [
                              _buildMetricTile(context, 'Total Users', '$userCount', AppColors.primary, AppColors.softBlue),
                              const SizedBox(width: 10),
                              _buildMetricTile(context, 'Applications', '$appCount', AppColors.success, AppColors.successLight),
                              const SizedBox(width: 10),
                              _buildMetricTile(context, 'Pending Review', '$pendingDocs', AppColors.warning, AppColors.warningLight),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Management Modules',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildAdminCard(context, Icons.people_outline, 'Users', RouteNames.adminUserManagement),
                    _buildAdminCard(context, Icons.work_outline, 'Careers', RouteNames.adminCareerManagement),
                    _buildAdminCard(context, Icons.stars_outlined, 'Skills', RouteNames.adminSkillManagement),
                    _buildAdminCard(context, Icons.school_outlined, 'Scholarships', RouteNames.adminScholarshipManagement),
                    _buildAdminCard(context, Icons.business_center_outlined, 'Jobs', RouteNames.adminJobManagement),
                    _buildAdminCard(context, Icons.person_pin_outlined, 'Mentors', RouteNames.adminMentorManagement),
                    _buildAdminCard(context, Icons.assignment_outlined, 'Apps', RouteNames.adminApplicationManagement),
                    _buildAdminCard(context, Icons.verified_user_outlined, 'Doc Review', RouteNames.adminDocumentVerification),
                    _buildAdminCard(context, Icons.notifications_outlined, 'Notifs', RouteNames.adminNotificationManagement),
                    _buildAdminCard(context, Icons.bar_chart_rounded, 'Reports', RouteNames.adminReportsAnalytics),
                    _buildAdminCard(context, Icons.settings_outlined, 'Settings', RouteNames.adminSettings),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String count, Color textColor, Color bgColor) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        backgroundColor: bgColor,
        borderColor: textColor.withOpacity(0.3),
        child: Column(
          children: [
            Text(count, style: AppTypography.displayMedium.copyWith(color: textColor)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.labelSmall.copyWith(color: textColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, IconData icon, String title, String routeName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(routeName),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
