import 'package:flutter/material.dart';

import '../../../careers/data/models/career_model.dart';
import '../../data/repositories/skill_gap_repository_impl.dart';
import '../../domain/repositories/skill_gap_repository.dart';

class SkillGapProvider with ChangeNotifier {
  final SkillGapRepository _repository;

  SkillGapProvider({SkillGapRepository? repository})
      : _repository = repository ?? SkillGapRepositoryImpl();

  List<CareerModel> _careers = [];
  CareerModel? _selectedCareer;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  List<CareerModel> get careers => _careers;
  CareerModel? get selectedCareer => _selectedCareer;
  Map<String, dynamic>? get result => _result;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;

  Future<void> loadCareers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _careers = await _repository.getCareers();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectCareer(CareerModel? career) {
    _selectedCareer = career;
    _result = null;
    notifyListeners();
  }

  Future<void> analyze(String userId) async {
    if (_selectedCareer == null) return;
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _result = await _repository.analyzeGap(userId: userId, targetCareer: _selectedCareer!);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isAnalyzing = false;
    notifyListeners();
  }
}
