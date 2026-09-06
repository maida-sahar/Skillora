import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../learning_roadmap/presentation/providers/roadmap_provider.dart';
import '../providers/skill_gap_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class SkillGapAnalysisScreen extends StatefulWidget {
  const SkillGapAnalysisScreen({super.key});

  @override
  State<SkillGapAnalysisScreen> createState() => _SkillGapAnalysisScreenState();
}

class _SkillGapAnalysisScreenState extends State<SkillGapAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillGapProvider>().loadCareers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<SkillGapProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Skill Gap Analysis')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField(
                    dropdownColor: _kSurface,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Target Career',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    initialValue: provider.selectedCareer,
                    items: provider.careers
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.title)))
                        .toList(),
                    onChanged: provider.selectCareer,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: (provider.selectedCareer == null || provider.isAnalyzing || userId == null)
                        ? null
                        : () => provider.analyze(userId),
                    child: provider.isAnalyzing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Analyze Gap'),
                  ),
                  const SizedBox(height: 16),
                  if (provider.errorMessage != null)
                    Text(provider.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                  if (provider.result != null)
                    Expanded(
                      child: _ResultView(
                        result: provider.result!,
                        userId: userId,
                        careerId: provider.selectedCareer?.id ?? '',
                        careerTitle: provider.selectedCareer?.title ?? '',
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final String? userId;
  final String careerId;
  final String careerTitle;

  const _ResultView({
    required this.result,
    required this.userId,
    required this.careerId,
    required this.careerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final missing = (result['missingSkills'] as List?)?.cast<String>() ?? [];
    final roadmap = (result['roadmap'] as List?)?.cast<String>() ?? [];
    final advice = result['advice'] as String? ?? (result['raw'] as String? ?? '');

    return ListView(
      children: [
        if (missing.isNotEmpty) ...[
          const Text('Missing Skills', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missing.map((s) => Chip(label: Text(s), backgroundColor: _kSurface)).toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (roadmap.isNotEmpty) ...[
          const Text('Learning Roadmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...roadmap.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(color: Colors.white70)),
                ),
              ),
          const SizedBox(height: 12),
          if (userId != null && careerId.isNotEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined, color: _kAccent),
              label: const Text('Save as Roadmap', style: TextStyle(color: _kAccent)),
              onPressed: () async {
                final ok = await context.read<RoadmapProvider>().saveFromGapAnalysis(
                      userId: userId!,
                      careerId: careerId,
                      careerTitle: careerTitle,
                      missingSkills: missing,
                      roadmapSteps: roadmap,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Saved to Learning Roadmap!' : 'Failed to save.')),
                  );
                }
              },
            ),
          const SizedBox(height: 20),
        ],
        if (advice.isNotEmpty) ...[
          const Text('Advice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(advice, style: const TextStyle(color: Colors.white70)),
        ],
      ],
    );
  }
}
