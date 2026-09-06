import 'package:flutter/material.dart';

import '../../data/models/skill_model.dart';
import '../../data/models/user_skill_model.dart';
import '../../data/repositories/skills_repository_impl.dart';
import '../../domain/repositories/skills_repository.dart';

/// Shared across Skill Assessment, Skill Gap Analysis and Admin Skill
/// Management — they all read/write the same catalog + user_skills data.
class SkillsProvider with ChangeNotifier {
  final SkillsRepository _repository;

  SkillsProvider({SkillsRepository? repository})
      : _repository = repository ?? SkillsRepositoryImpl();

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Stream<List<SkillModel>> watchCatalog() => _repository.watchCatalog();

  Future<List<SkillModel>> getCatalogOnce() => _repository.getCatalogOnce();

  Stream<List<UserSkillModel>> watchUserSkills(String userId) =>
      _repository.watchUserSkills(userId);

  Future<List<UserSkillModel>> getUserSkillsOnce(String userId) =>
      _repository.getUserSkillsOnce(userId);

  Future<bool> saveAssessment(List<UserSkillModel> results) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.saveAssessment(results);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- Admin: Skill Management ---

  Future<bool> addSkill(SkillModel skill) => _guarded(() => _repository.addSkill(skill));

  Future<bool> updateSkill(SkillModel skill) => _guarded(() => _repository.updateSkill(skill));

  Future<bool> deleteSkill(String skillId) => _guarded(() => _repository.deleteSkill(skillId));

  Future<bool> _guarded(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
