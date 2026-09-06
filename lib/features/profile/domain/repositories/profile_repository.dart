import 'dart:io';
import 'dart:typed_data';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<String> uploadProfilePicture({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String? oldImageUrl,
  });

  Future<void> updateUserProfile({
    required String userId,
    required UserModel updatedUser,
  });
}

