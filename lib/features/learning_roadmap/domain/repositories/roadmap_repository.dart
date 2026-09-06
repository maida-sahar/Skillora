import '../../data/models/roadmap_model.dart';

abstract class RoadmapRepository {
  Stream<List<RoadmapModel>> watchRoadmaps(String userId);

  Future<void> saveRoadmap(RoadmapModel roadmap);

  Future<void> toggleStep(String roadmapId, int stepIndex, bool completed);

  Future<void> deleteRoadmap(String roadmapId);
}
