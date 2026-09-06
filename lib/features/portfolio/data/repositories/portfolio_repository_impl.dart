import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../firebase/firestore_service.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../models/portfolio_item_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final SupabaseStorageService _supabaseStorageService;
  final FirestoreService _firestoreService;

  static const _bucket = 'portfolio-assets';
  static const _maxBytes = 5 * 1024 * 1024; // 5 MB
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  PortfolioRepositoryImpl({
    SupabaseStorageService? supabaseStorageService,
    FirestoreService? firestoreService,
  })  : _supabaseStorageService = supabaseStorageService ?? SupabaseStorageServiceImpl(),
        _firestoreService = firestoreService ?? FirestoreServiceImpl();

  @override
  Future<String> uploadPortfolioImage({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String? projectId,
  }) async {
    if (userId.trim().isEmpty) {
      throw const ServerException('User authentication is required to upload portfolio assets.');
    }

    Uint8List bytes;
    if (imageBytes != null) {
      bytes = imageBytes;
    } else if (imageFile != null) {
      bytes = await imageFile.readAsBytes();
    } else {
      throw const ServerException('No image file or bytes provided for upload.');
    }

    if (bytes.length > _maxBytes) {
      throw const ServerException('Portfolio image size exceeds the 5 MB limit.');
    }

    String ext = 'jpg';
    if (fileName != null && fileName.contains('.')) {
      ext = fileName.split('.').last.toLowerCase();
    } else if (imageFile != null) {
      ext = imageFile.path.split('.').last.toLowerCase();
    }

    if (!_allowedExtensions.contains(ext)) {
      throw ServerException('Invalid file type (.$ext). Only image files (JPG, PNG, WEBP, GIF) are allowed.');
    }

    final String folder = projectId != null && projectId.isNotEmpty ? '$userId/$projectId' : userId;
    final String path = '$folder/portfolio_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // Upload to Supabase 'portfolio-assets' public bucket
    final String publicUrl = await _supabaseStorageService.uploadImageBytes(
      _bucket,
      path,
      bytes,
      contentType: 'image/$ext',
    );

    return publicUrl;
  }

  @override
  Future<void> addPortfolioItem(PortfolioItemModel item) async {
    await _firestoreService.setDocument(
      'portfolios',
      item.id,
      item.toFirestore(),
    );
  }

  @override
  Future<List<PortfolioItemModel>> getUserPortfolioItems(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('portfolios')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) => PortfolioItemModel.fromFirestore(doc)).toList();
  }
}

