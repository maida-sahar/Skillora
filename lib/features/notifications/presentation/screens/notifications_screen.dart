import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: AppEmptyState(
          title: 'Sign In Required',
          message: 'Please sign in to view your notifications.',
          lottieAsset: 'assets/animations/empty_users.json',
          fallbackIcon: Icons.lock_outline,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Center'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          final userNotifs = docs.where((doc) {
            final recipient = doc.data()['userId'] ?? 'all';
            return recipient == 'all' || recipient == userId;
          }).toList();

          if (userNotifs.isEmpty) {
            return const AppEmptyState(
              title: "You're All Caught Up!",
              message: 'No new notifications at this time.',
              lottieAsset: 'assets/animations/empty_notifications.json',
              fallbackIcon: Icons.notifications_off_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userNotifs.length,
            itemBuilder: (context, index) {
              final doc = userNotifs[index];
              final data = doc.data();
              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final isRead = data['isRead'] == true;
              final createdAtTs = data['createdAt'] as Timestamp?;
              final date = createdAtTs?.toDate() ?? DateTime.now();

              return Card(
                color: isRead ? null : Colors.indigo.shade50,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(Icons.notifications_active, color: Colors.indigo),
                  ),
                  title: Text(title, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text('$message\n\n${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    if (!isRead) {
                      await FirebaseFirestore.instance.collection('notifications').doc(doc.id).update({'isRead': true});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
