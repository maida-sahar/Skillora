import 'dart:io';
import 'dart:typed_data';

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
        withData: true,
      );
      if (result == null || result.files.isEmpty) return false;

      final platformFile = result.files.single;
      Uint8List? bytes = platformFile.bytes;

      if (bytes == null && platformFile.path != null) {
        bytes = await File(platformFile.path!).readAsBytes();
      }

      if (bytes == null) {
        _errorMessage = 'Could not read selected document bytes.';
        notifyListeners();
        return false;
      }

      final fileName = platformFile.name;
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

      const allowedExts = {'png', 'jpg', 'jpeg', 'pdf'};
      if (!allowedExts.contains(ext)) {
        _errorMessage = 'Invalid document type (.$ext). Only PNG, JPG, JPEG, and PDF documents are allowed.';
        notifyListeners();
        return false;
      }

      if (bytes.length > 10 * 1024 * 1024) {
        _errorMessage = 'File size exceeds maximum allowed 10 MB for user documents.';
        notifyListeners();
        return false;
      }

      _isUploading = true;
      notifyListeners();

      File? localFile;
      if (platformFile.path != null) {
        try {
          localFile = File(platformFile.path!);
        } catch (_) {}
      }

      await _repository.uploadDocument(
        userId: userId,
        documentType: documentType,
        file: localFile,
        fileBytes: bytes,
        fileName: fileName,
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

