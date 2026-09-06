import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../shared/widgets/cards/app_card.dart';
import '../shared/widgets/inputs/app_text_field.dart';
import '../shared/widgets/buttons/custom_button.dart';

class SkillAssessmentScreen extends StatefulWidget {
  const SkillAssessmentScreen({super.key});

  @override
  State<SkillAssessmentScreen> createState() => _SkillAssessmentScreenState();
}

class _SkillAssessmentScreenState extends State<SkillAssessmentScreen> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = false;
  String _analysisResult = '';

  @override
  void dispose() {
    _skillsController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _performAssessment() async {
    if (_skillsController.text.trim().isEmpty || _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both current skills and target role.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
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

    if (mounted) {
      setState(() {
        _isLoading = false;
        _analysisResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('AI Skill Assessment', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cyanSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cyan),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.cyan, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Competency Analysis',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Evaluate your skill gap against market requirements',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Input Card
            AppCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Current Skills & Competencies',
                    hint: 'e.g. Flutter UI, Dart, REST APIs, Git, Firebase',
                    controller: _skillsController,
                    maxLines: 3,
                    prefixIcon: Icons.stars_outlined,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Target Job Role',
                    hint: 'e.g. Senior Flutter Developer, AI Engineer',
                    controller: _roleController,
                    prefixIcon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Analyze Skill Gap',
                    isLoading: _isLoading,
                    icon: Icons.bolt,
                    onPressed: _performAssessment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Result Card
            if (_analysisResult.isNotEmpty) ...[
              Text(
                'AI Career Recommendation',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(22),
                child: SelectableText(
                  _analysisResult,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}