import '../../../scholarships/data/models/scholarship_model.dart';

/// A scholarship checked against the student's profile.
class EligibilityResult {
  final ScholarshipModel scholarship;
  final int matchedCount;
  final int totalCriteria;
  final bool fieldMatches;
  final bool countryMatches;

  const EligibilityResult({
    required this.scholarship,
    required this.matchedCount,
    required this.totalCriteria,
    required this.fieldMatches,
    required this.countryMatches,
  });

  /// 0-100. Field + country are weighted like any other criterion so a
  /// scholarship with no listed criteria doesn't wrongly show 100%.
  int get scorePercent {
    final total = totalCriteria + 2;
    final matched = matchedCount + (fieldMatches ? 1 : 0) + (countryMatches ? 1 : 0);
    if (total == 0) return 0;
    return ((matched / total) * 100).round();
  }
}

abstract class EligibilityRepository {
  Future<List<ScholarshipModel>> getOpenScholarships();
}
