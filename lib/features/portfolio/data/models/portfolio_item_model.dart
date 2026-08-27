import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioItemModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String imageUrl;
  final String? projectUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PortfolioItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.projectUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PortfolioItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PortfolioItemModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      projectUrl: data['projectUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'projectUrl': projectUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
