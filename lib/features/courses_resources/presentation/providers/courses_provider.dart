import 'package:flutter/material.dart';

import '../../../skills/data/repositories/skills_repository_impl.dart';
import '../../../skills/domain/repositories/skills_repository.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/courses_repository_impl.dart';
import '../../domain/repositories/courses_repository.dart';

class CoursesProvider with ChangeNotifier {
  final CoursesRepository _repository;
  final SkillsRepository _skillsRepository;

  CoursesProvider({CoursesRepository? repository, SkillsRepository? skillsRepository})
      : _repository = repository ?? CoursesRepositoryImpl(),
        _skillsRepository = skillsRepository ?? SkillsRepositoryImpl();

  List<CourseModel> _all = [];
  List<CourseModel> _filtered = [];
  bool _isLoading = false;
  bool _recommendedOnly = false;
  String? _errorMessage;

  List<CourseModel> get courses => _filtered;
  bool get isLoading => _isLoading;
  bool get recommendedOnly => _recommendedOnly;
  String? get errorMessage => _errorMessage;

  Future<void> load(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _all = await _repository.getAllCourses();
      _filtered = _all;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleRecommendedOnly(String userId) async {
    _recommendedOnly = !_recommendedOnly;
    if (!_recommendedOnly) {
      _filtered = _all;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final userSkills = await _skillsRepository.getUserSkillsOnce(userId);
      final gapSkillNames = userSkills.map((s) => s.skillName).toList();
      _filtered = await _repository.getCoursesForSkills(gapSkillNames);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      _filtered = _recommendedOnly ? _filtered : _all;
      notifyListeners();
      return;
    }
    final source = _recommendedOnly ? _filtered : _all;
    _filtered = source.where((c) => c.title.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
  }
}
