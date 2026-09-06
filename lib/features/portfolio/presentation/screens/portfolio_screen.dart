import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/loaders/app_shimmer.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<PortfolioProvider>(context, listen: false).fetchUserPortfolio(user.id);
      }
    });
  }

  void _showAddProjectDialog(BuildContext context, String userId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final linkController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final selectedBytes = portfolioProvider.selectedImageBytes;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Portfolio Project',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: portfolioProvider.isLoading
                        ? null
                        : () async {
                            final ok = await portfolioProvider.pickImage(ImageSource.gallery);
                            if (!ok && portfolioProvider.errorMessage != null && ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(portfolioProvider.errorMessage!),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softBlueDark),
                      ),
                      child: selectedBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(selectedBytes, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to pick project screenshot / cover',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Project Title',
                    hint: 'e.g. Skillora Mobile App',
                    controller: titleController,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Description',
                    hint: 'Describe key features, tools, & outcomes...',
                    controller: descriptionController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Project Link (Optional)',
                    hint: 'https://github.com/my-project',
                    controller: linkController,
                    prefixIcon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Upload & Add to Portfolio',
                    isLoading: portfolioProvider.isLoading,
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill title and description.')),
                        );
                        return;
                      }

                      final success = await portfolioProvider.createPortfolioItem(
                        userId: userId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        projectUrl: linkController.text.trim().isNotEmpty ? linkController.text.trim() : null,
                      );

                      if (success && ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Project uploaded successfully!'), backgroundColor: AppColors.success),
                        );
                      } else if (!success && ctx.mounted && portfolioProvider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(portfolioProvider.errorMessage!), backgroundColor: AppColors.error),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not authenticated.')));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('Portfolio Showcase', style: AppTypography.titleLarge)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context, user.id),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Project', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
      ),
      body: portfolioProvider.isLoading && portfolioProvider.items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: AppShimmerCardList(itemCount: 3, cardHeight: 180),
            )
          : portfolioProvider.items.isEmpty
              ? AppEmptyState(
                  title: 'No Portfolio Projects Added Yet',
                  message: 'Showcase your work, projects, and certifications by adding them to your portfolio.',
                  lottieAsset: 'assets/animations/empty_data.json',
                  fallbackIcon: Icons.folder_open_outlined,
                  actionText: 'Add Project',
                  onActionPressed: () => _showAddProjectDialog(context, user.id),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: portfolioProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = portfolioProvider.items[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              item.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 180,
                                color: AppColors.softBlue,
                                child: const Icon(Icons.broken_image, size: 48, color: AppColors.textMutedLight),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (item.projectUrl != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.projectUrl!,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
