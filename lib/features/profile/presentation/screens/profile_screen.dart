import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/chips/app_chip.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showImagePickerModal(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Profile Picture',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Choose from Gallery', style: AppTypography.bodyMedium),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await profileProvider.pickImage(ImageSource.gallery);
                  if (!ok && profileProvider.errorMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(profileProvider.errorMessage!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Take Photo with Camera', style: AppTypography.bodyMedium),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await profileProvider.pickImage(ImageSource.camera);
                  if (!ok && profileProvider.errorMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(profileProvider.errorMessage!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadImage(BuildContext context, String userId, String? oldAvatarUrl) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final publicUrl = await profileProvider.uploadProfilePicture(userId, oldImageUrl: oldAvatarUrl);

    if (publicUrl != null) {
      authProvider.updateCurrentUserAvatar(publicUrl);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (context.mounted && profileProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated.')),
      );
    }

    final selectedBytes = profileProvider.selectedImageBytes;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('User Profile', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar & Profile Header Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: isDark ? AppColors.cardDark : AppColors.softBlue,
                              backgroundImage: selectedBytes != null
                                  ? MemoryImage(selectedBytes) as ImageProvider
                                  : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                      ? NetworkImage(user.avatarUrl!)
                                      : null),
                              child: (selectedBytes == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                                  ? Text(
                                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                      style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                                    )
                                  : null,
                            ),
                          ),
                          if (profileProvider.isUploading)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: profileProvider.isUploading ? null : () => _showImagePickerModal(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedBytes != null) ...[
                      Text(
                        'New image selected',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.info),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: profileProvider.isUploading ? null : () => profileProvider.clearSelectedImage(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            text: 'Upload',
                            height: 40,
                            onPressed: profileProvider.isUploading ? null : () => _uploadImage(context, user.id, user.avatarUrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      user.displayName,
                      style: AppTypography.displayMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppChip(
                      label: 'Role: ${user.role.toUpperCase()}',
                      variant: AppChipVariant.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details List Cards
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Education Field',
                      value: user.educationField ?? 'Not specified',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.stars_outlined,
                      title: 'Skills',
                      value: user.skillsList.isNotEmpty ? user.skillsList.join(', ') : 'No skills added yet',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
