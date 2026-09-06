import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/documents_repository.dart';
import '../models/document_model.dart';

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
  static const _maxBytes = 10 * 1024 * 1024; // 10 MB limit
  static const _allowedExtensions = {'png', 'jpg', 'jpeg', 'pdf'};

  @override
  Future<DocumentModel> uploadDocument({
    required String userId,
    required String documentType,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      if (userId.trim().isEmpty) {
        throw const ServerException('User authentication is required to upload documents.');
      }

      Uint8List bytes;
      if (fileBytes != null) {
        bytes = fileBytes;
      } else if (file != null) {
        bytes = await file.readAsBytes();
      } else {
        throw const ServerException('No document file or bytes provided for upload.');
      }

      final resolvedName = fileName ?? (file != null ? file.path.split('/').last : 'document.pdf');
      _assertAllowedExtension(resolvedName);

      if (bytes.length > _maxBytes) {
        throw const ServerException('Document file size exceeds the 10 MB limit.');
      }

      final ext = resolvedName.split('.').last.toLowerCase();
      final mimeType = ext == 'pdf' ? 'application/pdf' : 'image/$ext';
      final safeName = resolvedName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      // Upload to private bucket 'user-documents' using bytes
      await _storage.uploadFileBytes(
        _bucket,
        storagePath,
        bytes,
        contentType: mimeType,
      );

      final docRef = _firestore.collection(_collection).doc();
      final model = DocumentModel(
        id: docRef.id,
        userId: userId,
        documentType: documentType,
        fileName: resolvedName,
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
    // Generate secure temporary signed URL for private bucket access
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
    if (!_allowedExtensions.contains(ext)) {
      throw ServerException('Unsupported file type (.$ext). Only PNG, JPG, JPEG, and PDF documents are allowed.');
    }
  }
}

