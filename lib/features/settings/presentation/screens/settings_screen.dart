import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user != null) ...[
              AppCard(
                onTap: () => Navigator.pushNamed(context, RouteNames.profile),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.lavenderSoft,
                      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                              style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: AppTypography.titleMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              'Preferences & Notifications',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: Text('In-App Notifications', style: AppTypography.bodyMedium),
                    subtitle: Text('Receive application & deadline updates', style: AppTypography.bodySmall),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Account & Services',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    title: Text('Account & Security', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                    onTap: () => Navigator.pushNamed(context, RouteNames.forgotPassword),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.folder_open_outlined, color: AppColors.primary),
                    title: Text('My Uploaded Documents', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                    onTap: () => Navigator.pushNamed(context, RouteNames.documents),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: Text('Help & Customer Support', style: AppTypography.bodyMedium),
                    subtitle: Text('FAQs, Contact Support', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Skillora Support', style: AppTypography.titleLarge),
                          content: Text('For assistance, email support@skillora.app or visit our website.', style: AppTypography.bodyMedium),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text('Sign Out', style: AppTypography.titleMedium.copyWith(color: AppColors.error)),
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
