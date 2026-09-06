import 'package:cloud_firestore/cloud_firestore.dart';

enum SkillLevel { beginner, intermediate, advanced }

SkillLevel skillLevelFromString(String value) {
  switch (value) {
    case 'intermediate':
      return SkillLevel.intermediate;
    case 'advanced':
      return SkillLevel.advanced;
    default:
      return SkillLevel.beginner;
  }
}

String skillLevelToString(SkillLevel level) => level.name;

/// A student's self-assessed level for one catalog skill.
/// Firestore doc id is "{userId}_{skillId}" so re-assessing a skill
/// overwrites the previous result instead of duplicating rows.
class UserSkillModel {
  final String userId;
  final String skillId;
  final String skillName;
  final String category;
  final SkillLevel level;
  final DateTime assessedAt;

  const UserSkillModel({
    required this.userId,
    required this.skillId,
    required this.skillName,
    required this.category,
    required this.level,
    required this.assessedAt,
  });

  factory UserSkillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserSkillModel(
      userId: data['userId'] as String? ?? '',
      skillId: data['skillId'] as String? ?? '',
      skillName: data['skillName'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      level: skillLevelFromString(data['level'] as String? ?? 'beginner'),
      assessedAt: (data['assessedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'skillId': skillId,
      'skillName': skillName,
      'category': category,
      'level': skillLevelToString(level),
      'assessedAt': Timestamp.fromDate(assessedAt),
    };
  }
}
