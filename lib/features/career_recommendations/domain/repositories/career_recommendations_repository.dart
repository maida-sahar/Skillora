abstract class CareerRecommendationsRepository {
  /// Each entry: {'career': CareerModel, 'matchScore': int, 'reason': String}
  Future<List<Map<String, dynamic>>> getRecommendations(String userId);
}
