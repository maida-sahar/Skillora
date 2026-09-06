import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ApplicationManagementScreen extends StatefulWidget {
  const ApplicationManagementScreen({super.key});

  @override
  State<ApplicationManagementScreen> createState() => _ApplicationManagementScreenState();
}

class _ApplicationManagementScreenState extends State<ApplicationManagementScreen> {
  String _statusFilter = 'All';

  Future<void> _updateStatus(String docId, String currentStatus, String? currentNotes) async {
    String newStatus = currentStatus;
    final notesController = TextEditingController(text: currentNotes ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: const Text('Update Application Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: newStatus,
                  items: ['Applied', 'Under Review', 'Interview', 'Accepted', 'Rejected']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => newStatus = val);
                  },
                  decoration: const InputDecoration(labelText: 'Application Status'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Admin Notes / Rejection Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('applications').doc(docId).update({
                  'status': newStatus,
                  'notes': notesController.text.trim(),
                  'updatedAt': Timestamp.now(),
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Application status updated to $newStatus')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Management'),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('Filter Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Applied', 'Under Review', 'Accepted', 'Rejected'].map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: _statusFilter == status,
                              onSelected: (_) => setState(() => _statusFilter = status),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('applications').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];

                  final filtered = docs.where((doc) {
                    final status = doc.data()['status'] ?? 'Applied';
                    return _statusFilter == 'All' || status == _statusFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const AppEmptyState(
                      title: 'No Applications Match Filter',
                      message: 'No student applications found for the selected status filter.',
                      lottieAsset: 'assets/animations/empty_applications.json',
                      fallbackIcon: Icons.assignment_outlined,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final type = data['applicationType'] ?? 'scholarship';
                      final status = data['status'] ?? 'Applied';
                      final notes = data['notes'] as String?;
                      final userId = data['userId'] ?? 'Unknown Student';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(status).withAlpha(50),
                            child: Icon(_statusIcon(status), color: _statusColor(status)),
                          ),
                          title: Text('Student UID: $userId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Type: ${type.toUpperCase()} • Status: $status${notes != null && notes.isNotEmpty ? '\nNotes: $notes' : ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () => _updateStatus(doc.id, status, notes),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Under Review': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Accepted': return Icons.check_circle;
      case 'Rejected': return Icons.cancel;
      case 'Under Review': return Icons.hourglass_top;
      default: return Icons.assignment;
    }
  }
}
