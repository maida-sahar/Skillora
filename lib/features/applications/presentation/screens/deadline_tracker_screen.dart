import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

class DeadlineTrackerScreen extends StatefulWidget {
  const DeadlineTrackerScreen({super.key});

  @override
  State<DeadlineTrackerScreen> createState() => _DeadlineTrackerScreenState();
}

class _DeadlineTrackerScreenState extends State<DeadlineTrackerScreen> {
  int _selectedDayIndex = 3; // 24 Thu (default selected)
  String _currentMonth = 'April';

  final List<Map<String, String>> _days = [
    {'day': '21', 'weekday': 'Mon'},
    {'day': '22', 'weekday': 'Tue'},
    {'day': '23', 'weekday': 'Wed'},
    {'day': '24', 'weekday': 'Thu'},
    {'day': '25', 'weekday': 'Fri'},
    {'day': '26', 'weekday': 'Sat'},
    {'day': '27', 'weekday': 'Sun'},
  ];

  final List<Map<String, dynamic>> _ongoingTasks = [
    {
      'title': 'Frontend Frameworks Certification',
      'category': 'Skillora Skill Benchmark',
      'timeRange': '10:00 AM - 12:30 PM • Due Today',
      'bgColor': const Color(0xFFFFF7ED),
      'borderColor': const Color(0xFFFFEDD5),
      'accentColor': const Color(0xFFEA580C),
      'icon': Icons.code_rounded,
      'avatars': [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=128&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=128&auto=format&fit=crop',
      ],
      'extraCount': '+2 mentors',
    },
    {
      'title': 'Google Women Techmakers Scholarship',
      'category': 'Scholarship Grant Application',
      'timeRange': 'Due April 26, 2026 • 11:59 PM',
      'bgColor': const Color(0xFFF0F9FF),
      'borderColor': const Color(0xFFE0F2FE),
      'accentColor': const Color(0xFF0284C7),
      'icon': Icons.school_rounded,
      'avatars': [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=128&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=128&auto=format&fit=crop',
      ],
      'extraCount': '+4 reviewers',
    },
    {
      'title': 'UI/UX Portfolio Peer Review',
      'category': 'Mentorship Feedback Session',
      'timeRange': '03:00 PM - 04:30 PM • Due April 28',
      'bgColor': const Color(0xFFFDF2F8),
      'borderColor': const Color(0xFFFCE7F3),
      'accentColor': const Color(0xFFDB2777),
      'icon': Icons.palette_rounded,
      'avatars': [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=128&auto=format&fit=crop',
      ],
      'extraCount': '+1 peer',
    },
    {
      'title': 'Cybersecurity Fundamentals Assessment',
      'category': 'Skill Pathway Final Exam',
      'timeRange': 'Due April 30, 2026 • 06:00 PM',
      'bgColor': const Color(0xFFE6FFFA),
      'borderColor': const Color(0xFFCCFBF1),
      'accentColor': const Color(0xFF0D9488),
      'icon': Icons.shield_rounded,
      'avatars': [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=128&auto=format&fit=crop',
      ],
      'extraCount': '+3 leads',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Header (Back Arrow, Centered Month with Chevrons, Top-Right Avatar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.headingDark,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),

                  // Month Name Centered ("April") with Left/Right Chevrons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentMonth == 'April') {
                              _currentMonth = 'March';
                            } else {
                              _currentMonth = 'April';
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.headingDark,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentMonth,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_currentMonth == 'April') {
                              _currentMonth = 'May';
                            } else {
                              _currentMonth = 'April';
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.headingDark,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  // Avatar top-right with thin white ring
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
                      radius: 18,
                      backgroundColor: Color(0xFFE2E8F0),
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=256&auto=format&fit=crop',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal Scrollable Row of Day Chips
            SizedBox(
              height: 76,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  final dayItem = _days[index];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 54,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(isSelected ? 24 : 16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                        border: isSelected
                            ? null
                            : Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayItem['day']!,
                            style: AppTypography.titleMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.headingDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dayItem['weekday']!,
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppColors.textSecondaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Section Header "Ongoing" & Task List
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ongoing',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_ongoingTasks.length} Deadlines',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vertical List of Colored Deadline/Task Cards
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _ongoingTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final task = _ongoingTasks[index];
                          final bgColor = task['bgColor'] as Color;
                          final borderColor = task['borderColor'] as Color;
                          final accentColor = task['accentColor'] as Color;
                          final avatars = task['avatars'] as List<String>;
                          final extraCount = task['extraCount'] as String;

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x0C000000),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        task['icon'] as IconData,
                                        color: accentColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task['title'] as String,
                                            style: AppTypography.titleMedium.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.headingDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            task['category'] as String,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: accentColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Row of small avatar icons
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: (avatars.length * 18 + 14).toDouble(),
                                          height: 26,
                                          child: Stack(
                                            children: List.generate(avatars.length, (i) {
                                              return Positioned(
                                                left: i * 18.5,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 11,
                                                    backgroundImage: NetworkImage(avatars[i]),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          extraCount,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondaryLight,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Time/Date Range underneath in smaller text
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task['timeRange'] as String,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.headingDark.withValues(alpha: 0.85),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
