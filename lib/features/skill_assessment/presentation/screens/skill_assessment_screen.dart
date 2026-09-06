import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../skills/data/models/user_skill_model.dart';
import '../providers/skill_assessment_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class SkillAssessmentScreen extends StatefulWidget {
  const SkillAssessmentScreen({super.key});

  @override
  State<SkillAssessmentScreen> createState() => _SkillAssessmentScreenState();
}

class _SkillAssessmentScreenState extends State<SkillAssessmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillAssessmentProvider>().loadCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<SkillAssessmentProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text('Skill Assessment'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.catalog.isEmpty
              ? const Center(
                  child: Text(
                    'No skills in catalog yet.\nAdmin needs to add skills first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.catalog.length,
                  itemBuilder: (context, index) {
                    final skill = provider.catalog[index];
                    final selected = provider.ratings[skill.id];
                    return Card(
                      color: _kSurface,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            Text(skill.category, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: SkillLevel.values.map((level) {
                                return ChoiceChip(
                                  label: Text(level.name),
                                  selected: selected == level,
                                  selectedColor: _kAccent,
                                  onSelected: (_) => provider.rate(skill.id, level),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: (userId == null || provider.isSaving)
                ? null
                : () async {
                    final ok = await provider.submit(userId);
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Assessment saved!')));
                      Navigator.pop(context);
                    } else if (provider.errorMessage != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
                    }
                  },
            child: provider.isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Assessment'),
          ),
        ),
      ),
    );
  }
}
