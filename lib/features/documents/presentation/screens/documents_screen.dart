import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/document_model.dart';
import '../providers/documents_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<DocumentsProvider>();

    if (userId == null) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(
          child: Text('Please sign in.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text('My Documents'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kAccent,
        icon: provider.isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.upload_file),
        label: Text(provider.isUploading ? 'Uploading...' : 'Upload Document'),
        onPressed: provider.isUploading ? null : () => _showUploadSheet(context, provider, userId),
      ),
      body: StreamBuilder<List<DocumentModel>>(
        stream: provider.watchUserDocuments(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No documents uploaded yet.', style: TextStyle(color: Colors.white70)),
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
                child: ListTile(
                  leading: _statusIcon(doc.status),
                  title: Text(doc.fileName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${doc.documentType} • ${_statusLabel(doc.status)}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white70),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUploadSheet(BuildContext context, DocumentsProvider provider, String userId) {
    const types = ['CNIC', 'Transcript', 'Certificate', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: types.map((type) {
              return ListTile(
                title: Text(type, style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await provider.pickAndUploadDocument(
                    userId: userId,
                    documentType: type.toLowerCase(),
                  );
                  if (!ok && provider.errorMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _statusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DocumentStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.redAccent);
      case DocumentStatus.pending:
        return const Icon(Icons.hourglass_top, color: Colors.amber);
    }
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.pending:
        return 'Pending review';
    }
  }
}
