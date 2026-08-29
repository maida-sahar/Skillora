import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../../../features/documents/data/models/document_model.dart';
import '../../domain/repositories/document_verification_repository.dart';

/// NOTE: Free-plan (Spark) version — no Cloud Functions. Signed URLs are
/// generated directly with the Supabase anon key. See the note in
/// DocumentsRepositoryImpl for the security trade-off this implies.
class DocumentVerificationRepositoryImpl implements DocumentVerificationRepository {
  final FirebaseFirestore _firestore;
  final SupabaseStorageService _storage;

  DocumentVerificationRepositoryImpl({
    FirebaseFirestore? firestore,
    SupabaseStorageService? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? SupabaseStorageServiceImpl();

  static const _collection = 'documents';
  static const _bucket = 'user-documents';

  @override
  Stream<List<DocumentModel>> watchAllDocuments({String? statusFilter}) {
    Query<Map<String, dynamic>> query = _firestore.collection(_collection);
    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    query = query.orderBy('uploadedAt', descending: true);
    return query.snapshots().map(
          (snap) => snap.docs.map(DocumentModel.fromFirestore).toList(),
        );
  }

  @override
  Future<String> getViewUrl(String storagePath) async {
    return _storage.getSignedUrl(_bucket, storagePath, expiresInSeconds: 600);
  }

  @override
  Future<void> updateStatus({
    required String documentId,
    required DocumentStatus status,
    required String verifiedBy,
    String? rejectionReason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(documentId).update({
        'status': documentStatusToString(status),
        'verifiedAt': Timestamp.now(),
        'verifiedBy': verifiedBy,
        'rejectionReason': rejectionReason,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update document status.');
    } catch (e) {
      throw ServerException('Failed to update status: ${e.toString()}');
    }
  }
}
