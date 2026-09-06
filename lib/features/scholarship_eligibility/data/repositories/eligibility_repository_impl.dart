import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../scholarships/data/models/scholarship_model.dart';
import '../../domain/repositories/eligibility_repository.dart';

class EligibilityRepositoryImpl implements EligibilityRepository {
  final FirebaseFirestore _firestore;

  EligibilityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ScholarshipModel>> getOpenScholarships() async {
    try {
      final snap = await _firestore
          .collection('scholarships')
          .where('status', isEqualTo: 'Open')
          .get();
      return snap.docs.map(ScholarshipModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load scholarships: ${e.toString()}');
    }
  }
}
