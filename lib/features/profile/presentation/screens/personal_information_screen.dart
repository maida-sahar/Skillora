import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _educationController;
  late TextEditingController _careerGoalController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _educationController = TextEditingController(text: user?.educationField ?? '');
    _careerGoalController = TextEditingController(
      text: user?.careerGoalsList.isNotEmpty == true ? user!.careerGoalsList.first : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _careerGoalController.dispose();
    super.dispose();
  }

  Future<void> _savePersonalInformation() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null || user.id.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final updatedName = _nameController.text.trim();
      final updatedEdu = _educationController.text.trim();
      final updatedGoal = _careerGoalController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'name': updatedName,
        'displayName': updatedName,
        'education': updatedEdu,
        'careerGoals': updatedGoal.isNotEmpty ? [updatedGoal] : [],
        'updatedAt': Timestamp.now(),
      });

      await authProvider.refreshUserData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal Information saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Personal Information',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your account details and profile information.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark),
                ),
                const SizedBox(height: 24),

                // Full Name
                _buildLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _buildInputDecoration('Enter your full name', Icons.person_outline_rounded),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 18),

                // Email Address (Read Only)
                _buildLabel('Email Address (Account ID)'),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 14),
                  decoration: _buildInputDecoration('Email address', Icons.email_outlined).copyWith(
                    filled: true,
                    fillColor: const Color(0xFF181A24),
                  ),
                ),
                const SizedBox(height: 18),

                // Education / Field of Study
                _buildLabel('Field of Study / Title'),
                TextFormField(
                  controller: _educationController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Computer Science, Product Design', Icons.school_outlined),
                ),
                const SizedBox(height: 18),

                // Primary Career Goal
                _buildLabel('Primary Career Goal'),
                TextFormField(
                  controller: _careerGoalController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Backend Developer, Data Scientist', Icons.work_outline_rounded),
                ),

                const SizedBox(height: 36),

                // Save Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _savePersonalInformation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceDark,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Save Information',
                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTypography.titleMedium.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark),
      prefixIcon: Icon(prefixIcon, color: AppColors.textMutedDark, size: 20),
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
