import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/reminder_providers.dart';
import 'category_reminders_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allReminders = ref.watch(allRemindersProvider);

    // Count reminders by category
    final categoryCounts = <String, int>{};
    for (final reminder in allReminders) {
      categoryCounts[reminder.category] = (categoryCounts[reminder.category] ?? 0) + 1;
    }

    final categories = [
      {
        'title': l10n?.financial ?? 'Financial',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppColors.financial,
        'templates': AppConstants.financialTemplates,
      },
      {
        'title': l10n?.subscriptions ?? 'Subscriptions',
        'icon': Icons.subscriptions_rounded,
        'color': AppColors.subscription,
        'templates': AppConstants.subscriptionTemplates,
      },
      {
        'title': l10n?.personal ?? 'Personal',
        'icon': Icons.person_rounded,
        'color': AppColors.personal,
        'templates': AppConstants.personalTemplates,
      },
      {
        'title': l10n?.utility ?? 'Utility',
        'icon': Icons.build_rounded,
        'color': AppColors.utility,
        'templates': AppConstants.utilityTemplates,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n?.categories ?? 'Categories',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.financial,
                  AppColors.financial.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.totalReminders ?? 'Total Reminders',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${allReminders.length}',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Cards
          ...categories.map((category) {
            final templates = category['templates'] as List<Map<String, dynamic>>;
            final categoryTitle = category['title'] as String;
            final categoryColor = category['color'] as Color;
            final categoryIcon = category['icon'] as IconData;

            // Count reminders for templates in this category
            int totalCount = 0;
            for (final template in templates) {
              totalCount += categoryCounts[template['name']] ?? 0;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryRemindersScreen(
                        categoryTitle: categoryTitle,
                        templates: templates,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryTitle,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCount ${l10n?.reminders ?? 'reminders'}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Mini category chips
                      Wrap(
                        spacing: 4,
                        children: templates.take(3).map((template) {
                          final templateName = template['name'] as String;
                          final localizedName = l10n?.getCategoryLocalizedName(templateName) ?? templateName;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              localizedName.length > 8 ? localizedName.substring(0, 8) : localizedName,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: categoryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
