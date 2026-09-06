import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker;

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  File? _selectedImageFile;
  bool _isUploading = false;
  String? _errorMessage;

  ProfileProvider({
    ProfileRepository? profileRepository,
    ImagePicker? imagePicker,
  })  : _profileRepository = profileRepository ?? ProfileRepositoryImpl(),
        _imagePicker = imagePicker ?? ImagePicker();

  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedFileName => _selectedFileName;
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

      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';

      const allowedExts = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
      if (!allowedExts.contains(ext)) {
        _errorMessage = 'Invalid file type (.$ext). Only images (JPG, PNG, WEBP, GIF) are allowed.';
        notifyListeners();
        return false;
      }

      if (bytes.length > 2 * 1024 * 1024) {
        _errorMessage = 'File size exceeds maximum allowed 2 MB for profile avatar.';
        notifyListeners();
        return false;
      }

      _selectedImageBytes = bytes;
      _selectedFileName = fileName;

      try {
        _selectedImageFile = File(pickedFile.path);
      } catch (_) {
        _selectedImageFile = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearSelectedImage() {
    _selectedImageBytes = null;
    _selectedFileName = null;
    _selectedImageFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> uploadProfilePicture(String userId, {String? oldImageUrl}) async {
    if (_selectedImageBytes == null) {
      _errorMessage = 'Please select a profile image first.';
      notifyListeners();
      return null;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String publicUrl = await _profileRepository.uploadProfilePicture(
        userId: userId,
        imageBytes: _selectedImageBytes,
        fileName: _selectedFileName,
        oldImageUrl: oldImageUrl,
      );

      _selectedImageBytes = null;
      _selectedFileName = null;
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

