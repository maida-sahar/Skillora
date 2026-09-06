import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/skills_repository.dart';
import '../models/skill_model.dart';
import '../models/user_skill_model.dart';

class SkillsRepositoryImpl implements SkillsRepository {
  final FirebaseFirestore _firestore;

  SkillsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _skillsCollection = 'skills';
  static const _userSkillsCollection = 'user_skills';

  @override
  Stream<List<SkillModel>> watchCatalog() {
    return _firestore
        .collection(_skillsCollection)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(SkillModel.fromFirestore).toList());
  }

  @override
  Future<List<SkillModel>> getCatalogOnce() async {
    final snap = await _firestore.collection(_skillsCollection).orderBy('name').get();
    return snap.docs.map(SkillModel.fromFirestore).toList();
  }

  @override
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _firestore.collection(_skillsCollection).add(skill.toFirestore());
    } catch (e) {
      throw ServerException('Failed to add skill: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSkill(SkillModel skill) async {
    try {
      await _firestore.collection(_skillsCollection).doc(skill.id).update(skill.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update skill: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSkill(String skillId) async {
    try {
      await _firestore.collection(_skillsCollection).doc(skillId).delete();
    } catch (e) {
      throw ServerException('Failed to delete skill: ${e.toString()}');
    }
  }

  @override
  Stream<List<UserSkillModel>> watchUserSkills(String userId) {
    return _firestore
        .collection(_userSkillsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(UserSkillModel.fromFirestore).toList());
  }

  @override
  Future<List<UserSkillModel>> getUserSkillsOnce(String userId) async {
    final snap = await _firestore
        .collection(_userSkillsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs.map(UserSkillModel.fromFirestore).toList();
  }

  @override
  Future<void> saveAssessment(List<UserSkillModel> results) async {
    try {
      final batch = _firestore.batch();
      for (final result in results) {
        final docId = '${result.userId}_${result.skillId}';
        final ref = _firestore.collection(_userSkillsCollection).doc(docId);
        batch.set(ref, result.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to save assessment: ${e.toString()}');
    }
  }
}
