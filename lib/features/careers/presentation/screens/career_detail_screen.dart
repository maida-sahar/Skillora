import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CareerDetailScreen extends StatefulWidget {
  const CareerDetailScreen({super.key});

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  bool _isApplying = false;

  Future<void> _applyForCareer({
    required BuildContext context,
    required String userId,
    required String userEmail,
    required String userName,
    required String careerId,
    required String careerTitle,
    required String category,
    required String company,
  }) async {
    setState(() => _isApplying = true);

    try {
      // Create new application in Firestore
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'careerId': careerId,
        'title': careerTitle,
        'careerTitle': careerTitle,
        'company': company,
        'location': 'Skillora Network',
        'category': category,
        'status': 'In progress',
        'progress': 0.5,
        'appliedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully applied for $careerTitle!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to Applications Screen
      Navigator.pushReplacementNamed(context, RouteNames.applications);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    String? careerId;
    if (rawArgs is String) {
      careerId = rawArgs;
    } else if (rawArgs is Map<String, dynamic>) {
      careerId = rawArgs['docId'] as String? ?? rawArgs['careerId'] as String?;
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (careerId == null || careerId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: AppEmptyState(
            title: 'Career Not Found',
            message: 'Invalid career path specified or argument missing.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('careers').doc(careerId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: AppEmptyState(
                  title: 'Opportunity Unavailable',
                  message: 'This career path or opportunity is no longer available.',
                ),
              );
            }

            final data = snapshot.data!.data() ?? {};
            final title = data['title'] as String? ?? 'Career Opportunity';
            final category = (data['category'] ?? data['field'] ?? 'General').toString();
            final description = data['description'] as String? ?? 'No description provided.';
            final education = data['education'] as String? ?? 'Bachelor Degree or Equivalent';
            final level = data['careerLevel'] as String? ?? 'Entry Level';
            final skills = List<String>.from(data['requiredSkills'] ?? []);
            final image = data['image'] as String? ??
                'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?q=80&w=800&auto=format&fit=crop';
            final company = data['company'] as String? ?? data['organization'] as String? ?? 'Skillora Admin';

            return Column(
              children: [
                // Top Custom Header Bar
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
                        'Career Details',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to Bookmarks'),
                              backgroundColor: AppColors.primary,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Banner Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            image,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: AppColors.surfaceDark,
                              child: const Icon(Icons.work_outline_rounded, size: 50, color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          title,
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          company,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMutedDark,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tags Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPurpleBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.pastelPurpleText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pastelOrangeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                level,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.pastelOrangeText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Overview / Description Section Card
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
                                'About this Role',
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
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

                        // Education Requirements Section
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
                                  const Icon(Icons.school_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Education Requirement',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                education,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMutedDark,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Skills Section
                        if (skills.isNotEmpty)
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
                                      'Key Skills Required',
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
                                  children: skills.map((s) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundDark,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.borderDark),
                                      ),
                                      child: Text(
                                        s,
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

                // Fixed Bottom Action Bar with Duplicate Check Stream
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('applications')
                          .where('userId', isEqualTo: user.id)
                          .where('careerId', isEqualTo: careerId)
                          .snapshots(),
                  builder: (context, appSnapshot) {
                    final hasApplied = (appSnapshot.data?.docs ?? []).isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceDark,
                        border: Border(top: BorderSide(color: AppColors.borderDark)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: ElevatedButton(
                          onPressed: (_isApplying || hasApplied || user == null)
                              ? (hasApplied
                                  ? () => Navigator.pushReplacementNamed(context, RouteNames.applications)
                                  : null)
                              : () => _applyForCareer(
                                    context: context,
                                    userId: user.id,
                                    userEmail: user.email,
                                    userName: user.displayName.isNotEmpty
                                        ? user.displayName
                                        : user.email.split('@').first,
                                    careerId: careerId!,
                                    careerTitle: title,
                                    category: category,
                                    company: company,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasApplied ? const Color(0xFF10B981) : AppColors.primary,
                            disabledBackgroundColor: AppColors.surfaceDark,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: _isApplying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  hasApplied
                                      ? '✓ Already Applied (View Status)'
                                      : (user == null ? 'Login to Apply' : 'Apply Now'),
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
