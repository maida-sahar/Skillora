import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import 'career_applications_list_screen.dart';
import 'deadline_tracker_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Applications & Opportunities',
          style: AppTypography.displayMedium.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.headingDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_outlined), text: 'Career Applications'),
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Deadline Tracker'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CareerApplicationsListScreen(),
          DeadlineTrackerScreen(),
        ],
      ),
    );
  }
}
