abstract class IRecommendationEngine {
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
    required List<String> currentSkills,
    required List<String> interests,
  });

  Future<Map<String, dynamic>> analyzeSkillGap({
    required List<String> currentSkills,
    required String targetCareerId,
  });
}
