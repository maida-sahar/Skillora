import '../../data/models/skill_model.dart';
import '../../data/models/user_skill_model.dart';

abstract class SkillsRepository {
  /// Master catalog — used by Skill Assessment, Skill Gap Analysis and
  /// Admin Skill Management.
  Stream<List<SkillModel>> watchCatalog();

  Future<List<SkillModel>> getCatalogOnce();

  Future<void> addSkill(SkillModel skill);

  Future<void> updateSkill(SkillModel skill);

  Future<void> deleteSkill(String skillId);

  /// The signed-in user's self-assessed skills.
  Stream<List<UserSkillModel>> watchUserSkills(String userId);

  Future<List<UserSkillModel>> getUserSkillsOnce(String userId);

  Future<void> saveAssessment(List<UserSkillModel> results);
}
