import 'package:flutter/material.dart';
import '../config/routes/route_names.dart';

/// TEMPORARY — testing-only menu so Member 2's features (which aren't
/// linked from the real Home screen / Admin Dashboard yet, since those
/// belong to Member 3) can be reached and tested individually.
/// Delete this file + its entry point in HomeScreen once Member 3's
/// navigation wires these routes into the real UI.
class DevTestMenuScreen extends StatelessWidget {
  const DevTestMenuScreen({super.key});

  static const _routes = [
    ('Skill Assessment', RouteNames.skillAssessment),
    ('Skill Gap Analysis', RouteNames.skillGapAnalysis),
    ('Career Recommendations', RouteNames.careerRecommendations),
    ('Scholarship Eligibility', RouteNames.scholarshipEligibility),
    ('Learning Roadmap', RouteNames.learningRoadmap),
    ('Courses & Resources', RouteNames.coursesResources),
    ('Admin: Skill Management', RouteNames.adminSkillManagement),
    ('Admin: Reports & Analytics', RouteNames.adminReportsAnalytics),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Test Menu (Member 2)')),
      body: ListView(
        children: _routes
            .map((r) => ListTile(
                  title: Text(r.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(r.$2),
                ))
            .toList(),
      ),
    );
  }
}
