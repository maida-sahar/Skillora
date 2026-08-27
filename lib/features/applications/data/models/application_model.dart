import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String userId;
  final String? scholarshipId;
  final String? jobId;
  final String applicationType; // 'scholarship' | 'job'
  final String status; // 'Saved' | 'Applied' | 'Under Review' | 'Interview' | 'Accepted' | 'Rejected'
  final DateTime? submittedAt;
  final DateTime? deadline;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApplicationModel({
    required this.id,
    required this.userId,
    this.scholarshipId,
    this.jobId,
    required this.applicationType,
    this.status = 'Applied',
    this.submittedAt,
    this.deadline,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ApplicationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      scholarshipId: data['scholarshipId'] as String?,
      jobId: data['jobId'] as String?,
      applicationType: data['applicationType'] as String? ?? 'scholarship',
      status: data['status'] as String? ?? 'Applied',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'scholarshipId': scholarshipId,
      'jobId': jobId,
      'applicationType': applicationType,
      'status': status,
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
