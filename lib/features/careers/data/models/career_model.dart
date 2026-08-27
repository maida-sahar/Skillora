import 'package:cloud_firestore/cloud_firestore.dart';

class CareerModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final String education;
  final String careerLevel;
  final List<String> relatedCourses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CareerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.requiredSkills = const [],
    required this.education,
    required this.careerLevel,
    this.relatedCourses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CareerModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CareerModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      education: data['education'] as String? ?? '',
      careerLevel: data['careerLevel'] as String? ?? 'Entry Level',
      relatedCourses: List<String>.from(data['relatedCourses'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'requiredSkills': requiredSkills,
      'education': education,
      'careerLevel': careerLevel,
      'relatedCourses': relatedCourses,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
