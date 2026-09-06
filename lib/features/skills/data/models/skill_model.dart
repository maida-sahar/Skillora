import 'package:cloud_firestore/cloud_firestore.dart';

/// A master catalog skill (e.g. "Flutter", "SQL") managed by admins via
/// Admin Skill Management, and referenced by Careers, Skill Assessment,
/// and Skill Gap Analysis.
class SkillModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final DateTime createdAt;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    required this.createdAt,
  });

  factory SkillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SkillModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
