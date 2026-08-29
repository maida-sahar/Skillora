import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/models/document_model.dart';
import '../../data/repositories/documents_repository_impl.dart';
import '../../domain/repositories/documents_repository.dart';

class DocumentsProvider with ChangeNotifier {
  final DocumentsRepository _repository;

  DocumentsProvider({DocumentsRepository? repository})
      : _repository = repository ?? DocumentsRepositoryImpl();

  bool _isUploading = false;
  String? _errorMessage;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Stream<List<DocumentModel>> watchUserDocuments(String userId) {
    return _repository.watchUserDocuments(userId);
  }

  Future<bool> pickAndUploadDocument({
    required String userId,
    required String documentType,
  }) async {
    _errorMessage = null;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );
      if (result == null || result.files.single.path == null) return false;

      _isUploading = true;
      notifyListeners();

      final file = File(result.files.single.path!);
      await _repository.uploadDocument(
        userId: userId,
        documentType: documentType,
        file: file,
      );

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> getViewUrl(String storagePath) async {
    try {
      return await _repository.getViewUrl(storagePath);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteDocument(DocumentModel doc) async {
    try {
      await _repository.deleteDocument(
        documentId: doc.id,
        storagePath: doc.storagePath,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
