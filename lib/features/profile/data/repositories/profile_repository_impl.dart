import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../firebase/firestore_service.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseStorageService _supabaseStorageService;
  final FirestoreService _firestoreService;

  static const _bucket = 'avatars';
  static const _maxBytes = 2 * 1024 * 1024; // 2 MB
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  ProfileRepositoryImpl({
    SupabaseStorageService? supabaseStorageService,
    FirestoreService? firestoreService,
  })  : _supabaseStorageService = supabaseStorageService ?? SupabaseStorageServiceImpl(),
        _firestoreService = firestoreService ?? FirestoreServiceImpl();

  @override
  Future<String> uploadProfilePicture({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String? oldImageUrl,
  }) async {
    if (userId.trim().isEmpty) {
      throw const ServerException('User authentication is required to upload an avatar.');
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
      throw const ServerException('Avatar image size exceeds the 2 MB limit.');
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

    final String path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // 1. Upload file to Supabase Storage 'avatars' bucket
    final String publicUrl = await _supabaseStorageService.uploadImageBytes(
      _bucket,
      path,
      bytes,
      contentType: 'image/$ext',
    );

    // 2. Update Firestore users collection document with the URL string only
    await _firestoreService.updateDocument('users', userId, {
      'profileImage': publicUrl,
      'updatedAt': Timestamp.now(),
    });

    // 3. Delete old avatar if present and different
    if (oldImageUrl != null && oldImageUrl.isNotEmpty && oldImageUrl != publicUrl) {
      try {
        final oldPath = _supabaseStorageService.extractPathFromUrl(_bucket, oldImageUrl);
        if (oldPath != null) {
          await _supabaseStorageService.deleteImage(_bucket, oldPath);
        }
      } catch (e) {
        // Log cleanup error without throwing as the primary upload/save succeeded
      }
    }

    return publicUrl;
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required UserModel updatedUser,
  }) async {
    await _firestoreService.setDocument(
      'users',
      userId,
      updatedUser.toFirestore(),
      merge: true,
    );
  }
}

