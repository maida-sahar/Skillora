import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collections = <String, String>{
    'Users': 'users',
    'Careers': 'careers',
    'Scholarships': 'scholarships',
    'Skills in catalog': 'skills',
    'Skill assessments submitted': 'user_skills',
    'Learning roadmaps saved': 'learning_roadmaps',
    'Documents uploaded': 'documents',
    'Applications': 'applications',
    'Mentors': 'mentors',
    'Jobs/Internships': 'jobs',
  };

  @override
  Future<Map<String, int>> getCounts() async {
    final result = <String, int>{};
    for (final entry in _collections.entries) {
      try {
        final snap = await _firestore.collection(entry.value).count().get();
        result[entry.key] = snap.count ?? 0;
      } catch (e) {
        // A collection that doesn't exist yet (e.g. another member's
        // module isn't built) should show 0, not crash the dashboard.
        result[entry.key] = 0;
      }
    }
    return result;
  }
}
