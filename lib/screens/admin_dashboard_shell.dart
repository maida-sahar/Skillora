import 'package:flutter/material.dart';

class AdminDashboardShell extends StatelessWidget {
  const AdminDashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(
        child: Text('Admin Management Panel'),
      ),
    );
  }
}