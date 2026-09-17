import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({super.key});

  @override
  State<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showJobDialog({String? docId, Map<String, dynamic>? initialData}) {
    final titleController = TextEditingController(text: initialData?['title'] ?? '');
    final companyController = TextEditingController(text: initialData?['company'] ?? '');
    final locationController = TextEditingController(text: initialData?['location'] ?? 'Remote');
    final descController = TextEditingController(text: initialData?['description'] ?? '');
    final validTypes = ['Full-time', 'Part-time', 'Internship', 'Remote'];
    String rawType = (initialData?['type'] ?? 'Full-time').toString();
    String type = validTypes.firstWhere(
      (t) => t.toLowerCase() == rawType.toLowerCase(),
      orElse: () => 'Full-time',
    );

    final validStatuses = ['Open', 'Closed'];
    String rawStatus = (initialData?['status'] ?? 'Open').toString();
    String status = validStatuses.firstWhere(
      (s) => s.toLowerCase() == rawStatus.toLowerCase(),
      orElse: () => 'Open',
    );
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(docId == null
              ? 'Add Job / Internship'
              : (type == 'Internship' ? 'Edit Internship' : 'Edit Job')),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Job / Internship Title *',
                      hintText: 'e.g. Flutter Developer or UI/UX Intern',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: companyController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Company *',
                      hintText: 'e.g. TechCorp Inc.',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Company is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: locationController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      hintText: 'e.g. Remote, San Francisco, CA',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Job duties, requirements, and benefits...',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: validTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (val) {
                            if (val != null) setDialogState(() => type = val);
                          },
                    decoration: const InputDecoration(labelText: 'Job Type'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: validStatuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final messenger = ScaffoldMessenger.of(context);
                      setDialogState(() => isSaving = true);

                      try {
                        final isInternship = type == 'Internship';
                        final data = {
                          'title': titleController.text.trim(),
                          'company': companyController.text.trim(),
                          'location': locationController.text.trim(),
                          'type': type,
                          'description': descController.text.trim(),
                          'status': status,
                          'deadline': initialData?['deadline'] ??
                              Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
                          'updatedAt': Timestamp.now(),
                        };

                        if (docId == null) {
                          data['createdAt'] = Timestamp.now();
                          await FirebaseFirestore.instance.collection('jobs').add(data);
                        } else {
                          await FirebaseFirestore.instance.collection('jobs').doc(docId).update(data);
                        }

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(docId == null
                                ? (isInternship
                                    ? 'Internship posted successfully!'
                                    : 'Job posted successfully!')
                                : (isInternship
                                    ? 'Internship updated successfully!'
                                    : 'Job updated successfully!')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                        }
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to save: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJob(String docId, String title) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job / Internship'),
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
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(docId).delete();
        messenger.showSnackBar(
          const SnackBar(content: Text('Item deleted successfully.')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job/Internship Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Job / Internship'),
        onPressed: () => _showJobDialog(),
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
                  hintText: 'Search jobs & internships...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final title = (doc.data()['title'] ?? '').toString().toLowerCase();
                    final company = (doc.data()['company'] ?? '').toString().toLowerCase();
                    final type = (doc.data()['type'] ?? '').toString().toLowerCase();
                    return query.isEmpty || title.contains(query) || company.contains(query) || type.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: 'No Jobs or Internships Found',
                      message: 'No posted jobs or internships match your query.',
                      lottieAsset: 'assets/animations/empty_data.json',
                      fallbackIcon: Icons.business_center_outlined,
                      actionText: 'Add Job / Internship',
                      onActionPressed: () => _showJobDialog(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final title = data['title'] ?? 'Job';
                      final company = data['company'] ?? 'Company';
                      final type = data['type'] ?? 'Full-time';
                      final status = data['status'] ?? 'Open';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.business_center, color: Colors.white),
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$company • $type • Status: $status'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showJobDialog(docId: doc.id, initialData: data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteJob(doc.id, title),
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
