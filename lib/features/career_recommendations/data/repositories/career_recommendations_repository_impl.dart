import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/ai/recommendation_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../careers/data/models/career_model.dart';
import '../../../skills/data/repositories/skills_repository_impl.dart';
import '../../../skills/domain/repositories/skills_repository.dart';
import '../../domain/repositories/career_recommendations_repository.dart';

class CareerRecommendationsRepositoryImpl implements CareerRecommendationsRepository {
  final FirebaseFirestore _firestore;
  final SkillsRepository _skillsRepository;
  final RecommendationService _recommendationService;

  CareerRecommendationsRepositoryImpl({
    FirebaseFirestore? firestore,
    SkillsRepository? skillsRepository,
    RecommendationService? recommendationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _skillsRepository = skillsRepository ?? SkillsRepositoryImpl(),
        _recommendationService = recommendationService ?? RecommendationService();

  @override
  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    try {
      final careersSnap = await _firestore.collection('careers').get();
      final careers = careersSnap.docs.map(CareerModel.fromFirestore).toList();
      if (careers.isEmpty) return [];

      final userSkills = await _skillsRepository.getUserSkillsOnce(userId);
      final skillNames = userSkills.map((s) => s.skillName).toList();

      final ranked = await _recommendationService.getPersonalizedRecommendations(
        userId: userId,
        currentSkills: skillNames,
        // No separate "interests" input exists yet in the app — skills
        // are used as a stand-in signal until one is added.
        interests: skillNames,
        availableCareers: careers
            .map((c) => {'id': c.id, 'title': c.title, 'requiredSkills': c.requiredSkills})
            .toList(),
      );

      return ranked.map((r) {
        final career = careers.firstWhere(
          (c) => c.id == r['careerId'],
          orElse: () => careers.first,
        );
        return {
          'career': career,
          'matchScore': r['matchScore'] ?? 0,
          'reason': r['reason'] ?? '',
        };
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get recommendations: ${e.toString()}');
    }
  }
}
