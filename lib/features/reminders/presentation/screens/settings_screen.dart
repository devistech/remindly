import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/reminder_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n?.settings ?? 'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n?.chooseLanguage ?? 'Language'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  title: 'English',
                  subtitle: 'English',
                  languageCode: 'en',
                  isSelected: currentLanguage == 'en',
                ),
                const Divider(height: 1),
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  title: 'हिंदी',
                  subtitle: 'Hindi',
                  languageCode: 'hi',
                  isSelected: currentLanguage == 'hi',
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n?.about ?? 'About'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: l10n?.version ?? 'Version',
                  subtitle: '1.0.0',
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  icon: Icons.star_outline_rounded,
                  title: l10n?.rateApp ?? 'Rate App',
                  subtitle: l10n?.rateAppSubtitle ?? 'Rate us on Play Store',
                  onTap: () => _launchPlayStore(context),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n?.privacyPolicy ?? 'Privacy Policy',
                  subtitle: l10n?.privacyPolicySubtitle ?? 'Read our privacy policy',
                  onTap: () => _launchPrivacyPolicy(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n?.data ?? 'Data'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.delete_outline_rounded,
                  title: l10n?.clearAllData ?? 'Clear All Data',
                  subtitle: l10n?.clearAllDataSubtitle ?? 'Delete all reminders and settings',
                  titleColor: AppColors.overdue,
                  onTap: () => _showClearDataDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.financial,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.appName ?? 'Remindly',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.appTagline ?? 'Smart Life Reminder',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPlayStore(BuildContext context) async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.devis.remindly');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('https://devistech.github.io/Privacy-Policy/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(languageCode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.financial,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.financial).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: titleColor ?? AppColors.financial,
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
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n?.clearAllData ?? 'Clear All Data'),
        content: Text(
          l10n?.clearAllDataConfirm ?? 'This will delete all your reminders and reset settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              ref.read(allRemindersProvider.notifier).clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n?.allDataCleared ?? 'All data cleared')),
                );
              }
            },
            child: Text(
              l10n?.clear ?? 'Clear',
              style: const TextStyle(color: AppColors.overdue),
            ),
          ),
        ],
      ),
    );
  }
}
