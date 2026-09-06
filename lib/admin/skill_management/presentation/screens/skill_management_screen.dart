import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

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

  void _showSkillDialog({String? docId, Map<String, dynamic>? initialData}) {
    final nameController = TextEditingController(text: initialData?['name'] ?? '');
    final categoryController = TextEditingController(text: initialData?['category'] ?? 'General');
    final descController = TextEditingController(text: initialData?['description'] ?? '');
    String level = initialData?['level'] ?? 'Intermediate';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: Text(docId == null ? 'Add Skill' : 'Edit Skill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Skill Name')),
                const SizedBox(height: 10),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 10),
                TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: level,
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final data = {
                  'name': nameController.text.trim(),
                  'category': categoryController.text.trim(),
                  'description': descController.text.trim(),
                  'level': level,
                  'createdAt': Timestamp.now(),
                };

                if (docId == null) {
                  await FirebaseFirestore.instance.collection('skills').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('skills').doc(docId).update(data);
                }

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(docId == null ? 'Skill added!' : 'Skill updated!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSkill(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('skills').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('skills').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final name = (doc.data()['name'] ?? '').toString().toLowerCase();
                    final cat = (doc.data()['category'] ?? '').toString().toLowerCase();
                    return query.isEmpty || name.contains(query) || cat.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: 'No Skills Available',
                      message: 'No skills match your query or have been added yet.',
                      lottieAsset: 'assets/animations/empty_data.json',
                      fallbackIcon: Icons.star_border,
                      actionText: 'Add Skill',
                      onActionPressed: () => _showSkillDialog(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final name = data['name'] ?? 'Skill';
                      final category = data['category'] ?? 'General';
                      final level = data['level'] ?? 'Intermediate';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.star, color: Colors.white),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$category • Level: $level'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showSkillDialog(docId: doc.id, initialData: data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSkill(doc.id, name),
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
