import 'package:flutter/material.dart';

import '../../data/models/roadmap_model.dart';
import '../../data/repositories/roadmap_repository_impl.dart';
import '../../domain/repositories/roadmap_repository.dart';

class RoadmapProvider with ChangeNotifier {
  final RoadmapRepository _repository;

  RoadmapProvider({RoadmapRepository? repository})
      : _repository = repository ?? RoadmapRepositoryImpl();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Stream<List<RoadmapModel>> watchRoadmaps(String userId) => _repository.watchRoadmaps(userId);

  /// Called from Skill Gap Analysis's "Save as Roadmap" button.
  Future<bool> saveFromGapAnalysis({
    required String userId,
    required String careerId,
    required String careerTitle,
    required List<String> missingSkills,
    required List<String> roadmapSteps,
  }) async {
    try {
      final roadmap = RoadmapModel(
        id: '${userId}_$careerId',
        userId: userId,
        careerId: careerId,
        careerTitle: careerTitle,
        missingSkills: missingSkills,
        steps: roadmapSteps.map((s) => RoadmapStep(text: s)).toList(),
        createdAt: DateTime.now(),
      );
      await _repository.saveRoadmap(roadmap);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleStep(String roadmapId, int stepIndex, bool completed) =>
      _repository.toggleStep(roadmapId, stepIndex, completed);

  Future<void> deleteRoadmap(String roadmapId) => _repository.deleteRoadmap(roadmapId);
}
