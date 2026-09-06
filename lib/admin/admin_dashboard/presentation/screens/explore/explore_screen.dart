import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['All', 'Deadline Soon', 'Saved'];

  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Women in Tech Grant',
      'subtitle': 'Google Techmakers',
      'value': '\$10,000 / Full Grant',
      'category': 'Scholarship',
      'accentColor': AppColors.pastelMintText,
      'isSaved': true,
      'isDeadlineSoon': true,
    },
    {
      'title': 'Full-Stack AI Pathway',
      'subtitle': 'Skillora Academy',
      'value': '12 Weeks • Certified',
      'category': 'Featured Course',
      'accentColor': AppColors.pastelOrangeText,
      'isSaved': false,
      'isDeadlineSoon': false,
    },
    {
      'title': 'UX Research Fellowship',
      'subtitle': 'Meta Design Lab',
      'value': '\$7,500 / Stipend',
      'category': 'Fellowship',
      'accentColor': AppColors.pastelPinkText,
      'isSaved': true,
      'isDeadlineSoon': true,
    },
    {
      'title': 'Cloud Architecture Grant',
      'subtitle': 'AWS Education',
      'value': '8 Weeks • Advanced',
      'category': 'Course Grant',
      'accentColor': AppColors.pastelBlueText,
      'isSaved': false,
      'isDeadlineSoon': false,
    },
    {
      'title': 'Data Science Leader Grant',
      'subtitle': 'Microsoft Learn',
      'value': '\$5,000 / Grant',
      'category': 'Scholarship',
      'accentColor': AppColors.pastelMintText,
      'isSaved': false,
      'isDeadlineSoon': true,
    },
    {
      'title': 'Cybersecurity Bootcamp',
      'subtitle': 'Cloudflare Institute',
      'value': '10 Weeks • Intensive',
      'category': 'Bootcamp',
      'accentColor': AppColors.pastelOrangeText,
      'isSaved': true,
      'isDeadlineSoon': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final title = item['title'].toString().toLowerCase();
      final subtitle = item['subtitle'].toString().toLowerCase();
      final matchesSearch = query.isEmpty || title.contains(query) || subtitle.contains(query);

      if (!matchesSearch) return false;

      if (_selectedFilterIndex == 1) {
        return item['isDeadlineSoon'] == true;
      } else if (_selectedFilterIndex == 2) {
        return item['isSaved'] == true;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Opportunities',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hi, Maida',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ],
                  ),

                  // Avatar photo with thin white ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFE2E8F0),
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=256&auto=format&fit=crop',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar: White Pill, Light Gray Border, Search Icon Left, Filter Icon Right
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.headingDark,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search scholarships or courses...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMutedLight,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Open Filter Modal / Options
                      },
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips Row ("All", "Deadline Soon", "Saved")
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedFilterIndex;
                    final label = _filters[index];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Section Title
              Text(
                'Browse Opportunities',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              const SizedBox(height: 16),

              // 2-Column Grid of White Rounded Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final accentColor = item['accentColor'] as Color;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0E000000),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Small Colored Top Accent Bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Tag
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['category'] as String,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: accentColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    item['isSaved'] == true
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 18,
                                    color: item['isSaved'] == true
                                        ? AppColors.primary
                                        : AppColors.textMutedLight,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Title in Bold
                              Text(
                                item['title'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingDark,
                                  height: 1.25,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Short Muted Subtitle
                              Text(
                                item['subtitle'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Bold Amount or Duration at the Bottom
                              Text(
                                item['value'] as String,
                                style: AppTypography.labelLarge.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}