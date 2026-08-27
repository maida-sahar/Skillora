import 'package:cloud_firestore/cloud_firestore.dart';

class MentorModel {
  final String id;
  final String userId;
  final String name;
  final String? profileImage;
  final String bio;
  final List<String> expertise;
  final String experience;
  final List<String> availability;
  final double rating;
  final String status; // 'available' | 'busy' | 'offline'
  final DateTime createdAt;
  final DateTime updatedAt;

  const MentorModel({
    required this.id,
    required this.userId,
    required this.name,
    this.profileImage,
    required this.bio,
    this.expertise = const [],
    required this.experience,
    this.availability = const [],
    this.rating = 5.0,
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
  });

  factory MentorModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MentorModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      profileImage: data['profileImage'] as String?,
      bio: data['bio'] as String? ?? '',
      expertise: List<String>.from(data['expertise'] ?? []),
      experience: data['experience'] as String? ?? '',
      availability: List<String>.from(data['availability'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      status: data['status'] as String? ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'profileImage': profileImage,
      'bio': bio,
      'expertise': expertise,
      'experience': experience,
      'availability': availability,
      'rating': rating,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
