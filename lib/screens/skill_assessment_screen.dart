import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class SkillAssessmentScreen extends StatefulWidget {
  const SkillAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<SkillAssessmentScreen> createState() => _SkillAssessmentScreenState();
}

class _SkillAssessmentScreenState extends State<SkillAssessmentScreen> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = false;
  String _analysisResult = '';

  Future<void> _performAssessment() async {
    if (_skillsController.text.trim().isEmpty || _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tamam fields ko fill karein')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = '';
    });

    final result = await _geminiService.analyzeSkillGap(
      currentSkills: _skillsController.text.trim(),
      targetRole: _roleController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _analysisResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Skill Assessment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _skillsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Apni Current Skills Likhein',
                hintText: 'e.g. HTML, CSS, Basics of JavaScript, Flutter UI',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Target Job Role',
                hintText: 'e.g. Flutter Developer, Full Stack Developer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _performAssessment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze Skill Gap', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            if (_analysisResult.isNotEmpty) ...[
              const Text(
                'AI Recommendation Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _analysisResult,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}