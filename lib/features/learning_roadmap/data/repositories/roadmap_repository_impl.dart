import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/roadmap_repository.dart';
import '../models/roadmap_model.dart';

class RoadmapRepositoryImpl implements RoadmapRepository {
  final FirebaseFirestore _firestore;

  RoadmapRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'learning_roadmaps';

  @override
  Stream<List<RoadmapModel>> watchRoadmaps(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(RoadmapModel.fromFirestore).toList());
  }

  @override
  Future<void> saveRoadmap(RoadmapModel roadmap) async {
    try {
      final docId = '${roadmap.userId}_${roadmap.careerId}';
      await _firestore.collection(_collection).doc(docId).set(roadmap.toFirestore());
    } catch (e) {
      throw ServerException('Failed to save roadmap: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleStep(String roadmapId, int stepIndex, bool completed) async {
    try {
      final ref = _firestore.collection(_collection).doc(roadmapId);
      final doc = await ref.get();
      if (!doc.exists) return;
      final roadmap = RoadmapModel.fromFirestore(doc);
      final updatedSteps = List<RoadmapStep>.from(roadmap.steps);
      if (stepIndex < 0 || stepIndex >= updatedSteps.length) return;
      updatedSteps[stepIndex] = updatedSteps[stepIndex].copyWith(completed: completed);
      await ref.update({'steps': updatedSteps.map((s) => s.toMap()).toList()});
    } catch (e) {
      throw ServerException('Failed to update step: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRoadmap(String roadmapId) async {
    try {
      await _firestore.collection(_collection).doc(roadmapId).delete();
    } catch (e) {
      throw ServerException('Failed to delete roadmap: ${e.toString()}');
    }
  }
}
