import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/chips/app_chip.dart';
import '../../../../shared/widgets/loaders/app_shimmer.dart';
import '../../data/models/document_model.dart';
import '../providers/documents_provider.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<DocumentsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (userId == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(
          child: AppEmptyState(
            title: 'Sign In Required',
            message: 'Please sign in to upload and view your verified documents.',
            lottieAsset: 'assets/animations/empty_users.json',
            fallbackIcon: Icons.lock_outline,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('My Documents', style: AppTypography.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: provider.isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: Text(
          provider.isUploading ? 'Uploading...' : 'Upload Document',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
        onPressed: provider.isUploading ? null : () => _showUploadSheet(context, provider, userId),
      ),
      body: StreamBuilder<List<DocumentModel>>(
        stream: provider.watchUserDocuments(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: AppShimmerCardList(itemCount: 4),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return AppEmptyState(
              title: 'No Documents Uploaded Yet',
              message: 'Upload your transcripts or certificates for official verification.',
              lottieAsset: 'assets/animations/empty_documents.json',
              fallbackIcon: Icons.folder_open_outlined,
              actionText: 'Upload Document',
              onActionPressed: () => _showUploadSheet(context, provider, userId),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusBg(doc.status),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_statusIconData(doc.status), color: _statusColor(doc.status), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doc.documentType.toUpperCase(),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppChip(
                      label: _statusLabel(doc.status),
                      variant: _statusChipVariant(doc.status),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, color: AppColors.primary),
                      onPressed: () async {
                        final url = await provider.getViewUrl(doc.storagePath);
                        if (url != null) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else if (context.mounted && provider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppColors.error),
                          );
                        }
                      },
                    ),
                  ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Document Type',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 14),
                ...types.map((type) {
                  return ListTile(
                    leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                    title: Text(
                      type,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final ok = await provider.pickAndUploadDocument(
                        userId: userId,
                        documentType: type.toLowerCase(),
                      );
                      if (!ok && provider.errorMessage != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppColors.error),
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _statusIconData(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Icons.check_circle_outline;
      case DocumentStatus.rejected:
        return Icons.cancel_outlined;
      case DocumentStatus.pending:
        return Icons.hourglass_top_outlined;
    }
  }

  Color _statusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
      case DocumentStatus.pending:
        return AppColors.warning;
    }
  }

  Color _statusBg(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.successLight;
      case DocumentStatus.rejected:
        return AppColors.errorLight;
      case DocumentStatus.pending:
        return AppColors.warningLight;
    }
  }

  AppChipVariant _statusChipVariant(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppChipVariant.success;
      case DocumentStatus.rejected:
        return AppChipVariant.error;
      case DocumentStatus.pending:
        return AppChipVariant.warning;
    }
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.pending:
        return 'Pending';
    }
  }
}
