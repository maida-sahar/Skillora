import 'dart:convert';

import '../../services/gemini_service.dart';
import 'interface/i_recommendation_engine.dart';

/// Turns raw Gemini text output into the structured Maps the app's
/// Career Recommendation Engine, Skill Gap Analysis and Scholarship
/// Eligibility screens expect.
class RecommendationService implements IRecommendationEngine {
  final GeminiService _gemini;

  RecommendationService({GeminiService? gemini}) : _gemini = gemini ?? GeminiService();

  @override
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
    required List<String> currentSkills,
    required List<String> interests,
    List<Map<String, dynamic>>? availableCareers,
  }) async {
    final careers = availableCareers ?? const [];
    if (careers.isEmpty) return [];

    final careersJson = jsonEncode(careers
        .map((c) => {
              'id': c['id'],
              'title': c['title'],
              'requiredSkills': c['requiredSkills'],
            })
        .toList());

    final prompt = '''
You are a career-matching engine for Pakistani students.
Current skills: ${currentSkills.isEmpty ? 'none listed' : currentSkills.join(', ')}
Interests: ${interests.isEmpty ? 'none listed' : interests.join(', ')}
Available careers (JSON): $careersJson

Rank the careers by fit for this student. Return ONLY valid JSON, no
markdown formatting, in this exact shape:
{"recommendations": [{"careerId": "...", "matchScore": 0, "reason": "one short sentence"}]}
matchScore is an integer 0-100. Return at most 5 careers, best match first.
''';

    final result = await _gemini.generateJson(prompt);
    final list = result['recommendations'];
    if (list is List) {
      return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> analyzeSkillGap({
    required List<String> currentSkills,
    required String targetCareerId,
    String? targetCareerTitle,
    List<String>? requiredSkills,
  }) async {
    final required = requiredSkills ?? const [];
    final prompt = '''
You are an expert career counselor for Pakistani students.
Student's current skills: ${currentSkills.isEmpty ? 'none listed' : currentSkills.join(', ')}
Target role: ${targetCareerTitle ?? targetCareerId}
Required skills for this role: ${required.isEmpty ? 'not specified' : required.join(', ')}

Return ONLY valid JSON, no markdown formatting, in this exact shape:
{
  "missingSkills": ["skill1", "skill2"],
  "roadmap": ["step 1", "step 2", "step 3"],
  "advice": "2-3 short actionable sentences"
}
''';
    return _gemini.generateJson(prompt);
  }

  @override
  Future<Map<String, dynamic>> checkScholarshipEligibility({
    required Map<String, dynamic> studentProfile,
    required String scholarshipTitle,
    required List<String> eligibilityCriteria,
  }) async {
    final profileJson = jsonEncode(studentProfile);
    final prompt = '''
You are a scholarship eligibility checker for Pakistani students.
Student profile (JSON): $profileJson
Scholarship: $scholarshipTitle
Eligibility criteria (as written by the scholarship provider):
${eligibilityCriteria.isEmpty ? '- not specified' : eligibilityCriteria.map((c) => '- $c').join('\n')}

Compare the student profile against each criterion. Return ONLY valid
JSON, no markdown formatting, in this exact shape:
{
  "eligible": true,
  "matchScore": 0,
  "metCriteria": ["criterion the student satisfies"],
  "unmetCriteria": ["criterion the student does not satisfy or can't be confirmed"],
  "advice": "1-2 short sentences on what to do next"
}
"eligible" is true only if there are no unmetCriteria that are hard
requirements. matchScore is an integer 0-100.
''';
    return _gemini.generateJson(prompt);
  }
}
