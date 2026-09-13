import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ScholarshipDetailScreen extends StatefulWidget {
  const ScholarshipDetailScreen({super.key});

  @override
  State<ScholarshipDetailScreen> createState() => _ScholarshipDetailScreenState();
}

class _ScholarshipDetailScreenState extends State<ScholarshipDetailScreen> {
  bool _isApplying = false;

  Future<void> _applyForScholarship({
    required BuildContext context,
    required String userId,
    required String userEmail,
    required String userName,
    required String scholarshipId,
    required String title,
    required String organization,
    required String field,
  }) async {
    setState(() => _isApplying = true);

    try {
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'scholarshipId': scholarshipId,
        'title': title,
        'company': organization,
        'organization': organization,
        'location': 'Scholarship Grant',
        'category': field,
        'type': 'scholarship',
        'status': 'In progress',
        'progress': 0.5,
        'appliedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully applied for $title!'),
          backgroundColor: AppColors.success,
        ),
      );

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
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    String? docId;
    if (rawArgs is String) {
      docId = rawArgs;
    } else if (rawArgs is Map<String, dynamic>) {
      docId = rawArgs['docId'] as String? ?? rawArgs['scholarshipId'] as String?;
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
            title: 'Scholarship Not Found',
            message: 'Invalid scholarship ID or argument missing.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('scholarships').doc(docId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: AppEmptyState(
                  title: 'Scholarship Unavailable',
                  message: 'This scholarship opportunity is no longer active.',
                ),
              );
            }

            final data = snapshot.data!.data() ?? {};
            final title = data['title'] as String? ?? 'Scholarship Opportunity';
            final organization = data['organization'] as String? ?? data['company'] as String? ?? 'Skillora Partner';
            final field = (data['field'] ?? data['category'] ?? 'General').toString();
            final description = data['description'] as String? ?? 'No description provided.';
            final amountStr = data['amount'] != null ? '\$${data['amount']}' : 'Fully Funded';
            final country = data['country'] as String? ?? 'Global';
            final eligibility = List<String>.from(data['eligibilityCriteria'] ?? data['eligibility'] ?? []);
            final requiredDocs = List<String>.from(data['requiredDocuments'] ?? []);
            final image = data['image'] as String? ??
                'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=800&auto=format&fit=crop';

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
                        'Scholarship Details',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              child: const Icon(Icons.school_outlined, size: 50, color: Colors.white54),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

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
                          '$organization • $country',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMutedDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),

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
                                field,
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
                                amountStr,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.pastelOrangeText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Overview Card
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
                                'About this Grant',
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

                        if (eligibility.isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                                    const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Eligibility Requirements',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...eligibility.map((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(e, style: AppTypography.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],

                        if (requiredDocs.isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                                    const Icon(Icons.folder_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Required Documents',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...requiredDocs.map((d) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.description_outlined, color: AppColors.textMutedDark, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(d, style: AppTypography.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Apply CTA
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('applications')
                          .where('userId', isEqualTo: user.id)
                          .where('scholarshipId', isEqualTo: docId)
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
                              ? (hasApplied ? () => Navigator.pushReplacementNamed(context, RouteNames.applications) : null)
                              : () => _applyForScholarship(
                                    context: context,
                                    userId: user.id,
                                    userEmail: user.email,
                                    userName: user.displayName.isNotEmpty ? user.displayName : user.email.split('@').first,
                                    scholarshipId: docId!,
                                    title: title,
                                    organization: organization,
                                    field: field,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasApplied ? const Color(0xFF10B981) : AppColors.primary,
                            disabledBackgroundColor: AppColors.surfaceDark,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isApplying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  hasApplied ? '✓ Application Submitted (View Status)' : (user == null ? 'Login to Apply' : 'Apply for Scholarship'),
                                  style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
