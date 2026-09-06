import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> {
  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final userController = TextEditingController(text: 'all');
    String type = 'general';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: const Text('Send Notification / Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message Body'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient User UID (or "all")',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  items: ['general', 'application_update', 'document_status', 'deadline']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => type = val);
                  },
                  decoration: const InputDecoration(labelText: 'Notification Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) return;

                await FirebaseFirestore.instance.collection('notifications').add({
                  'title': titleController.text.trim(),
                  'message': messageController.text.trim(),
                  'userId': userController.text.trim().isEmpty ? 'all' : userController.text.trim(),
                  'type': type,
                  'isRead': false,
                  'createdAt': Timestamp.now(),
                });

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification broadcast successfully!')),
                  );
                }
              },
              child: const Text('Send'),
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
        title: const Text('Notification Management'),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.send),
        label: const Text('Send Notification'),
        onPressed: () => _showSendNotificationDialog(),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return AppEmptyState(
                title: 'No Broadcast Notifications Sent Yet',
                message: 'Tap "Send Notification" to broadcast updates or alerts to users.',
                lottieAsset: 'assets/animations/empty_notifications.json',
                fallbackIcon: Icons.notifications_active_outlined,
                actionText: 'Send Notification',
                onActionPressed: () => _showSendNotificationDialog(),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final title = data['title'] ?? 'Notification';
                final message = data['message'] ?? '';
                final recipient = data['userId'] ?? 'all';
                final type = data['type'] ?? 'general';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$message\n\nTarget: $recipient • Type: ${type.toString().toUpperCase()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
