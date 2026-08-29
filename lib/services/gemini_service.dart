import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API Key missing in .env file');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> analyzeSkillGap({
    required String currentSkills,
    required String targetRole,
  }) async {
    try {
      final prompt = '''
You are an expert career counselor and skill evaluator.
User Current Skills: $currentSkills
Target Job Role: $targetRole

Please provide a structured analysis in Roman Urdu / English including:
1. **Skill Gap Analysis**: What key skills are missing for this role?
2. **Learning Roadmap**: Step-by-step recommendations on what to learn next.
3. **Actionable Advice**: Short tips to improve their portfolio or profile.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Response generation failed. Please try again.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}