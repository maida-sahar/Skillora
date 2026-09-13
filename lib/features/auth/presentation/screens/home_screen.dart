import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeCareerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userName = (user?.displayName.isNotEmpty == true) ? user!.displayName.split(' ').first : 'User';
    final userAvatar = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
        ? user.avatarUrl!
        : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=256&auto=format&fit=crop';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header with Avatar & App Name & Notification Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceDark,
                          backgroundImage: NetworkImage(userAvatar),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Skillora',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, RouteNames.notifications),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
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
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Greeting & Subtitle
              Text(
                'Good morning, $userName 👋',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What do you want to learn today?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMutedDark,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // Rounded Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.borderDark, width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMutedDark,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onSubmitted: (val) {
                          Navigator.pushNamed(context, RouteNames.explore);
                        },
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search careers, skills or pathways...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMutedDark,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Recommended Careers Header
              _buildSectionHeader(
                title: 'Recommended careers',
                onSeeAll: () => Navigator.pushNamed(context, RouteNames.explore),
              ),

              const SizedBox(height: 14),

              // Recommended Careers Horizontal Cards (Real-time Firestore)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('careers').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const AppEmptyState(
                        title: 'No careers available yet',
                        message: 'Careers created by admin will appear here dynamically.',
                      ),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 224,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final item = doc.data();
                            final title = item['title'] as String? ?? 'Career';
                            final description = item['description'] as String? ?? '';
                            final category = item['category'] as String? ?? 'General';
                            final image = item['image'] as String? ??
                                'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?q=80&w=600&auto=format&fit=crop';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.careerDetails,
                                  arguments: doc.id,
                                );
                              },
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.borderDark, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                          child: Image.network(
                                            image,
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 100,
                                              color: const Color(0xFF262836),
                                              child: const Icon(Icons.work_outline_rounded, color: Colors.white54),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Saved to Bookmarks'),
                                                  backgroundColor: AppColors.primary,
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.bookmark_border_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: AppTypography.titleMedium.copyWith(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.textMutedDark,
                                              fontSize: 11,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(docs.length.clamp(0, 5), (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: index == _activeCareerIndex ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == _activeCareerIndex ? AppColors.primary : AppColors.borderDark,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 26),

              // Upcoming Deadlines Header
              _buildSectionHeader(
                title: 'Upcoming deadlines',
                onSeeAll: () => Navigator.pushNamed(context, RouteNames.applications),
              ),

              const SizedBox(height: 14),

              // Upcoming Deadlines Real-time Firestore Stream
              Builder(
                builder: (context) {
                  final userId = user?.id;
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: (userId == null || userId.isEmpty)
                        ? null
                        : (authProvider.currentUser?.role == 'admin'
                            ? FirebaseFirestore.instance.collection('applications').snapshots()
                            : FirebaseFirestore.instance
                                .collection('applications')
                                .where('userId', isEqualTo: userId)
                                .snapshots()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        );
                      }

                      final docs = (snapshot.data?.docs ?? []).where((doc) {
                        final data = doc.data();
                        return userId == null || data['userId'] == userId;
                      }).toList();

                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const AppEmptyState(
                        title: 'No upcoming deadlines',
                        message: 'Your active deadlines will appear here once you apply.',
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data();
                      final title = data['title'] as String? ?? data['careerTitle'] as String? ?? 'Application';
                      final subtitle = data['company'] as String? ?? data['organization'] as String? ?? 'Skillora';
                      final Timestamp? deadlineTs = data['deadlineDate'] as Timestamp? ?? data['deadline'] as Timestamp?;

                      String badgeText = 'Active';
                      bool isDanger = false;
                      if (deadlineTs != null) {
                        final diff = deadlineTs.toDate().difference(DateTime.now()).inDays;
                        if (diff < 0) {
                          badgeText = 'Closed';
                          isDanger = true;
                        } else {
                          badgeText = '${diff}d left';
                          isDanger = diff <= 7;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderDark, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPurpleBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textMutedDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDanger ? const Color(0x2EEF4444) : AppColors.pastelPurpleBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badgeText,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDanger ? const Color(0xFFF87171) : AppColors.pastelPurpleText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),

              const SizedBox(height: 26),

              // Mentors For You Header
              _buildSectionHeader(
                title: 'Mentors for you',
                onSeeAll: () => Navigator.pushNamed(context, RouteNames.explore),
              ),

              const SizedBox(height: 14),

              // Mentors Avatars Row (Real-time Firestore Stream)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const AppEmptyState(
                        title: 'No mentors available',
                        message: 'Mentors added by admin will appear here.',
                      ),
                    );
                  }

                  return SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final mentor = docs[index].data();
                        final name = mentor['name'] as String? ?? 'Mentor';
                        final role = mentor['title'] as String? ?? mentor['bio'] as String? ?? 'Advisor';
                        final avatar = mentor['avatarUrl'] as String? ??
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&auto=format&fit=crop';

                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.surfaceDark,
                              backgroundImage: NetworkImage(avatar),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              role,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMutedDark,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}