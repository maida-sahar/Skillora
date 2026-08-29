import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentStatus { pending, verified, rejected }

DocumentStatus documentStatusFromString(String value) {
  switch (value) {
    case 'verified':
      return DocumentStatus.verified;
    case 'rejected':
      return DocumentStatus.rejected;
    default:
      return DocumentStatus.pending;
  }
}

String documentStatusToString(DocumentStatus status) => status.name;

/// A verification document (CNIC, transcript, certificate, etc).
/// The actual file lives in the private "user-documents" Supabase bucket —
/// only [storagePath] (never a public URL) is stored here. Viewing a
/// document always goes through the `getDocumentSignedUrl` Cloud Function.
class DocumentModel {
  final String id;
  final String userId;
  final String documentType;
  final String fileName;
  final String storagePath;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.fileName,
    required this.storagePath,
    required this.status,
    required this.uploadedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DocumentModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      documentType: data['documentType'] as String? ?? 'other',
      fileName: data['fileName'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      status: documentStatusFromString(data['status'] as String? ?? 'pending'),
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: data['verifiedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'documentType': documentType,
      'fileName': fileName,
      'storagePath': storagePath,
      'status': documentStatusToString(status),
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}
