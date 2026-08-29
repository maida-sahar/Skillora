import 'dart:io';

import '../../data/models/document_model.dart';

abstract class DocumentsRepository {
  /// Uploads [file] via the `uploadDocumentFile` Cloud Function (which
  /// relays it into the private Supabase "user-documents" bucket using
  /// the service role key), then records it in Firestore.
  Future<DocumentModel> uploadDocument({
    required String userId,
    required String documentType,
    required File file,
  });

  Stream<List<DocumentModel>> watchUserDocuments(String userId);

  /// Gets a short-lived signed URL for viewing a document, via the
  /// `getDocumentSignedUrl` Cloud Function.
  Future<String> getViewUrl(String storagePath);

  Future<void> deleteDocument({
    required String documentId,
    required String storagePath,
  });
}
