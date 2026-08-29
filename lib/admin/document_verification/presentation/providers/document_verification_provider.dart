import 'package:flutter/material.dart';

import '../../../../features/documents/data/models/document_model.dart';
import '../../data/repositories/document_verification_repository_impl.dart';
import '../../domain/repositories/document_verification_repository.dart';

class DocumentVerificationProvider with ChangeNotifier {
  final DocumentVerificationRepository _repository;

  DocumentVerificationProvider({DocumentVerificationRepository? repository})
      : _repository = repository ?? DocumentVerificationRepositoryImpl();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Stream<List<DocumentModel>> watchDocuments({String? statusFilter}) {
    return _repository.watchAllDocuments(statusFilter: statusFilter);
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

  Future<bool> approve(DocumentModel doc, String adminId) async {
    try {
      await _repository.updateStatus(
        documentId: doc.id,
        status: DocumentStatus.verified,
        verifiedBy: adminId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(DocumentModel doc, String adminId, String reason) async {
    try {
      await _repository.updateStatus(
        documentId: doc.id,
        status: DocumentStatus.rejected,
        verifiedBy: adminId,
        rejectionReason: reason,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
