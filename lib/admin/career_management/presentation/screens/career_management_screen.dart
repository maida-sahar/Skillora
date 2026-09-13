import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class CareerManagementScreen extends StatefulWidget {
  const CareerManagementScreen({super.key});

  @override
  State<CareerManagementScreen> createState() => _CareerManagementScreenState();
}

class _CareerManagementScreenState extends State<CareerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCareerDialog({String? docId, Map<String, dynamic>? initialData}) {
    final titleController = TextEditingController(text: initialData?['title'] ?? '');
    final initialCategory = (initialData?['category'] ?? initialData?['field'] ?? '').toString();
    
    final standardCategories = ['STEM', 'Business', 'Design', 'Technology', 'Marketing', 'Arts', 'Healthcare', 'Finance'];
    bool isCustom = initialCategory.isNotEmpty && !standardCategories.contains(initialCategory);
    String selectedDropdownCategory = isCustom
        ? 'Custom'
        : (standardCategories.contains(initialCategory) ? initialCategory : 'STEM');
    
    final customCategoryController = TextEditingController(text: isCustom ? initialCategory : '');
    final descriptionController = TextEditingController(text: initialData?['description'] ?? '');
    final educationController = TextEditingController(text: initialData?['education'] ?? '');
    final skillsController = TextEditingController(
      text: initialData?['requiredSkills'] != null
          ? (initialData!['requiredSkills'] as List).join(', ')
          : '',
    );
    String careerLevel = initialData?['careerLevel'] ?? 'Entry Level';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(docId == null ? 'Add New Career' : 'Edit Career'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Career Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDropdownCategory,
                  items: [...standardCategories, 'Custom']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedDropdownCategory = val);
                  },
                  decoration: const InputDecoration(labelText: 'Field / Category'),
                ),
                if (selectedDropdownCategory == 'Custom') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customCategoryController,
                    decoration: const InputDecoration(labelText: 'Specify Custom Field / Category'),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: educationController,
                  decoration: const InputDecoration(labelText: 'Required Education'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Required Skills (comma separated)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: careerLevel,
                  items: ['Entry Level', 'Mid Level', 'Senior Level', 'Executive']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => careerLevel = val);
                  },
                  decoration: const InputDecoration(labelText: 'Career Level'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final finalCategory = (selectedDropdownCategory == 'Custom'
                        ? customCategoryController.text.trim()
                        : selectedDropdownCategory)
                    .trim();

                final skills = skillsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final data = {
                  'title': titleController.text.trim(),
                  'category': finalCategory,
                  'field': finalCategory,
                  'description': descriptionController.text.trim(),
                  'education': educationController.text.trim(),
                  'requiredSkills': skills,
                  'careerLevel': careerLevel,
                  'updatedAt': Timestamp.now(),
                };

                if (docId == null) {
                  data['createdAt'] = Timestamp.now();
                  await FirebaseFirestore.instance.collection('careers').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('careers').doc(docId).update(data);
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(docId == null ? 'Career created!' : 'Career updated!')),
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

  Future<void> _deleteCareer(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Career'),
        content: Text('Are you sure you want to delete "$title"?'),
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
      await FirebaseFirestore.instance.collection('careers').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Career deleted successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Career'),
        onPressed: () => _showCareerDialog(),
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
                  hintText: 'Search careers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('careers').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final title = (doc.data()['title'] ?? '').toString().toLowerCase();
                    final cat = (doc.data()['category'] ?? doc.data()['field'] ?? '').toString().toLowerCase();
                    return query.isEmpty || title.contains(query) || cat.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: 'No Careers Available',
                      message: 'No career paths match your query or have been added yet.',
                      fallbackIcon: Icons.work_outline,
                      actionText: 'Add Career',
                      onActionPressed: () => _showCareerDialog(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final title = data['title'] ?? 'Career';
                      final category = (data['category'] ?? data['field'] ?? '').toString().trim();
                      final level = data['careerLevel'] ?? 'Entry Level';
                      final hasNoCategory = category.isEmpty;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.work, color: Colors.white),
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${hasNoCategory ? 'Uncategorized' : category} • $level'),
                              if (hasNoCategory) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '⚠️ No Field Assigned - Edit to assign',
                                    style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showCareerDialog(docId: doc.id, initialData: data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCareer(doc.id, title),
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
