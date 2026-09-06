import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // 'Full-time' | 'Part-time' | 'Internship' | 'Remote'
  final String description;
  final List<String> requiredSkills;
  final double? salaryRangeMin;
  final double? salaryRangeMax;
  final DateTime deadline;
  final String status; // 'Open' | 'Closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    this.requiredSkills = const [],
    this.salaryRangeMin,
    this.salaryRangeMax,
    required this.deadline,
    this.status = 'Open',
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      company: data['company'] as String? ?? '',
      location: data['location'] as String? ?? 'Remote',
      type: data['type'] as String? ?? 'Full-time',
      description: data['description'] as String? ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      salaryRangeMin: (data['salaryRangeMin'] as num?)?.toDouble(),
      salaryRangeMax: (data['salaryRangeMax'] as num?)?.toDouble(),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'Open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'requiredSkills': requiredSkills,
      'salaryRangeMin': salaryRangeMin,
      'salaryRangeMax': salaryRangeMax,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
