import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'In progress', 'Submitted', 'Closed'];

  Stream<QuerySnapshot<Map<String, dynamic>>>? _applicationsStream;
  String? _lastStreamUserId;
  bool? _lastIsAdmin;

  void _initStreamIfNeeded(String? userId, bool isAdmin) {
    if (userId == null || userId.isEmpty) return;
    if (_applicationsStream != null && _lastStreamUserId == userId && _lastIsAdmin == isAdmin) {
      return;
    }
    _lastStreamUserId = userId;
    _lastIsAdmin = isAdmin;
    if (isAdmin) {
      _applicationsStream = FirebaseFirestore.instance.collection('applications').snapshots();
    } else {
      _applicationsStream = FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }
  }

  void _retryFetch(String? userId, bool isAdmin) {
    setState(() {
      _applicationsStream = null;
      _lastStreamUserId = null;
      _lastIsAdmin = null;
      _initStreamIfNeeded(userId, isAdmin);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUserId = authProvider.currentUser?.id ?? firebaseUser?.uid;
    final currentUserEmail = authProvider.currentUser?.email ?? firebaseUser?.email;
    final isAdmin = authProvider.currentUser?.role == 'admin';

    _initStreamIfNeeded(currentUserId, isAdmin);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouteNames.explore),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Notification Icon
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
                        'Applications',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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

              const SizedBox(height: 18),

              // Filter Tabs Header [ All | In progress | Submitted | Closed ]
              Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = index == _selectedTabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tabs[index],
                            style: AppTypography.titleMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textMutedDark,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: isSelected ? 20 : 0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Applications Cards Real-time Firestore Stream
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _applicationsStream,
                builder: (context, snapshot) {
                  if ((currentUserId == null || currentUserId.isEmpty) && authProvider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: AppEmptyState(
                        title: 'Unable to load applications',
                        message: 'Error fetching records from backend: ${snapshot.error}',
                        fallbackIcon: Icons.cloud_off_rounded,
                        actionText: 'Try Again',
                        onActionPressed: () => _retryFetch(currentUserId, isAdmin),
                      ),
                    );
                  }

                  final allDocs = (snapshot.data?.docs ?? []).where((doc) {
                    final data = doc.data();
                    final docUserId = (data['userId'] ?? data['uid'] ?? data['user_id'] ?? data['studentId'] ?? '').toString();
                    final docEmail = (data['userEmail'] ?? data['email'] ?? '').toString();

                    if (authProvider.currentUser?.role == 'admin') return true;

                    if (currentUserId != null && currentUserId.isNotEmpty) {
                      if (docUserId == currentUserId) return true;
                      if (currentUserEmail != null &&
                          currentUserEmail.isNotEmpty &&
                          docEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
                        return true;
                      }
                      return false;
                    }
                    return true;
                  }).toList();

                  final selectedTab = _tabs[_selectedTabIndex];

                  final filteredDocs = allDocs.where((doc) {
                    if (_selectedTabIndex == 0) return true; // 'All' tab returns all user applications
                    final status = (doc.data()['status'] ?? '').toString().toLowerCase();
                    if (selectedTab == 'In progress') {
                      return status.contains('progress') ||
                          status.contains('preparing') ||
                          status.contains('review') ||
                          status.contains('applied') ||
                          status == 'in progress';
                    }
                    if (selectedTab == 'Submitted') {
                      return status.contains('submitted') || status.contains('applied');
                    }
                    if (selectedTab == 'Closed') {
                      return status.contains('closed') || status.contains('accepted') || status.contains('rejected');
                    }
                    return true;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: AppEmptyState(
                        title: 'No applications found',
                        message: 'Tracked applications will appear here automatically when you apply.',
                        fallbackIcon: Icons.assignment_outlined,
                        actionText: 'Browse Opportunities',
                        onActionPressed: () => Navigator.pushNamed(context, RouteNames.explore),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final app = filteredDocs[index].data();
                      final title = app['title'] as String? ?? app['careerTitle'] as String? ?? 'Application';
                      final location = app['location'] as String? ?? app['company'] as String? ?? 'Skillora';
                      final statusLabel = app['status'] as String? ?? 'In Progress';
                      final Timestamp? deadlineTs = app['deadlineDate'] as Timestamp? ?? app['deadline'] as Timestamp?;

                      String deadlineTag = 'Active';
                      bool isClosed = false;
                      if (deadlineTs != null) {
                        final diff = deadlineTs.toDate().difference(DateTime.now()).inDays;
                        if (diff < 0) {
                          deadlineTag = 'Closed';
                          isClosed = true;
                        } else {
                          deadlineTag = '${diff}d left';
                        }
                      }

                      double percent = (app['progress'] as num?)?.toDouble() ?? 0.5;
                      Color progressColor = AppColors.primary;
                      Color badgeBg = AppColors.pastelPurpleBg;
                      Color badgeText = AppColors.pastelPurpleText;

                      if (statusLabel.contains('Submitted') || statusLabel.contains('Applied')) {
                        percent = 1.0;
                        progressColor = const Color(0xFF10B981);
                        badgeBg = const Color(0x1F10B981);
                        badgeText = const Color(0xFF34D399);
                      } else if (statusLabel.contains('Accepted')) {
                        percent = 1.0;
                        progressColor = const Color(0xFF3B82F6);
                        badgeBg = const Color(0x1F3B82F6);
                        badgeText = const Color(0xFF60A5FA);
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderDark, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Organization/Title & Deadline Tag
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isClosed
                                        ? AppColors.surfaceDark
                                        : const Color(0x2EEF4444),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isClosed
                                        ? Border.all(color: AppColors.borderDark)
                                        : null,
                                  ),
                                  child: Text(
                                    deadlineTag,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isClosed
                                          ? AppColors.textMutedDark
                                          : const Color(0xFFF87171),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Text(
                              location,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMutedDark,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Custom Rounded Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF262836),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: percent,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Progress Step Description & Percent Value
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  statusLabel,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textMutedDark,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${(percent * 100).toInt()}%',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Status Badge Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTypography.labelSmall.copyWith(
                                  color: badgeText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
