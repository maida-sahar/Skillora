import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showImagePickerModal(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6C5CE7)),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await profileProvider.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6C5CE7)),
                title: const Text('Take Photo with Camera'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await profileProvider.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadImage(BuildContext context, String userId) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final publicUrl = await profileProvider.uploadProfilePicture(userId);

    if (publicUrl != null) {
      // Update local AuthProvider user state so avatar updates globally across the app
      authProvider.updateCurrentUserAvatar(publicUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (context.mounted && profileProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated.')),
      );
    }

    final selectedImage = profileProvider.selectedImageFile;

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6C5CE7), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage) as ImageProvider
                            : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null),
                        child: (selectedImage == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                            ? Text(
                                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7)),
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
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF6C5CE7),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (selectedImage != null) ...[
                const Text(
                  'Image preview selected. Tap upload to save.',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
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
                    ElevatedButton.icon(
                      onPressed: profileProvider.isUploading ? null : () => _uploadImage(context, user.id),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload & Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                user.displayName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(
                  'Role: ${user.role.toUpperCase()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: const Color(0xFF6C5CE7),
              ),
              const SizedBox(height: 32),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Education'),
                subtitle: Text(user.educationField ?? 'Not specified'),
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Skills'),
                subtitle: Text(user.skillsList.isNotEmpty ? user.skillsList.join(', ') : 'No skills added yet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
