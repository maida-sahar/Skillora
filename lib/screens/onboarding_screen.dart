import 'package:flutter/material.dart';
import '../config/routes/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../shared/widgets/buttons/custom_button.dart';
import '../shared/widgets/illustrations/isometric_career_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'headline': 'Build Your\nCareer Story',
      'subtitle': 'Track your skill progress, earn verified credentials, and accelerate your professional growth with Skillora.',
      'buttonText': 'Get Started',
      'illustration': IsometricIllustrationType.careerGrowth,
    },
    {
      'headline': 'Master In-Demand\nDigital Skills',
      'subtitle': 'Explore curated learning pathways and receive real-time intelligence on your job market readiness.',
      'buttonText': 'Explore Pathways',
      'illustration': IsometricIllustrationType.skillTree,
    },
    {
      'headline': 'Unlock Verified\nCertificates & Rewards',
      'subtitle': 'Showcase your portfolio, claim scholarships, and connect with top tech employers.',
      'buttonText': 'Start My Journey',
      'illustration': IsometricIllustrationType.certificateLaptop,
    },
  ];

  void _onFinish() {
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Top Two-Thirds: Rich Purple Gradient Hero Card with 3D Isometric Art
            Expanded(
              flex: 6, // ~60-66% top portion
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 44, 16, 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Header Logo Accent (Top Left)
                      Positioned(
                        top: 20,
                        left: 24,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Skillora',
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PageView for 3D Isometric Illustrations
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                            child: IsometricCareerIllustration(
                              type: slide['illustration'] as IsometricIllustrationType,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Third: White Background Content & Actions
            Expanded(
              flex: 4, // ~34-40% bottom portion
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Small Page Indicator Dots Above Headline
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Bold 2-Line Headline
                        Text(
                          _slides[_currentPage]['headline']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: AppColors.headingDark,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Short Muted-Gray Subtitle Sentence
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _slides[_currentPage]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Full-Width Purple Gradient Pill Button ("Get Started")
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomButton(
                        text: _slides[_currentPage]['buttonText']!,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _onFinish();
                          }
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
