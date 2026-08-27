import 'package:cloud_firestore/cloud_firestore.dart';

class ScholarshipModel {
  final String id;
  final String title;
  final String organization;
  final String description;
  final String field;
  final List<String> eligibilityCriteria;
  final List<String> requiredDocuments;
  final DateTime deadline;
  final double amount;
  final String applicationUrl;
  final String country;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScholarshipModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.description,
    required this.field,
    this.eligibilityCriteria = const [],
    this.requiredDocuments = const [],
    required this.deadline,
    required this.amount,
    required this.applicationUrl,
    required this.country,
    this.status = 'Open',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScholarshipModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ScholarshipModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      organization: data['organization'] as String? ?? '',
      description: data['description'] as String? ?? '',
      field: data['field'] as String? ?? '',
      eligibilityCriteria: List<String>.from(data['eligibilityCriteria'] ?? []),
      requiredDocuments: List<String>.from(data['requiredDocuments'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      applicationUrl: data['applicationUrl'] as String? ?? '',
      country: data['country'] as String? ?? '',
      status: data['status'] as String? ?? 'Open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'description': description,
      'field': field,
      'eligibilityCriteria': eligibilityCriteria,
      'requiredDocuments': requiredDocuments,
      'deadline': Timestamp.fromDate(deadline),
      'amount': amount,
      'applicationUrl': applicationUrl,
      'country': country,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
