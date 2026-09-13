import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  void _showAddEditEducationDialog(BuildContext context, String userId, {DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final schoolController = TextEditingController(text: data?['school'] as String? ?? data?['institution'] as String? ?? '');
    final degreeController = TextEditingController(text: data?['degree'] as String? ?? '');
    final fieldController = TextEditingController(text: data?['fieldOfStudy'] as String? ?? '');
    final startYearController = TextEditingController(text: data?['startYear'] as String? ?? '');
    final endYearController = TextEditingController(text: data?['endYear'] as String? ?? '');
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
                      doc == null ? 'Add Education' : 'Edit Education',
                      style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField('School / Institution', schoolController, 'e.g. Stanford University'),
                const SizedBox(height: 12),
                _buildTextField('Degree / Qualification', degreeController, 'e.g. Bachelor of Science'),
                const SizedBox(height: 12),
                _buildTextField('Field of Study', fieldController, 'e.g. Computer Science'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildTextField('Start Year', startYearController, 'e.g. 2022')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('End Year / Expected', endYearController, 'e.g. 2026')),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final school = schoolController.text.trim();
                          final degree = degreeController.text.trim();
                          final field = fieldController.text.trim();
                          if (school.isEmpty || degree.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please provide School and Degree')),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            final eduData = {
                              'school': school,
                              'institution': school,
                              'degree': degree,
                              'fieldOfStudy': field,
                              'startYear': startYearController.text.trim(),
                              'endYear': endYearController.text.trim(),
                              'updatedAt': Timestamp.now(),
                            };

                            if (doc == null) {
                              eduData['createdAt'] = Timestamp.now();
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('education')
                                  .add(eduData);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('education')
                                  .doc(doc.id)
                                  .update(eduData);
                            }

                            // Update user's main education field on user document
                            if (field.isNotEmpty) {
                              await FirebaseFirestore.instance.collection('users').doc(userId).update({
                                'education': field,
                                'updatedAt': Timestamp.now(),
                              });
                              if (context.mounted) {
                                context.read<AuthProvider>().refreshUserData();
                              }
                            }

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Education saved successfully!'),
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
                      : Text(doc == null ? 'Add Record' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEducation(String userId, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('education')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education deleted'), backgroundColor: AppColors.success),
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
          'Education History',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (userId == null || userId.isEmpty)
            ? null
            : () => _showAddEditEducationDialog(context, userId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Education', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: userId == null || userId.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('education')
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
                        title: 'No education records',
                        message: 'Add your high school, university, or certification details to complete your profile.',
                        fallbackIcon: Icons.school_outlined,
                        actionText: 'Add Education',
                        onActionPressed: () => _showAddEditEducationDialog(context, userId),
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
                      final school = data['school'] as String? ?? data['institution'] as String? ?? 'Institution';
                      final degree = data['degree'] as String? ?? 'Degree';
                      final field = data['fieldOfStudy'] as String? ?? '';
                      final startYear = data['startYear'] as String? ?? '';
                      final endYear = data['endYear'] as String? ?? '';

                      String yearRange = '';
                      if (startYear.isNotEmpty || endYear.isNotEmpty) {
                        yearRange = '$startYear - ${endYear.isEmpty ? "Present" : endYear}';
                      }

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
                                color: AppColors.pastelPurpleBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    school,
                                    style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    field.isNotEmpty ? '$degree • $field' : degree,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, fontSize: 13),
                                  ),
                                  if (yearRange.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      yearRange,
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.pastelPurpleText, fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                              onPressed: () => _showAddEditEducationDialog(context, userId, doc: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                              onPressed: () => _deleteEducation(userId, doc.id),
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
