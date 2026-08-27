import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker;

  File? _selectedImageFile;
  bool _isUploading = false;
  String? _errorMessage;

  ProfileProvider({
    ProfileRepository? profileRepository,
    ImagePicker? imagePicker,
  })  : _profileRepository = profileRepository ?? ProfileRepositoryImpl(),
        _imagePicker = imagePicker ?? ImagePicker();

  File? get selectedImageFile => _selectedImageFile;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<bool> pickImage(ImageSource source) async {
    _errorMessage = null;
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return false;

      _selectedImageFile = File(pickedFile.path);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearSelectedImage() {
    _selectedImageFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> uploadProfilePicture(String userId) async {
    if (_selectedImageFile == null) return null;

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String publicUrl = await _profileRepository.uploadProfilePicture(
        userId: userId,
        imageFile: _selectedImageFile!,
      );

      _selectedImageFile = null;
      _isUploading = false;
      notifyListeners();
      return publicUrl;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }
}
