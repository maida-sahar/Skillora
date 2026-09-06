import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
          model: 'gemini-1.5-flash',
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
}