import 'dart:io';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  Future<void> updateUserProfile({
    required String userId,
    required UserModel updatedUser,
  });
}
