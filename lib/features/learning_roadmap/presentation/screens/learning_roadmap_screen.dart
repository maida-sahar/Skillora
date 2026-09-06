import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/roadmap_model.dart';
import '../providers/roadmap_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class LearningRoadmapScreen extends StatelessWidget {
  const LearningRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Learning Roadmap')),
      body: userId == null
          ? const Center(child: Text('Please sign in.', style: TextStyle(color: Colors.white70)))
          : StreamBuilder<List<RoadmapModel>>(
              stream: context.read<RoadmapProvider>().watchRoadmaps(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final roadmaps = snapshot.data ?? [];
                if (roadmaps.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No roadmaps yet. Run a Skill Gap Analysis and tap "Save as Roadmap" to track your progress here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: roadmaps.length,
                  itemBuilder: (context, index) => _RoadmapCard(roadmap: roadmaps[index]),
                );
              },
            ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  final RoadmapModel roadmap;
  const _RoadmapCard({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RoadmapProvider>();

    return Card(
      color: _kSurface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(roadmap.careerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: LinearProgressIndicator(
            value: roadmap.progress,
            backgroundColor: Colors.white12,
            color: _kAccent,
          ),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: [
          ...roadmap.steps.asMap().entries.map((e) {
            return CheckboxListTile(
              value: e.value.completed,
              activeColor: _kAccent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                e.value.text,
                style: TextStyle(
                  color: e.value.completed ? Colors.white38 : Colors.white70,
                  decoration: e.value.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              onChanged: (checked) => provider.toggleStep(roadmap.id, e.key, checked ?? false),
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => provider.deleteRoadmap(roadmap.id),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }
}
