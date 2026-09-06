import '../../../careers/data/models/career_model.dart';

abstract class SkillGapRepository {
  Future<List<CareerModel>> getCareers();

  Future<Map<String, dynamic>> analyzeGap({
    required String userId,
    required CareerModel targetCareer,
  });
}
