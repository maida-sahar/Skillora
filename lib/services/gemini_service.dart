import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Thin wrapper around the Gemini SDK. Kept generic (text-in, JSON-out)
/// so RecommendationService owns the actual prompt logic and this class
/// stays reusable for anything else in the app that needs an AI call.
class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API Key missing in .env file');
    }
    _model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: _apiKey);
  }

  Future<String> generateText(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Sends [prompt] to Gemini and parses the response as JSON. Strips
  /// ```json ... ``` markdown fences if Gemini wraps its answer in one
  /// (it frequently does even when told not to).
  Future<Map<String, dynamic>> generateJson(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '{}';
    final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'result': decoded};
    } catch (_) {
      // Gemini didn't return valid JSON this time — surface the raw
      // text instead of throwing, so the UI can still show *something*.
      return {'raw': raw};
    }
  }
}
