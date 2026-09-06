import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _roleFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(String userId, String currentRole) async {
    String newRole = currentRole;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['student', 'mentor', 'admin'].map((role) {
              return RadioListTile<String>(
                title: Text(role.toUpperCase()),
                value: role,
                groupValue: newRole,
                onChanged: (val) {
                  if (val != null) setDialogState(() => newRole = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'role': newRole,
                  'updatedAt': Timestamp.now(),
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User role updated to ${newRole.toUpperCase()}')),
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

  Future<void> _toggleDisableUser(String userId, bool currentlyDisabled) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isDisabled': !currentlyDisabled,
      'updatedAt': Timestamp.now(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentlyDisabled ? 'User account disabled' : 'User account enabled'),
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User Account'),
        content: Text('Are you sure you want to permanently delete user "$userName"?'),
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
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User account permanently deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _roleFilter,
                    items: ['All', 'Student', 'Mentor', 'Admin']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _roleFilter = val);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  final filtered = docs.where((doc) {
                    final data = doc.data();
                    final name = (data['displayName'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    final role = (data['role'] ?? 'student').toString().toLowerCase();

                    final matchesSearch = query.isEmpty || name.contains(query) || email.contains(query);
                    final matchesRole = _roleFilter == 'All' || role == _roleFilter.toLowerCase();

                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const AppEmptyState(
                      title: 'No Matching Users Found',
                      message: 'No registered users match your search query or role filter.',
                      lottieAsset: 'assets/animations/empty_users.json',
                      fallbackIcon: Icons.people_outline,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final userId = doc.id;
                      final name = data['displayName'] ?? 'Unnamed User';
                      final email = data['email'] ?? '';
                      final role = data['role'] ?? 'student';
                      final isDisabled = data['isDisabled'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isDisabled ? Colors.grey.shade200 : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              decoration: isDisabled ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('$email • Role: ${role.toString().toUpperCase()}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'role') _updateUserRole(userId, role);
                              if (val == 'disable') _toggleDisableUser(userId, isDisabled);
                              if (val == 'delete') _deleteUser(userId, name);
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'role', child: Text('Change Role')),
                              PopupMenuItem(
                                value: 'disable',
                                child: Text(isDisabled ? 'Enable Account' : 'Disable Account'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Account', style: TextStyle(color: Colors.red)),
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
