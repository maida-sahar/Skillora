import 'package:flutter/material.dart';

import '../../../scholarships/data/models/scholarship_model.dart';
import '../../data/repositories/eligibility_repository_impl.dart';
import '../../domain/repositories/eligibility_repository.dart';

/// Eligibility criteria in Firestore are free-text (e.g. "Must have a
/// GPA above 3.0", "Pakistani citizen only"), so they can't be verified
/// automatically. Instead the student self-declares which criteria they
/// meet via checkboxes, and the score combines that with the two
/// structured fields the app *can* check: field of study and country.
class EligibilityProvider with ChangeNotifier {
  final EligibilityRepository _repository;

  EligibilityProvider({EligibilityRepository? repository})
      : _repository = repository ?? EligibilityRepositoryImpl();

  List<ScholarshipModel> _scholarships = [];
  bool _isLoading = false;
  String? _errorMessage;

  String userField = '';
  String userCountry = '';

  // scholarshipId -> set of criteria indexes the student checked off
  final Map<String, Set<int>> _checkedCriteria = {};

  List<ScholarshipModel> get scholarships => _scholarships;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadScholarships() async {
    _isLoading = true;
    notifyListeners();
    try {
      _scholarships = await _repository.getOpenScholarships();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setProfile({String? field, String? country}) {
    if (field != null) userField = field;
    if (country != null) userCountry = country;
    notifyListeners();
  }

  bool isCriterionChecked(String scholarshipId, int index) {
    return _checkedCriteria[scholarshipId]?.contains(index) ?? false;
  }

  void toggleCriterion(String scholarshipId, int index) {
    final set = _checkedCriteria.putIfAbsent(scholarshipId, () => {});
    if (set.contains(index)) {
      set.remove(index);
    } else {
      set.add(index);
    }
    notifyListeners();
  }

  bool _fieldMatches(ScholarshipModel s) {
    if (userField.trim().isEmpty || s.field.trim().isEmpty) return false;
    return s.field.toLowerCase().contains(userField.trim().toLowerCase()) ||
        userField.trim().toLowerCase().contains(s.field.toLowerCase());
  }

  bool _countryMatches(ScholarshipModel s) {
    if (userCountry.trim().isEmpty) return false;
    final country = s.country.trim().toLowerCase();
    return country.isEmpty ||
        country == 'any' ||
        country == 'global' ||
        country == 'international' ||
        country == userCountry.trim().toLowerCase();
  }

  /// Returns (matchedCount, totalCriteria, fieldMatches, countryMatches, scorePercent)
  Map<String, dynamic> scoreFor(ScholarshipModel s) {
    final matched = _checkedCriteria[s.id]?.length ?? 0;
    final total = s.eligibilityCriteria.length;
    final fieldOk = _fieldMatches(s);
    final countryOk = _countryMatches(s);
    final totalWeight = total + 2;
    final matchedWeight = matched + (fieldOk ? 1 : 0) + (countryOk ? 1 : 0);
    final score = totalWeight == 0 ? 0 : ((matchedWeight / totalWeight) * 100).round();
    return {
      'matched': matched,
      'total': total,
      'fieldMatches': fieldOk,
      'countryMatches': countryOk,
      'score': score,
    };
  }
}
