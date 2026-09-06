import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/skills/data/models/skill_model.dart';
import '../../../../features/skills/presentation/providers/skills_provider.dart';

class SkillManagementScreen extends StatefulWidget {
  const SkillManagementScreen({super.key});

  @override
  State<SkillManagementScreen> createState() => _SkillManagementScreenState();
}

class _SkillManagementScreenState extends State<SkillManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSkillDialog({SkillModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController = TextEditingController(text: existing?.category ?? 'General');
    final descController = TextEditingController(text: existing?.description ?? '');
    String level = existing?.level ?? 'Intermediate';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Skill' : 'Edit Skill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Skill Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: level,
                  items: ['Beginner', 'Intermediate', 'Advanced']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => level = val);
                  },
                  decoration: const InputDecoration(labelText: 'Skill Level'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final category = categoryController.text.trim().isEmpty
                    ? 'General'
                    : categoryController.text.trim();
                if (name.isEmpty) return;

                final provider = context.read<SkillsProvider>();
                final skill = SkillModel(
                  id: existing?.id ?? '',
                  name: name,
                  category: category,
                  description: descController.text.trim(),
                  level: level,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                );

                if (existing == null) {
                  await provider.addSkill(skill);
                } else {
                  await provider.updateSkill(skill);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkillsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Skill'),
        onPressed: () => _showSkillDialog(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search skills...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<SkillModel>>(
                stream: provider.watchCatalog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final skills = snapshot.data ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = skills.where((s) {
                    final name = s.name.toLowerCase();
                    final cat = s.category.toLowerCase();
                    return query.isEmpty || name.contains(query) || cat.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No skills match your search query.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final skill = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.star, color: Colors.white),
                          ),
                          title: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${skill.category} • Level: ${skill.level}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showSkillDialog(existing: skill),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
            ),
          ],
        ),
      ),
    );
  }
}
