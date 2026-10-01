import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Thin wrapper around the Gemini SDK. Kept generic (text-in, JSON-out)
/// so RecommendationService owns the actual prompt logic and this class
/// stays reusable for anything else in the app that needs an AI call.
class GeminiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  GenerativeModel? _model;

  GeminiService() {
    _initModel();
  }

  void _initModel() {
    final key = _apiKey.trim();
    if (key.isNotEmpty && !key.contains('YOUR_GEMINI_API_KEY')) {
      try {
        _model = GenerativeModel(
          // 'gemini-1.5-flash' was shut down by Google on 29 Sept 2025 —
          // every request to it now fails with a 404, which is why the
          // Skill Gap Analysis / Career Recommendations screens were
          // returning nothing. 'gemini-3.5-flash-lite' is Google's
          // current GA model, no billing required, and is what Google
          // explicitly recommends for new projects as of Sept 2026.
          model: 'gemini-3.5-flash-lite',
          apiKey: key,
        );
      } catch (e) {
        debugPrint('Gemini Model Initialization Error: $e');
      }
    }
  }

  bool get isKeyConfigured {
    final key = _apiKey.trim();
    return key.isNotEmpty && !key.contains('YOUR_GEMINI_API_KEY');
  }

  Future<String> analyzeSkillGap({
    required String currentSkills,
    required String targetRole,
  }) async {
    if (!isKeyConfigured || _model == null) {
      return '''
⚠️ **Gemini API Key Required**

To receive live AI-generated skill gap analysis:
1. Open your `.env` file in the project root.
2. Set `GEMINI_API_KEY=your_actual_api_key_from_google_ai_studio`.
3. Restart the application.

---
**Sample Skill Gap Analysis for $targetRole:**
• **Target Role**: $targetRole
• **Your Skills**: $currentSkills
• **Recommended Skills**: Problem Solving, System Architecture, Version Control, Microservices.
• **Action Step**: Complete foundational certification & build 2 hands-on portfolio projects.
''';
    }

    try {
      final prompt = '''
You are an expert career counselor and skill evaluator.
User Current Skills: $currentSkills
Target Job Role: $targetRole

Please provide a structured analysis including:
1. **Skill Gap Analysis**: What key skills are missing for this role?
2. **Learning Roadmap**: Step-by-step recommendations on what to learn next.
3. **Actionable Advice**: Short tips to improve their portfolio or profile.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? 'Response generation failed. Please try again.';
    } catch (e) {
      return 'AI Assessment Error: $e. Please verify your GEMINI_API_KEY in .env.';
    }
  }

  Future<String> generateText(String prompt) async {
    if (!isKeyConfigured || _model == null) return '';
    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      debugPrint('Gemini generateText error: $e');
      return '';
    }
  }

  /// Starts a multi-turn chat session for the in-app AI advisor.
  /// [contextPrompt] (who the student is + the app's live careers /
  /// scholarships / jobs / courses) is seeded as the first exchange, so it
  /// works on every version of the google_generative_ai package (no
  /// systemInstruction needed).
  ChatSession startChat({required String contextPrompt}) {
    if (!isKeyConfigured || _model == null) {
      throw Exception('Gemini API key is not configured. Set GEMINI_API_KEY in .env.');
    }
    return _model!.startChat(history: [
      Content.text(contextPrompt),
      Content.model([TextPart('Understood. I am ready to advise this student.')]),
    ]);
  }

  /// Sends [prompt] to Gemini and parses the response as JSON. Strips
  /// ```json ... ``` markdown fences if Gemini wraps its answer in one
  /// (it frequently does even when told not to).
  ///
  /// IMPORTANT: this now throws on failure instead of silently returning
  /// `{}`. RecommendationService's three methods (getPersonalizedRecommendations,
  /// analyzeSkillGap, checkScholarshipEligibility) all call this directly with
  /// no try/catch of their own, and the repositories one layer up
  /// (CareerRecommendationsRepositoryImpl, SkillGapRepositoryImpl) already wrap
  /// their calls in try/catch and turn failures into a ServerException that the
  /// Providers already display as a red error message on screen. Swallowing the
  /// error here to `{}` was bypassing all of that — the screens looked like they
  /// were doing nothing instead of showing what actually went wrong.
  Future<Map<String, dynamic>> generateJson(String prompt) async {
    if (!isKeyConfigured || _model == null) {
      throw Exception('Gemini API key is not configured. Set GEMINI_API_KEY in .env.');
    }
    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final raw = response.text ?? '{}';
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'result': decoded};
    } catch (e) {
      debugPrint('Gemini generateJson error: $e');
      rethrow;
    }
  }
}
