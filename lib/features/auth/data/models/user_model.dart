import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final List<String> skillsList;
  final List<String> interestsList;
  final List<String> careerGoalsList;
  final String? educationField;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.role,
    super.avatarUrl,
    this.educationField,
    this.skillsList = const [],
    this.interestsList = const [],
    this.careerGoalsList = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['name'] as String? ?? data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      avatarUrl: data['profileImage'] as String? ?? data['avatarUrl'] as String?,
      educationField: data['education'] as String?,
      skillsList: List<String>.from(data['skills'] ?? []),
      interestsList: List<String>.from(data['interests'] ?? []),
      careerGoalsList: List<String>.from(data['careerGoals'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] as String? ?? '',
      displayName: data['name'] as String? ?? data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      avatarUrl: data['profileImage'] as String? ?? data['avatarUrl'] as String?,
      educationField: data['education'] as String?,
      skillsList: List<String>.from(data['skills'] ?? []),
      interestsList: List<String>.from(data['interests'] ?? []),
      careerGoalsList: List<String>.from(data['careerGoals'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': displayName,
      'email': email,
      'profileImage': avatarUrl,
      'role': role,
      'education': educationField,
      'skills': skillsList,
      'interests': interestsList,
      'careerGoals': careerGoalsList,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? avatarUrl,
    String? educationField,
    List<String>? skillsList,
    List<String>? interestsList,
    List<String>? careerGoalsList,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      educationField: educationField ?? this.educationField,
      skillsList: skillsList ?? this.skillsList,
      interestsList: interestsList ?? this.interestsList,
      careerGoalsList: careerGoalsList ?? this.careerGoalsList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
