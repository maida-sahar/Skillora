import 'package:cloud_firestore/cloud_firestore.dart';

/// A learning resource (course, article, video, etc). Seeded via
/// Firestore console/import for now — no dedicated admin CRUD module
/// was in the 12-module Admin Panel scope for this project.
class CourseModel {
  final String id;
  final String title;
  final String provider;
  final String url;
  final String type; // Course, Video, Article, Book
  final String category;
  final List<String> skillTags;

  const CourseModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.url,
    this.type = 'Course',
    this.category = 'General',
    this.skillTags = const [],
  });

  factory CourseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CourseModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      provider: data['provider'] as String? ?? '',
      url: data['url'] as String? ?? '',
      type: data['type'] as String? ?? 'Course',
      category: data['category'] as String? ?? 'General',
      skillTags: List<String>.from(data['skillTags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'provider': provider,
      'url': url,
      'type': type,
      'category': category,
      'skillTags': skillTags,
    };
  }
}
