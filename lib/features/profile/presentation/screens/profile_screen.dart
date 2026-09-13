import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showImagePickerModal(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
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
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Choose from Gallery', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
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
                title: Text('Take Photo with Camera', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
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

    final name = (user?.displayName.isNotEmpty == true)
        ? user!.displayName
        : (user?.email.isNotEmpty == true ? user!.email.split('@').first : 'User');
    final userAvatar = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
        ? user.avatarUrl!
        : '';

    final selectedBytes = profileProvider.selectedImageBytes;

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Personal information',
        'icon': Icons.person_outline_rounded,
        'route': RouteNames.personalInformation,
      },
      {
        'title': 'Education',
        'icon': Icons.school_outlined,
        'route': RouteNames.education,
      },
      {
        'title': 'Skills & interests',
        'icon': Icons.stars_outlined,
        'route': RouteNames.skillAssessment,
      },
      {
        'title': 'Work experience',
        'icon': Icons.work_outline_rounded,
        'route': RouteNames.workExperience,
      },
      {
        'title': 'Achievements',
        'icon': Icons.workspace_premium_outlined,
        'route': RouteNames.achievements,
      },
      {
        'title': 'Saved items',
        'icon': Icons.bookmark_border_rounded,
        'route': RouteNames.savedItems,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header Title "Profile" & Settings Gear Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceDark,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(40, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.borderDark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        'Profile',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, RouteNames.settings),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Profile Section (Avatar, Name, Title, Location, Edit Profile Button)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDark, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.surfaceDark,
                      backgroundImage: selectedBytes != null
                          ? MemoryImage(selectedBytes) as ImageProvider
                          : (userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null),
                      child: (selectedBytes == null && userAvatar.isEmpty)
                          ? const Icon(Icons.person_rounded, size: 44, color: AppColors.textMutedDark)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: profileProvider.isUploading ? null : () => _showImagePickerModal(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (selectedBytes != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => profileProvider.clearSelectedImage(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () => _uploadImage(context, user?.id ?? '', user?.avatarUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(80, 34),
                      ),
                      child: const Text('Upload'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              Text(
                name,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (user?.educationField != null && user!.educationField!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.educationField!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMutedDark,
                    fontSize: 13,
                  ),
                ),
              ],
              if (user?.careerGoalsList.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      user!.careerGoalsList.first,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMutedDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Edit Profile Button
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.personalInformation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  'Edit profile',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section Menu Card Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderDark, width: 1),
                ),
                child: Column(
                  children: List.generate(menuItems.length, (index) {
                    final item = menuItems[index];
                    final isLast = index == menuItems.length - 1;

                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (item['route'] != null) {
                              Navigator.pushNamed(context, item['route'] as String);
                            }
                          },
                          leading: Icon(
                            item['icon'] as IconData,
                            color: AppColors.textMutedDark,
                            size: 20,
                          ),
                          title: Text(
                            item['title'] as String,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMutedDark,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.borderDark,
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
