import 'dart:io';
import 'dart:typed_data';

import '../../data/models/document_model.dart';

abstract class DocumentsRepository {
  Future<DocumentModel> uploadDocument({
    required String userId,
    required String documentType,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  });

  Stream<List<DocumentModel>> watchUserDocuments(String userId);

  Future<String> getViewUrl(String storagePath);

  Future<void> deleteDocument({
    required String documentId,
    required String storagePath,
  });
}

