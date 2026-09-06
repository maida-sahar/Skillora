import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

enum ApplicationStatus { accepted, inReview, actionNeeded }

class CareerApplicationItem {
  final String roleName;
  final String companyName;
  final String dateLine;
  final ApplicationStatus status;
  final IconData icon;
  final Color iconBadgeBg;
  final Color iconBadgeColor;

  const CareerApplicationItem({
    required this.roleName,
    required this.companyName,
    required this.dateLine,
    required this.status,
    required this.icon,
    required this.iconBadgeBg,
    required this.iconBadgeColor,
  });
}

class CareerApplicationsListScreen extends StatefulWidget {
  const CareerApplicationsListScreen({super.key});

  @override
  State<CareerApplicationsListScreen> createState() => _CareerApplicationsListScreenState();
}

class _CareerApplicationsListScreenState extends State<CareerApplicationsListScreen> {
  final List<CareerApplicationItem> _applications = const [
    CareerApplicationItem(
      roleName: 'Senior Frontend Developer',
      companyName: 'Stripe Inc. • Full-time',
      dateLine: 'Applied: April 18 • Decision Due: April 30',
      status: ApplicationStatus.accepted,
      icon: Icons.code_rounded,
      iconBadgeBg: AppColors.pastelMintBg,
      iconBadgeColor: AppColors.pastelMintText,
    ),
    CareerApplicationItem(
      roleName: 'Product Design Lead',
      companyName: 'Linear • Remote',
      dateLine: 'Applied: April 15 • Review Stage 2',
      status: ApplicationStatus.inReview,
      icon: Icons.palette_rounded,
      iconBadgeBg: AppColors.pastelOrangeBg,
      iconBadgeColor: AppColors.pastelOrangeText,
    ),
    CareerApplicationItem(
      roleName: 'AI & Data Science Fellowship',
      companyName: 'Google Techmakers Grant',
      dateLine: 'Submitted: April 12 • Portfolio Verification Needed',
      status: ApplicationStatus.actionNeeded,
      icon: Icons.auto_awesome_rounded,
      iconBadgeBg: AppColors.pastelPinkBg,
      iconBadgeColor: AppColors.pastelPinkText,
    ),
    CareerApplicationItem(
      roleName: 'Full-Stack Software Engineer',
      companyName: 'Vercel • Contract',
      dateLine: 'Applied: April 10 • Final Interview Scheduled',
      status: ApplicationStatus.accepted,
      icon: Icons.terminal_rounded,
      iconBadgeBg: AppColors.pastelBlueBg,
      iconBadgeColor: AppColors.pastelBlueText,
    ),
    CareerApplicationItem(
      roleName: 'Cybersecurity Analyst Internship',
      companyName: 'Cloudflare • Summer 2026',
      dateLine: 'Applied: April 08 • Assessment Completed',
      status: ApplicationStatus.inReview,
      icon: Icons.security_rounded,
      iconBadgeBg: AppColors.pastelOrangeBg,
      iconBadgeColor: AppColors.pastelOrangeText,
    ),
  ];

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
              // Top Bar Header (Greeting + Search Icon + Avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting Left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
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

                  // Search Icon & Avatar Top Right
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.headingDark,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(width: 10),

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
                ],
              ),

              const SizedBox(height: 24),

              // Section Header with "View all" link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Career Applications',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View all',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Vertical List of White Rounded Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _applications[index];
                  return _buildApplicationCard(item);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(CareerApplicationItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small colored icon badge matching stat-tile palette
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.iconBadgeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconBadgeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Role & Company Name in Bold
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.roleName,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.companyName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Pill (Teal = Accepted, Orange = In Review, Pink = Action Needed)
              _buildStatusPill(item.status),
            ],
          ),

          const SizedBox(height: 14),

          // Divider line accent
          Divider(color: const Color(0xFFF1F5F9), height: 1),

          const SizedBox(height: 10),

          // Due-date / Date line underneath in gray
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.textMutedLight,
              ),
              const SizedBox(width: 6),
              Text(
                item.dateLine,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(ApplicationStatus status) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case ApplicationStatus.accepted:
        label = 'Accepted';
        bgColor = AppColors.pastelMintBg;
        textColor = AppColors.pastelMintText;
        break;
      case ApplicationStatus.inReview:
        label = 'In Review';
        bgColor = AppColors.pastelOrangeBg;
        textColor = AppColors.pastelOrangeText;
        break;
      case ApplicationStatus.actionNeeded:
        label = 'Action Needed';
        bgColor = AppColors.pastelPinkBg;
        textColor = AppColors.pastelPinkText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
