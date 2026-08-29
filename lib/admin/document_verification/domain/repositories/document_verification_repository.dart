import '../../../../features/documents/data/models/document_model.dart';

abstract class DocumentVerificationRepository {
  Stream<List<DocumentModel>> watchAllDocuments({String? statusFilter});

  /// Signed URL via the `getDocumentSignedUrl` Cloud Function — the admin
  /// role check happens server-side in that function.
  Future<String> getViewUrl(String storagePath);

  Future<void> updateStatus({
    required String documentId,
    required DocumentStatus status,
    required String verifiedBy,
    String? rejectionReason,
  });
}
