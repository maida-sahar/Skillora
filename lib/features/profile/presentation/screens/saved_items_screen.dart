import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUserId = authProvider.currentUser?.id ?? firebaseUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                    'Saved Items',
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
              child: (currentUserId == null || currentUserId.isEmpty)
                  ? const Center(
                      child: AppEmptyState(
                        title: 'Not Signed In',
                        message: 'Please sign in to view your saved items.',
                      ),
                    )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('saved_items')
                          .where('userId', isEqualTo: currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: AppEmptyState(
                              title: 'Unable to Load Saved Items',
                              message: 'An error occurred while loading your saved bookmarks.',
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                            child: AppEmptyState(
                              title: 'No Saved Items Yet',
                              message: 'Items you bookmark in Explore will automatically appear here.',
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
                            final itemDocId = data['itemDocId'] as String? ?? doc.id;
                            final title = data['title'] as String? ?? 'Saved Opportunity';
                            final description = data['description'] as String? ?? '';
                            final image = data['image'] as String? ??
                                'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=400&auto=format&fit=crop';
                            final category = data['category'] as String? ?? 'General';
                            final level = data['level'] as String? ?? 'Active';
                            final targetRoute = data['targetRoute'] as String? ?? RouteNames.careerDetails;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.borderDark, width: 1),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    targetRoute,
                                    arguments: itemDocId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        image,
                                        width: 76,
                                        height: 76,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 76,
                                          height: 76,
                                          color: const Color(0xFF262836),
                                          child: const Icon(Icons.bookmark_outlined, color: Colors.white54),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: AppTypography.titleMedium.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 20,
                                                  color: AppColors.error,
                                                ),
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('saved_items')
                                                      .doc(doc.id)
                                                      .delete();
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Removed from Saved Items'),
                                                        backgroundColor: AppColors.surfaceDark,
                                                        duration: Duration(seconds: 1),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.textMutedDark,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.pastelPurpleBg,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  category,
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: AppColors.pastelPurpleText,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.pastelOrangeBg,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  level,
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: AppColors.pastelOrangeText,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
