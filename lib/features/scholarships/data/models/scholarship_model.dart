import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore date fields are sometimes entered as a plain string in the
/// console (e.g. "12-12-2027") instead of a real Timestamp. Casting a
/// String directly to Timestamp throws, so this parses either shape
/// instead of crashing the whole document read.
DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) {
    // Try common formats: ISO (2027-12-12) and DD-MM-YYYY.
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final parts = value.split('-');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
  }
  return DateTime.now();
}

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
      deadline: _parseDate(data['deadline']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      applicationUrl: data['applicationUrl'] as String? ?? '',
      country: data['country'] as String? ?? '',
      status: data['status'] as String? ?? 'Open',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
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
