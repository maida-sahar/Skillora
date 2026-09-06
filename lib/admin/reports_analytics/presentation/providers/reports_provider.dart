import 'package:flutter/material.dart';

import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsProvider with ChangeNotifier {
  final ReportsRepository _repository;

  ReportsProvider({ReportsRepository? repository})
      : _repository = repository ?? ReportsRepositoryImpl();

  Map<String, int> _counts = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, int> get counts => _counts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _counts = await _repository.getCounts();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
