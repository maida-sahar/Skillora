import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MentorDetailScreen extends StatefulWidget {
  const MentorDetailScreen({super.key});

  @override
  State<MentorDetailScreen> createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {

  void _requestMentorshipSession(BuildContext context, String mentorName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: Text(
          'Request Session with $mentorName',
          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your mentorship request will be sent directly to $mentorName. They will review your goals and schedule an intro session.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mentorship request sent to $mentorName!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    String? docId;
    if (rawArgs is String) {
      docId = rawArgs;
    } else if (rawArgs is Map<String, dynamic>) {
      docId = rawArgs['docId'] as String? ?? rawArgs['mentorId'] as String?;
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (docId == null || docId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: AppEmptyState(
            title: 'Mentor Not Found',
            message: 'Invalid mentor profile specified or argument missing.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('mentors').doc(docId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: AppEmptyState(
                  title: 'Mentor Profile Unavailable',
                  message: 'This mentor profile is no longer available.',
                ),
              );
            }

            final data = snapshot.data!.data() ?? {};
            final name = data['name'] as String? ?? 'Mentor';
            final role = data['title'] as String? ?? data['role'] as String? ?? 'Career Advisor';
            final organization = data['organization'] as String? ?? data['company'] as String? ?? 'Skillora Mentors';
            final bio = data['bio'] as String? ?? data['description'] as String? ?? 'Experienced industry mentor.';
            final avatar = data['avatarUrl'] as String? ?? data['image'] as String? ??
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop';
            final expertise = List<String>.from(data['skills'] ?? data['expertise'] ?? ['Career Guidance', 'Portfolio Review']);

            return Column(
              children: [
                // Top Custom Header Bar with Back Button
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
                        'Mentor Profile',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Mentor Avatar Header
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.surfaceDark,
                          backgroundImage: NetworkImage(avatar),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          name,
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          '$role • $organization',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // About Mentor Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Mentor',
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bio,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMutedDark,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Expertise & Skills Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Areas of Expertise',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: expertise.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundDark,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.borderDark),
                                    ),
                                    child: Text(
                                      item,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Request Session Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border(top: BorderSide(color: AppColors.borderDark)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: user == null ? null : () => _requestMentorshipSession(context, name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceDark,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        user == null ? 'Login to Connect' : 'Request 1-on-1 Mentorship',
                        style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
