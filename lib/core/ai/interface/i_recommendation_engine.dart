abstract class IRecommendationEngine {
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
    required List<String> currentSkills,
    required List<String> interests,
    List<Map<String, dynamic>>? availableCareers,
  });

  Future<Map<String, dynamic>> analyzeSkillGap({
    required List<String> currentSkills,
    required String targetCareerId,
    String? targetCareerTitle,
    List<String>? requiredSkills,
  });

  Future<Map<String, dynamic>> checkScholarshipEligibility({
    required Map<String, dynamic> studentProfile,
    required String scholarshipTitle,
    required List<String> eligibilityCriteria,
  });
}
