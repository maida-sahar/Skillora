import 'package:flutter/material.dart';

import '../../../skills/data/models/skill_model.dart';
import '../../../skills/data/models/user_skill_model.dart';
import '../../../skills/data/repositories/skills_repository_impl.dart';
import '../../../skills/domain/repositories/skills_repository.dart';

/// Drives the self-assessment flow: load the shared skill catalog, let
/// the student rate each skill (Beginner/Intermediate/Advanced), and
/// save the results as [UserSkillModel]s via the shared SkillsRepository.
class SkillAssessmentProvider with ChangeNotifier {
  final SkillsRepository _repository;

  SkillAssessmentProvider({SkillsRepository? repository})
      : _repository = repository ?? SkillsRepositoryImpl();

  List<SkillModel> _catalog = [];
  final Map<String, SkillLevel> _ratings = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<SkillModel> get catalog => _catalog;
  Map<String, SkillLevel> get ratings => _ratings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadCatalog() async {
    _isLoading = true;
    notifyListeners();
    try {
      _catalog = await _repository.getCatalogOnce();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void rate(String skillId, SkillLevel level) {
    _ratings[skillId] = level;
    notifyListeners();
  }

  Future<bool> submit(String userId) async {
    if (_ratings.isEmpty) {
      _errorMessage = 'Kam az kam aik skill rate karein.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final results = _ratings.entries.map((entry) {
      final skill = _catalog.firstWhere((s) => s.id == entry.key);
      return UserSkillModel(
        userId: userId,
        skillId: skill.id,
        skillName: skill.name,
        category: skill.category,
        level: entry.value,
        assessedAt: now,
      );
    }).toList();

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
}
