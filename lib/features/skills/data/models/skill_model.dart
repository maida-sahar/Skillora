import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String level; // 'Beginner' | 'Intermediate' | 'Advanced'
  final DateTime createdAt;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.level = 'Intermediate',
    required this.createdAt,
  });

  factory SkillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SkillModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      description: data['description'] as String? ?? '',
      level: data['level'] as String? ?? 'Intermediate',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
