import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../firebase/firestore_service.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseStorageService _supabaseStorageService;
  final FirestoreService _firestoreService;

  ProfileRepositoryImpl({
    SupabaseStorageService? supabaseStorageService,
    FirestoreService? firestoreService,
  })  : _supabaseStorageService = supabaseStorageService ?? SupabaseStorageServiceImpl(),
        _firestoreService = firestoreService ?? FirestoreServiceImpl();

  @override
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    final String path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // 1. Upload file to Supabase Storage 'avatars' bucket
    final String publicUrl = await _supabaseStorageService.uploadImage(
      'avatars',
      path,
      imageFile,
    );

    // 2. Update Firestore users collection document with the URL string only
    await _firestoreService.updateDocument('users', userId, {
      'profileImage': publicUrl,
      'updatedAt': Timestamp.now(),
    });

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
