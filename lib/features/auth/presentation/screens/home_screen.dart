import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/pastel_stat_tile.dart';
import '../../../../config/routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date, Greeting, and Deadlines
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monday, 25 October',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hi, Maida',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.headingDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '3 deadlines this week',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Search Icon & Circular Avatar Top Right
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Open search dialog / route
                        },
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.headingDark,
                          size: 24,
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
                          radius: 20,
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

              // Featured Purple Gradient Hero Card (Top Priority)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.heroCardGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Tag "New"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'New Priority',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.bookmark_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Top Priority Title
                    Text(
                      'Skill Assessment: Frontend Development',
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      'Complete your assessment to earn your verified proficiency badge.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Row of overlapping avatar circles & action button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Overlapping Avatars
                        Row(
                          children: [
                            SizedBox(
                              width: 72,
                              height: 30,
                              child: Stack(
                                children: const [
                                  Positioned(
                                    left: 0,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=128&auto=format&fit=crop',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=128&auto=format&fit=crop',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 36,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=128&auto=format&fit=crop',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+4 peers enrolled',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        // Start Assessment CTA
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pushNamed(RouteNames.skillAssessment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Start',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section Header "Monthly Overview"
              Text(
                'Monthly Overview',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              const SizedBox(height: 16),

              // 2x2 Grid of Colored Stat Tiles
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  // Teal Tile: "22 / Skills Completed"
                  PastelStatTile(
                    value: '22',
                    label: 'Skills Completed',
                    icon: Icons.check_circle_outline_rounded,
                    variant: PastelTileVariant.mint,
                    onTap: () {},
                  ),

                  // Orange Tile: "7 / In Progress"
                  PastelStatTile(
                    value: '7',
                    label: 'In Progress',
                    icon: Icons.timelapse_rounded,
                    variant: PastelTileVariant.orange,
                    onTap: () {},
                  ),

                  // Pink Tile: "12 / Applications Sent"
                  PastelStatTile(
                    value: '12',
                    label: 'Applications Sent',
                    icon: Icons.send_rounded,
                    variant: PastelTileVariant.pink,
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.applications),
                  ),

                  // Sky Blue Tile: "14 / Awaiting Review"
                  PastelStatTile(
                    value: '14',
                    label: 'Awaiting Review',
                    icon: Icons.hourglass_top_rounded,
                    variant: PastelTileVariant.blue,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}