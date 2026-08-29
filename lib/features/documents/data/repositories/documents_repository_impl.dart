import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/documents_repository.dart';
import '../models/document_model.dart';

/// NOTE: Free-plan (Spark) version — uploads/downloads go straight from
/// the Flutter app to Supabase using the anon key. There is no Cloud
/// Functions relay and no service-role-key gatekeeping. The
/// "user-documents" bucket stays non-public in the Supabase dashboard,
/// but its RLS policies allow the anon key full access — so protection
/// relies on paths being unguessable ({uid}/{timestamp}_{filename}),
/// not on real per-user access control. Upgrade to Blaze later and swap
/// this back to the Cloud Functions version for real security.
class DocumentsRepositoryImpl implements DocumentsRepository {
  final FirebaseFirestore _firestore;
  final SupabaseStorageService _storage;

  DocumentsRepositoryImpl({
    FirebaseFirestore? firestore,
    SupabaseStorageService? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? SupabaseStorageServiceImpl();

  static const _collection = 'documents';
  static const _bucket = 'user-documents';
  static const _maxBytes = 10 * 1024 * 1024; // matches Supabase bucket limit

  @override
  Future<DocumentModel> uploadDocument({
    required String userId,
    required String documentType,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      _assertAllowedExtension(fileName);

      final length = await file.length();
      if (length > _maxBytes) {
        throw const ServerException('File exceeds the 10MB limit.');
      }

      final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await _storage.uploadFile(_bucket, storagePath, file);

      final docRef = _firestore.collection(_collection).doc();
      final model = DocumentModel(
        id: docRef.id,
        userId: userId,
        documentType: documentType,
        fileName: fileName,
        storagePath: storagePath,
        status: DocumentStatus.pending,
        uploadedAt: DateTime.now(),
      );

      await docRef.set(model.toFirestore());
      return model;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to upload document: ${e.toString()}');
    }
  }

  @override
  Stream<List<DocumentModel>> watchUserDocuments(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DocumentModel.fromFirestore).toList());
  }

  @override
  Future<String> getViewUrl(String storagePath) async {
    // 10-minute signed URL — still expires even though RLS is anon-open,
    // so a leaked link doesn't work forever.
    return _storage.getSignedUrl(_bucket, storagePath, expiresInSeconds: 600);
  }

  @override
  Future<void> deleteDocument({
    required String documentId,
    required String storagePath,
  }) async {
    try {
      await _storage.deleteImage(_bucket, storagePath);
      await _firestore.collection(_collection).doc(documentId).delete();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete document: ${e.toString()}');
    }
  }

  void _assertAllowedExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const allowed = {'png', 'jpg', 'jpeg', 'pdf'};
    if (!allowed.contains(ext)) {
      throw ServerException('Unsupported file type: .$ext');
    }
  }
}
