import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  void _showAddEditAchievementDialog(BuildContext context, String userId, {DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final titleController = TextEditingController(text: data?['title'] as String? ?? '');
    final issuerController = TextEditingController(text: data?['issuer'] as String? ?? data?['organization'] as String? ?? '');
    final dateController = TextEditingController(text: data?['issueDate'] as String? ?? '');
    final descController = TextEditingController(text: data?['description'] as String? ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      doc == null ? 'Add Achievement' : 'Edit Achievement',
                      style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField('Achievement Title', titleController, 'e.g. AWS Certified Developer'),
                const SizedBox(height: 12),
                _buildTextField('Issuer / Organization', issuerController, 'e.g. Amazon Web Services'),
                const SizedBox(height: 12),
                _buildTextField('Issue Date / Year', dateController, 'e.g. May 2025'),
                const SizedBox(height: 12),
                _buildTextField('Description / Notes', descController, 'e.g. Completed advanced cloud development certification'),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final issuer = issuerController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an achievement title')),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            final itemData = {
                              'title': title,
                              'issuer': issuer,
                              'organization': issuer,
                              'issueDate': dateController.text.trim(),
                              'description': descController.text.trim(),
                              'updatedAt': Timestamp.now(),
                            };

                            if (doc == null) {
                              itemData['createdAt'] = Timestamp.now();
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('achievements')
                                  .add(itemData);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('achievements')
                                  .doc(doc.id)
                                  .update(itemData);
                            }

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Achievement saved successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(doc == null ? 'Add Achievement' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAchievement(String userId, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achievement deleted'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userId = authProvider.currentUser?.id ?? firebaseUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Achievements & Awards',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (userId == null || userId.isEmpty)
            ? null
            : () => _showAddEditAchievementDialog(context, userId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Achievement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: userId == null || userId.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('achievements')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: AppEmptyState(
                        title: 'No achievements added',
                        message: 'Showcase your certifications, awards, grants, or competition milestones.',
                        fallbackIcon: Icons.workspace_premium_outlined,
                        actionText: 'Add Achievement',
                        onActionPressed: () => _showAddEditAchievementDialog(context, userId),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final title = data['title'] as String? ?? 'Achievement';
                      final issuer = data['issuer'] as String? ?? data['organization'] as String? ?? '';
                      final date = data['issueDate'] as String? ?? '';
                      final desc = data['description'] as String? ?? '';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.pastelOrangeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.workspace_premium_outlined, color: AppColors.pastelOrangeText, size: 22),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  if (issuer.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      issuer,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, fontSize: 13),
                                    ),
                                  ],
                                  if (date.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.pastelOrangeText, fontSize: 11),
                                    ),
                                  ],
                                  if (desc.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      desc,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                              onPressed: () => _showAddEditAchievementDialog(context, userId, doc: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                              onPressed: () => _deleteAchievement(userId, doc.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark),
            filled: true,
            fillColor: AppColors.backgroundDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
