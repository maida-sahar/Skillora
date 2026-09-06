import 'package:flutter/material.dart';

import '../../data/repositories/career_recommendations_repository_impl.dart';
import '../../domain/repositories/career_recommendations_repository.dart';

class CareerRecommendationsProvider with ChangeNotifier {
  final CareerRecommendationsRepository _repository;

  CareerRecommendationsProvider({CareerRecommendationsRepository? repository})
      : _repository = repository ?? CareerRecommendationsRepositoryImpl();

  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecommendations(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _recommendations = await _repository.getRecommendations(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
