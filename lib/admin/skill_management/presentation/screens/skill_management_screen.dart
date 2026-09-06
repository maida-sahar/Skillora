import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/skills/data/models/skill_model.dart';
import '../../../../features/skills/presentation/providers/skills_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

/// Admin CRUD over the shared skill catalog. Uses the same SkillsProvider
/// as Skill Assessment / Skill Gap Analysis / Career Recommendations —
/// they all read from this one catalog.
class SkillManagementScreen extends StatelessWidget {
  const SkillManagementScreen({super.key});

  void _showEditor(BuildContext context, {SkillModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController = TextEditingController(text: existing?.category ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _kSurface,
        title: Text(existing == null ? 'Add Skill' : 'Edit Skill', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Skill name'),
            ),
            TextField(
              controller: categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent, foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameController.text.trim();
              final category = categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim();
              if (name.isEmpty) return;
              final provider = dialogContext.read<SkillsProvider>();
              final skill = SkillModel(
                id: existing?.id ?? '',
                name: name,
                category: category,
                description: descController.text.trim(),
                createdAt: existing?.createdAt ?? DateTime.now(),
              );
              if (existing == null) {
                await provider.addSkill(skill);
              } else {
                await provider.updateSkill(skill);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkillsProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Admin: Skill Management')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kAccent,
        onPressed: () => _showEditor(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<SkillModel>>(
        stream: provider.watchCatalog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final skills = snapshot.data ?? [];
          if (skills.isEmpty) {
            return const Center(child: Text('No skills yet. Tap + to add one.', style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              return Card(
                color: _kSurface,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(skill.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(skill.category, style: const TextStyle(color: Colors.white54)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                        onPressed: () => _showEditor(context, existing: skill),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                        onPressed: () => provider.deleteSkill(skill.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
