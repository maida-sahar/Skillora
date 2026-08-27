import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../data/models/portfolio_item_model.dart';

class PortfolioProvider with ChangeNotifier {
  final PortfolioRepository _portfolioRepository;
  final ImagePicker _imagePicker;

  List<PortfolioItemModel> _items = [];
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _errorMessage;

  PortfolioProvider({
    PortfolioRepository? portfolioRepository,
    ImagePicker? imagePicker,
  })  : _portfolioRepository = portfolioRepository ?? PortfolioRepositoryImpl(),
        _imagePicker = imagePicker ?? ImagePicker();

  List<PortfolioItemModel> get items => _items;
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
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked == null) return false;

      _selectedImageFile = File(picked.path);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick portfolio image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearSelectedImage() {
    _selectedImageFile = null;
    notifyListeners();
  }

  Future<bool> createPortfolioItem({
    required String userId,
    required String title,
    required String description,
    String? projectUrl,
  }) async {
    if (_selectedImageFile == null) {
      _errorMessage = 'Please select a project screenshot or cover image.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload image to Supabase Storage 'portfolio-assets' bucket
      final String publicUrl = await _portfolioRepository.uploadPortfolioImage(
        userId: userId,
        imageFile: _selectedImageFile!,
      );

      // 2. Save metadata & public URL string into Firestore portfolios collection
      final now = DateTime.now();
      final item = PortfolioItemModel(
        id: 'portfolio_${now.millisecondsSinceEpoch}',
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
