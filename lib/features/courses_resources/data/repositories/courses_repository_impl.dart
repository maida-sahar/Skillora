import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/courses_repository.dart';
import '../models/course_model.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final FirebaseFirestore _firestore;

  CoursesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'courses';

  @override
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final snap = await _firestore.collection(_collection).get();
      return snap.docs.map(CourseModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load courses: ${e.toString()}');
    }
  }

  @override
  Future<List<CourseModel>> getCoursesForSkills(List<String> skillNames) async {
    if (skillNames.isEmpty) return getAllCourses();
    try {
      // Firestore whereIn caps at 30 values — trim defensively.
      final tags = skillNames.take(30).toList();
      final snap = await _firestore
          .collection(_collection)
          .where('skillTags', arrayContainsAny: tags)
          .get();
      return snap.docs.map(CourseModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load courses: ${e.toString()}');
    }
  }
}
