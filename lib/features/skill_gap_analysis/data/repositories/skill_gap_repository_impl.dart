import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/ai/recommendation_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../careers/data/models/career_model.dart';
import '../../../skills/data/repositories/skills_repository_impl.dart';
import '../../../skills/domain/repositories/skills_repository.dart';
import '../../domain/repositories/skill_gap_repository.dart';

class SkillGapRepositoryImpl implements SkillGapRepository {
  final FirebaseFirestore _firestore;
  final SkillsRepository _skillsRepository;
  final RecommendationService _recommendationService;

  SkillGapRepositoryImpl({
    FirebaseFirestore? firestore,
    SkillsRepository? skillsRepository,
    RecommendationService? recommendationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _skillsRepository = skillsRepository ?? SkillsRepositoryImpl(),
        _recommendationService = recommendationService ?? RecommendationService();

  @override
  Future<List<CareerModel>> getCareers() async {
    final snap = await _firestore.collection('careers').get();
    return snap.docs.map(CareerModel.fromFirestore).toList();
  }

  @override
  Future<Map<String, dynamic>> analyzeGap({
    required String userId,
    required CareerModel targetCareer,
  }) async {
    try {
      final userSkills = await _skillsRepository.getUserSkillsOnce(userId);
      final currentSkillNames = userSkills.map((s) => s.skillName).toList();

      return await _recommendationService.analyzeSkillGap(
        currentSkills: currentSkillNames,
        targetCareerId: targetCareer.id,
        targetCareerTitle: targetCareer.title,
        requiredSkills: targetCareer.requiredSkills,
      );
    } catch (e) {
      throw ServerException('Failed to analyze skill gap: ${e.toString()}');
    }
  }
}
