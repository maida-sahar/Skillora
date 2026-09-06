import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ScholarshipManagementScreen extends StatefulWidget {
  const ScholarshipManagementScreen({super.key});

  @override
  State<ScholarshipManagementScreen> createState() => _ScholarshipManagementScreenState();
}

class _ScholarshipManagementScreenState extends State<ScholarshipManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showScholarshipDialog({String? docId, Map<String, dynamic>? initialData}) {
    final titleController = TextEditingController(text: initialData?['title'] ?? '');
    final orgController = TextEditingController(text: initialData?['organization'] ?? '');
    final fieldController = TextEditingController(text: initialData?['field'] ?? '');
    final amountController = TextEditingController(text: initialData?['amount']?.toString() ?? '');
    final countryController = TextEditingController(text: initialData?['country'] ?? '');
    final descController = TextEditingController(text: initialData?['description'] ?? '');
    final urlController = TextEditingController(text: initialData?['applicationUrl'] ?? '');
    String status = initialData?['status'] ?? 'Open';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: Text(docId == null ? 'Add Scholarship' : 'Edit Scholarship'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: orgController, decoration: const InputDecoration(labelText: 'Organization')),
                const SizedBox(height: 10),
                TextField(controller: fieldController, decoration: const InputDecoration(labelText: 'Field of Study')),
                const SizedBox(height: 10),
                TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (\$)')),
                const SizedBox(height: 10),
                TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
                const SizedBox(height: 10),
                TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 10),
                TextField(controller: urlController, decoration: const InputDecoration(labelText: 'Application URL')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: ['Open', 'Closed', 'Upcoming']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => status = val);
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final data = {
                  'title': titleController.text.trim(),
                  'organization': orgController.text.trim(),
                  'field': fieldController.text.trim(),
                  'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
                  'country': countryController.text.trim(),
                  'description': descController.text.trim(),
                  'applicationUrl': urlController.text.trim(),
                  'status': status,
                  'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
                  'updatedAt': Timestamp.now(),
                };

                if (docId == null) {
                  data['createdAt'] = Timestamp.now();
                  await FirebaseFirestore.instance.collection('scholarships').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('scholarships').doc(docId).update(data);
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(docId == null ? 'Scholarship added!' : 'Scholarship updated!')),
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

  Future<void> _deleteScholarship(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Scholarship'),
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
      await FirebaseFirestore.instance.collection('scholarships').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scholarship deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Scholarship'),
        onPressed: () => _showScholarshipDialog(),
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
                  hintText: 'Search scholarships...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('scholarships').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final title = (doc.data()['title'] ?? '').toString().toLowerCase();
                    final field = (doc.data()['field'] ?? '').toString().toLowerCase();
                    return query.isEmpty || title.contains(query) || field.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: 'No Scholarships Found',
                      message: 'No active or posted scholarships match your search query.',
                      lottieAsset: 'assets/animations/empty_search.json',
                      fallbackIcon: Icons.school_outlined,
                      actionText: 'Add Scholarship',
                      onActionPressed: () => _showScholarshipDialog(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final title = data['title'] ?? 'Scholarship';
                      final org = data['organization'] ?? 'Organization';
                      final amount = data['amount'] ?? 0;
                      final status = data['status'] ?? 'Open';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.school, color: Colors.white),
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$org • \$$amount • Status: $status'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showScholarshipDialog(docId: doc.id, initialData: data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteScholarship(doc.id, title),
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
