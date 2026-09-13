import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class WorkExperienceScreen extends StatefulWidget {
  const WorkExperienceScreen({super.key});

  @override
  State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  void _showAddExperienceDialog(BuildContext context, String userId) {
    _titleController.clear();
    _companyController.clear();
    _durationController.clear();
    _descriptionController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Work Experience',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Job Title / Position',
                    labelStyle: TextStyle(color: AppColors.textMutedDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Company / Organization',
                    labelStyle: TextStyle(color: AppColors.textMutedDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter company name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Duration (e.g. 2023 - Present)',
                    labelStyle: TextStyle(color: AppColors.textMutedDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter duration' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Key Responsibilities / Impact',
                    labelStyle: TextStyle(color: AppColors.textMutedDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveExperience(ctx, userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Experience', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveExperience(BuildContext dialogContext, String userId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final newExp = {
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
      };
      await docRef.set({
        'workExperience': FieldValue.arrayUnion([newExp]),
      }, SetOptions(merge: true));

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work experience saved!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (dialogContext.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userId = authProvider.currentUser?.id ?? firebaseUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: userId == null ? null : () => _showAddExperienceDialog(context, userId),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Header with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                  ),
                  Text(
                    'Work Experience',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: userId == null
                  ? const Center(
                      child: AppEmptyState(
                        title: 'Not Signed In',
                        message: 'Please sign in to view your work experience.',
                      ),
                    )
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                        }

                        final data = snapshot.data?.data() ?? {};
                        final rawList = data['workExperience'] as List<dynamic>? ?? [];
                        final experiences = rawList.cast<Map<String, dynamic>>();

                        if (experiences.isEmpty) {
                          return const Center(
                            child: AppEmptyState(
                              title: 'No Experience Added',
                              message: 'Tap the + button to add your previous work or internship experience.',
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: experiences.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final exp = experiences[index];
                            final title = exp['title'] as String? ?? 'Position';
                            final company = exp['company'] as String? ?? 'Organization';
                            final duration = exp['duration'] as String? ?? '';
                            final desc = exp['description'] as String? ?? '';

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
                                      color: AppColors.backgroundDark,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderDark),
                                    ),
                                    child: const Icon(Icons.business_center_outlined, color: AppColors.primary, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$company • $duration',
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight, fontSize: 13),
                                        ),
                                        if (desc.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            desc,
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, height: 1.4),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
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
