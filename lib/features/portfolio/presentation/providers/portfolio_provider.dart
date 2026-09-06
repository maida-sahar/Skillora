import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../data/models/portfolio_item_model.dart';

class PortfolioProvider with ChangeNotifier {
  final PortfolioRepository _portfolioRepository;
  final ImagePicker _imagePicker;

  List<PortfolioItemModel> _items = [];
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _errorMessage;

  PortfolioProvider({
    PortfolioRepository? portfolioRepository,
    ImagePicker? imagePicker,
  })  : _portfolioRepository = portfolioRepository ?? PortfolioRepositoryImpl(),
        _imagePicker = imagePicker ?? ImagePicker();

  List<PortfolioItemModel> get items => _items;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedFileName => _selectedFileName;
  File? get selectedImageFile => _selectedImageFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserPortfolio(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _portfolioRepository.getUserPortfolioItems(userId);
    } catch (e) {
      _errorMessage = 'Failed to load portfolio items: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickImage(ImageSource source) async {
    _errorMessage = null;
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked == null) return false;

      final bytes = await picked.readAsBytes();
      final fileName = picked.name;
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';

      const allowedExts = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
      if (!allowedExts.contains(ext)) {
        _errorMessage = 'Invalid file type (.$ext). Only image files (JPG, PNG, WEBP, GIF) are allowed for portfolio assets.';
        notifyListeners();
        return false;
      }

      if (bytes.length > 5 * 1024 * 1024) {
        _errorMessage = 'File size exceeds maximum allowed 5 MB for portfolio assets.';
        notifyListeners();
        return false;
      }

      _selectedImageBytes = bytes;
      _selectedFileName = fileName;

      try {
        _selectedImageFile = File(picked.path);
      } catch (_) {
        _selectedImageFile = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick portfolio image: ${e.toString()}';
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

  Future<bool> createPortfolioItem({
    required String userId,
    required String title,
    required String description,
    String? projectUrl,
  }) async {
    if (_selectedImageBytes == null) {
      _errorMessage = 'Please select a project screenshot or cover image.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String itemId = 'portfolio_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Upload image to Supabase Storage 'portfolio-assets' bucket
      final String publicUrl = await _portfolioRepository.uploadPortfolioImage(
        userId: userId,
        imageBytes: _selectedImageBytes,
        fileName: _selectedFileName,
        projectId: itemId,
      );

      // 2. Save metadata & public URL string into Firestore portfolios collection
      final now = DateTime.now();
      final item = PortfolioItemModel(
        id: itemId,
        userId: userId,
        title: title,
        description: description,
        imageUrl: publicUrl,
        projectUrl: projectUrl,
        createdAt: now,
        updatedAt: now,
      );

      await _portfolioRepository.addPortfolioItem(item);

      _items.insert(0, item);
      _selectedImageBytes = null;
      _selectedFileName = null;
      _selectedImageFile = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
