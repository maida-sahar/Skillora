import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../shared/widgets/empty_state_widget.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  int _selectedFieldIndex = 0;

  final List<String> _categories = ['Careers', 'Scholarships', 'Mentors'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _currentCollectionName {
    switch (_selectedCategoryIndex) {
      case 1:
        return 'scholarships';
      case 2:
        return 'mentors';
      case 0:
      default:
        return 'careers';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUserId = authProvider.currentUser?.id ?? firebaseUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title & Notification Icon
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
                        'Explore',
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

              // Search Bar
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
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search careers, skills or keywords...',
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

              const SizedBox(height: 20),

              // Category Switcher Pills [ Careers | Scholarships | Mentors ]
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark, width: 1),
                ),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategoryIndex = index;
                          _selectedFieldIndex = 0; // Reset to 'All fields' when switching section
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _categories[index],
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textMutedDark,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Real-time Stream for User Saved Items (State Source of Truth)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('saved_items')
                    .where('userId', isEqualTo: currentUserId ?? '')
                    .snapshots(),
                builder: (context, savedSnapshot) {
                  final Map<String, String> savedItemMap = {};
                  if (savedSnapshot.hasData && savedSnapshot.data != null) {
                    for (final doc in savedSnapshot.data!.docs) {
                      final data = doc.data();
                      final itemDocId = data['itemDocId'] as String?;
                      if (itemDocId != null) {
                        savedItemMap[itemDocId] = doc.id;
                      }
                    }
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection(_currentCollectionName).snapshots(),
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final query = _searchController.text.trim().toLowerCase();

                  // Dynamically extract categories from Firestore documents
                  final Set<String> extractedFields = {'STEM', 'Business', 'Design', 'Technology', 'Marketing'};
                  for (final doc in allDocs) {
                    final data = doc.data();
                    final cat = (data['category'] ?? data['field'] ?? '').toString().trim();
                    if (cat.isNotEmpty) {
                      extractedFields.add(cat);
                    }
                  }

                  final List<String> fields = ['All fields', ...extractedFields.toList()];
                  if (_selectedFieldIndex >= fields.length) {
                    _selectedFieldIndex = 0;
                  }
                  final selectedField = fields[_selectedFieldIndex];
                  final isAllFields = _selectedFieldIndex == 0 || selectedField.trim().toLowerCase() == 'all fields';

                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? data['name'] ?? '').toString().toLowerCase();
                    final desc = (data['description'] ?? data['bio'] ?? data['organization'] ?? '').toString().toLowerCase();
                    final category = (data['category'] ?? data['field'] ?? '').toString().trim();

                    final matchesQuery = query.isEmpty || title.contains(query) || desc.contains(query);
                    if (!matchesQuery) return false;

                    if (isAllFields) {
                      return true; // All fields shows everything
                    }

                    if (category.isEmpty) {
                      return false; // Items without fields only appear under 'All fields'
                    }

                    final normalizedItemCat = category.toLowerCase();
                    final normalizedSelField = selectedField.trim().toLowerCase();

                    return normalizedItemCat == normalizedSelField ||
                        normalizedItemCat.contains(normalizedSelField) ||
                        normalizedSelField.contains(normalizedItemCat);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field Filters Chips [ All fields | STEM | Business | ... ]
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: fields.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedFieldIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedFieldIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(18),
                                  border: isSelected
                                      ? null
                                      : Border.all(color: AppColors.borderDark, width: 1),
                                ),
                                child: Text(
                                  fields[index],
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textMutedDark,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Progress indicator slider line
                      Container(
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_selectedCategoryIndex + 1) / _categories.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (filteredDocs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: AppEmptyState(
                            title: 'No ${_categories[_selectedCategoryIndex].toLowerCase()} found',
                            message: isAllFields
                                ? 'No records have been created by admin yet.'
                                : 'No records matching field "$selectedField" were found.',
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredDocs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data();
                      final title = data['title'] as String? ?? data['name'] as String? ?? 'Opportunity';
                      final description = data['description'] as String? ?? data['bio'] as String? ?? data['organization'] as String? ?? '';
                      final image = data['image'] as String? ?? data['avatarUrl'] as String? ??
                          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=400&auto=format&fit=crop';
                      final category = data['category'] as String? ?? data['field'] as String? ?? 'General';
                      final level = data['careerLevel'] as String? ?? data['amount']?.toString() ?? 'Active';

                      String targetRoute = RouteNames.careerDetails;
                      if (_selectedCategoryIndex == 1) {
                        targetRoute = RouteNames.scholarshipDetails;
                      } else if (_selectedCategoryIndex == 2) {
                        targetRoute = RouteNames.mentorDetails;
                      }

                      final isSaved = savedItemMap.containsKey(doc.id);
                      final savedDocId = savedItemMap[doc.id];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            targetRoute,
                            arguments: doc.id,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderDark, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Thumbnail Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  image,
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 78,
                                    height: 78,
                                    color: const Color(0xFF262836),
                                    child: const Icon(Icons.work_outline_rounded, color: Colors.white54),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Center Details & Right Bookmark
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
                                        GestureDetector(
                                          onTap: () async {
                                            final firebaseUser = FirebaseAuth.instance.currentUser;
                                            final activeUid = firebaseUser?.uid ?? currentUserId;
                                            if (firebaseUser == null || activeUid == null || activeUid.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please sign in to save items'),
                                                  backgroundColor: AppColors.error,
                                                ),
                                              );
                                              return;
                                            }

                                            if (isSaved) {
                                              // UNSAVE: Remove from Firestore
                                              try {
                                                if (savedDocId != null) {
                                                  await FirebaseFirestore.instance
                                                      .collection('saved_items')
                                                      .doc(savedDocId)
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
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Failed to remove: $e'),
                                                      backgroundColor: AppColors.error,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              // SAVE: Create record in Firestore
                                              try {
                                                final activeUid = FirebaseAuth.instance.currentUser?.uid ?? currentUserId;
                                                await FirebaseFirestore.instance.collection('saved_items').add({
                                                  'userId': activeUid,
                                                  'itemDocId': doc.id,
                                                  'title': title,
                                                  'description': description,
                                                  'image': image,
                                                  'category': category,
                                                  'level': level,
                                                  'targetRoute': targetRoute,
                                                  'createdAt': FieldValue.serverTimestamp(),
                                                });
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Saved to Bookmarks'),
                                                      backgroundColor: AppColors.primary,
                                                      duration: Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Failed to save item: $e'),
                                                      backgroundColor: AppColors.error,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: Icon(
                                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                            size: 22,
                                            color: isSaved ? AppColors.primary : AppColors.textMutedDark,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      description,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textMutedDark,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 10),

                                    // Category Tag Row
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
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
                  ),
                ],
              );
            },
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
}