import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  final TextEditingController _supportEmailController = TextEditingController(text: 'support@skillora.app');
  final TextEditingController _reminderDaysController = TextEditingController(text: '7');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('app_config').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _maintenanceMode = data['maintenanceMode'] ?? false;
          _supportEmailController.text = data['supportEmail'] ?? 'support@skillora.app';
          _reminderDaysController.text = (data['reminderDays'] ?? 7).toString();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      await FirebaseFirestore.instance.collection('settings').doc('app_config').set({
        'maintenanceMode': _maintenanceMode,
        'supportEmail': _supportEmailController.text.trim(),
        'reminderDays': int.tryParse(_reminderDaysController.text.trim()) ?? 7,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin settings saved successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Disable student operations during platform updates'),
                      value: _maintenanceMode,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _supportEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Support Contact Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reminderDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Deadline Reminder Threshold (Days)',
                        prefixIcon: Icon(Icons.alarm),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: _saveSettings,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
