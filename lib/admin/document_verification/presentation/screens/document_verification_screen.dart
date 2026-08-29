import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../features/documents/data/models/document_model.dart';
import '../providers/document_verification_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  String? _statusFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentVerificationProvider>();
    final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text('Document Verification'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _statusFilter,
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'verified', child: Text('Verified')),
              PopupMenuItem(value: 'rejected', child: Text('Rejected')),
              PopupMenuItem(value: null, child: Text('All')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<DocumentModel>>(
        stream: provider.watchDocuments(statusFilter: _statusFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No documents found.', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                color: _kSurface,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.fileName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Type: ${doc.documentType}', style: const TextStyle(color: Colors.white54)),
                      Text(
                        'User: ${doc.userId}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.visibility, color: Colors.white70),
                            label: const Text('View', style: TextStyle(color: Colors.white70)),
                            onPressed: () async {
                              final url = await provider.getViewUrl(doc.storagePath);
                              if (url != null) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              } else if (context.mounted && provider.errorMessage != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
                              }
                            },
                          ),
                          const Spacer(),
                          if (doc.status == DocumentStatus.pending) ...[
                            TextButton(
                              onPressed: () => provider.approve(doc, adminId),
                              child: const Text('Verify', style: TextStyle(color: Colors.green)),
                            ),
                            TextButton(
                              onPressed: () => _showRejectDialog(context, provider, doc, adminId),
                              child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ] else
                            Chip(
                              label: Text(
                                doc.status == DocumentStatus.verified ? 'Verified' : 'Rejected',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: doc.status == DocumentStatus.verified
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    DocumentVerificationProvider provider,
    DocumentModel doc,
    String adminId,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text('Reject Document', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.reject(doc, adminId, controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
