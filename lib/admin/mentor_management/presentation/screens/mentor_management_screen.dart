import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

import '../../../../shared/widgets/app_mentor_avatar.dart';
import '../../../../shared/utils/app_image_helper.dart';

class MentorManagementScreen extends StatefulWidget {
  const MentorManagementScreen({super.key});

  @override
  State<MentorManagementScreen> createState() => _MentorManagementScreenState();
}

class _MentorManagementScreenState extends State<MentorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMentorDialog({String? docId, Map<String, dynamic>? initialData}) {
    debugPrint('3 - EDIT CALLBACK STARTED (docId: $docId)');
    try {
      final nameController = TextEditingController(text: initialData?['name']?.toString() ?? '');
      final bioController = TextEditingController(text: initialData?['bio']?.toString() ?? '');
      final expController = TextEditingController(text: initialData?['experience']?.toString() ?? '');

      String expertiseText = '';
      final rawExpertise = initialData?['expertise'];
      if (rawExpertise is List) {
        expertiseText = rawExpertise.map((e) => e.toString()).join(', ');
      } else if (rawExpertise is String) {
        expertiseText = rawExpertise;
      }
      final expertiseController = TextEditingController(text: expertiseText);

      const validStatuses = ['available', 'busy', 'offline'];
      final rawStatus = (initialData?['status'] ?? 'available').toString().trim().toLowerCase();
      String status = validStatuses.contains(rawStatus) ? rawStatus : 'available';

      debugPrint('4 - OPENING EDIT FORM (name: ${nameController.text}, status: $status)');

      showDialog(
        context: context,
        builder: (ctx) {
          debugPrint('5 - EDIT FORM BUILDER STARTED');
          return StatefulBuilder(
        builder: (context, setDialogState) {
          debugPrint('6 - EDIT FORM DATA LOADED');
          return AlertDialog(

          title: Text(docId == null ? 'Add Mentor Profile' : 'Edit Mentor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Mentor Name')),
                const SizedBox(height: 10),
                TextField(controller: bioController, maxLines: 2, decoration: const InputDecoration(labelText: 'Bio')),
                const SizedBox(height: 10),
                TextField(controller: expController, decoration: const InputDecoration(labelText: 'Experience (e.g. 5 yrs at Google)')),
                const SizedBox(height: 10),
                TextField(controller: expertiseController, decoration: const InputDecoration(labelText: 'Expertise (comma separated)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ['available', 'busy', 'offline']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
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
                if (nameController.text.trim().isEmpty) return;

                final expertise = expertiseController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final data = {
                  'name': nameController.text.trim(),
                  'bio': bioController.text.trim(),
                  'experience': expController.text.trim(),
                  'expertise': expertise,
                  'status': status,
                  'rating': initialData?['rating'] ?? 5.0,
                  'updatedAt': Timestamp.now(),
                };

                if (docId == null) {
                  data['createdAt'] = Timestamp.now();
                  await FirebaseFirestore.instance.collection('mentors').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('mentors').doc(docId).update(data);
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(docId == null ? 'Mentor added!' : 'Mentor updated!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
          );
        },
          );
        },
      );
    } catch (e, stack) {
      debugPrint('EDIT MENTOR DIALOG ERROR: $e');
      debugPrint('$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open edit form: $e')),
        );
      }
    }
  }

  Future<void> _deleteMentor(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mentor'),
        content: Text('Are you sure you want to delete mentor "$name"?'),
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
      await FirebaseFirestore.instance.collection('mentors').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mentor profile deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Mentor'),
        onPressed: () => _showMentorDialog(),
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
                  hintText: 'Search mentors...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final name = (doc.data()['name'] ?? '').toString().toLowerCase();
                    final exp = (doc.data()['experience'] ?? '').toString().toLowerCase();
                    return query.isEmpty || name.contains(query) || exp.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      title: 'No Mentors Found',
                      message: 'No registered mentor profiles match your search query.',
                      lottieAsset: 'assets/animations/empty_users.json',
                      fallbackIcon: Icons.people_outline,
                      actionText: 'Add Mentor',
                      onActionPressed: () => _showMentorDialog(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final name = data['name'] ?? 'Mentor';
                      final experience = data['experience'] ?? '';
                      final status = data['status'] ?? 'available';
                      final rawImage = data['profileImage'] as String? ??
                          data['avatarUrl'] as String? ??
                          data['image'] as String?;
                      final avatarUrl = AppImageHelper.getMentorAvatar(rawImage, doc.id, index);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: AppMentorAvatar(
                            imageUrl: avatarUrl,
                            radius: 22,
                            backgroundColor: Colors.indigo,
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$experience • Status: ${status.toString().toUpperCase()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  debugPrint('1 - PENCIL CLICKED');
                                  debugPrint('2 - MENTOR ID: ${doc.id}');
                                  _showMentorDialog(docId: doc.id, initialData: data);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMentor(doc.id, name),
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