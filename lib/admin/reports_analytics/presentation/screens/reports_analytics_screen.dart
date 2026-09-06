import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalApplications = 0;
  int _totalScholarships = 0;
  int _totalCareers = 0;
  int _pendingDocuments = 0;
  int _verifiedDocuments = 0;
  int _activeMentors = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final appsSnap = await FirebaseFirestore.instance.collection('applications').get();
      final scholarSnap = await FirebaseFirestore.instance.collection('scholarships').get();
      final careersSnap = await FirebaseFirestore.instance.collection('careers').get();
      final docsSnap = await FirebaseFirestore.instance.collection('documents').get();
      final mentorsSnap = await FirebaseFirestore.instance.collection('mentors').get();

      final pendingDocs = docsSnap.docs.where((d) => d.data()['status'] == 'pending').length;
      final verifiedDocs = docsSnap.docs.where((d) => d.data()['status'] == 'verified').length;

      if (mounted) {
        setState(() {
          _totalUsers = usersSnap.docs.length;
          _totalApplications = appsSnap.docs.length;
          _totalScholarships = scholarSnap.docs.length;
          _totalCareers = careersSnap.docs.length;
          _pendingDocuments = pendingDocs;
          _verifiedDocuments = verifiedDocs;
          _activeMentors = mentorsSnap.docs.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _exportReport(String format) async {
    final String content;
    final String mimeType;

    if (format == 'csv') {
      content = 'Metric,Value\n'
          'Total Users,$_totalUsers\n'
          'Total Applications,$_totalApplications\n'
          'Total Scholarships,$_totalScholarships\n'
          'Total Careers,$_totalCareers\n'
          'Pending Document Verifications,$_pendingDocuments\n'
          'Verified Documents,$_verifiedDocuments\n'
          'Active Mentors,$_activeMentors\n';
      mimeType = 'text/csv';
    } else if (format == 'excel') {
      content = 'Metric\tValue\n'
          'Total Users\t$_totalUsers\n'
          'Total Applications\t$_totalApplications\n'
          'Total Scholarships\t$_totalScholarships\n'
          'Total Careers\t$_totalCareers\n'
          'Pending Document Verifications\t$_pendingDocuments\n'
          'Verified Documents\t$_verifiedDocuments\n'
          'Active Mentors\t$_activeMentors\n';
      mimeType = 'application/vnd.ms-excel';
    } else {
      content = 'SKILLORA REPORTS AND ANALYTICS SUMMARY\n'
          'Generated At: ${DateTime.now().toIso8601String()}\n'
          '-----------------------------------------\n'
          'Total Users: $_totalUsers\n'
          'Total Applications: $_totalApplications\n'
          'Total Scholarships: $_totalScholarships\n'
          'Total Careers: $_totalCareers\n'
          'Pending Document Verifications: $_pendingDocuments\n'
          'Verified Documents: $_verifiedDocuments\n'
          'Active Mentors: $_activeMentors\n';
      mimeType = 'application/pdf';
    }

    final bytes = utf8.encode(content);
    final uri = Uri.dataFromBytes(bytes, mimeType: mimeType);

    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Exported ${format.toUpperCase()} Report'),
            content: SingleChildScrollView(
              child: SelectableText(content),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStats),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_totalUsers == 0 && _totalApplications == 0 && _totalScholarships == 0 && _totalCareers == 0)
                ? AppEmptyState(
                    title: 'No Analytics Data Available',
                    message: 'No platform activity or metrics recorded yet for report generation.',
                    lottieAsset: 'assets/animations/empty_data.json',
                    fallbackIcon: Icons.analytics_outlined,
                    actionText: 'Refresh Metrics',
                    onActionPressed: _fetchStats,
                  )
                : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Platform Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard('Total Users', '$_totalUsers', Icons.people, Colors.blue),
                        _buildStatCard('Applications', '$_totalApplications', Icons.assignment, Colors.green),
                        _buildStatCard('Scholarships', '$_totalScholarships', Icons.school, Colors.orange),
                        _buildStatCard('Careers', '$_totalCareers', Icons.work, Colors.purple),
                        _buildStatCard('Pending Docs', '$_pendingDocuments', Icons.hourglass_top, Colors.amber),
                        _buildStatCard('Verified Docs', '$_verifiedDocuments', Icons.check_circle, Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Export Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: const Text('PDF', style: TextStyle(color: Colors.white)),
                            onPressed: () => _exportReport('pdf'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            icon: const Icon(Icons.table_chart, color: Colors.white),
                            label: const Text('Excel', style: TextStyle(color: Colors.white)),
                            onPressed: () => _exportReport('excel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                            icon: const Icon(Icons.description, color: Colors.white),
                            label: const Text('CSV', style: TextStyle(color: Colors.white)),
                            onPressed: () => _exportReport('csv'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
