import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/reminder_tile.dart';
import '../providers/reminder_providers.dart';
import '../widgets/add_reminder_sheet.dart';
import 'reminder_detail_screen.dart';

class CategoryRemindersScreen extends ConsumerWidget {
  final String categoryTitle;
  final List<Map<String, dynamic>> templates;

  const CategoryRemindersScreen({
    super.key,
    required this.categoryTitle,
    required this.templates,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allReminders = ref.watch(allRemindersProvider);

    // Filter reminders that match any template in this category
    final categoryReminders = allReminders.where((r) {
      return templates.any((t) => t['name'] == r.category);
    }).toList();

    // Sort by date
    categoryReminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          categoryTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: categoryReminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.noRemindersInCategory ?? 'No reminders in this category',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.tapToAddReminder ?? 'Tap + to add a reminder',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categoryReminders.length,
              itemBuilder: (context, index) {
                final reminder = categoryReminders[index];
                return ReminderTile(
                  title: reminder.title,
                  category: reminder.category,
                  localizedCategory: l10n?.getCategoryLocalizedName(reminder.category),
                  dateTime: reminder.dateTime,
                  isCompleted: reminder.isCompleted,
                  isOverdue: reminder.isOverdue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReminderDetailScreen(reminder: reminder),
                    ),
                  ),
                  onToggle: () => ref
                      .read(allRemindersProvider.notifier)
                      .toggleComplete(reminder.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddReminderSheet(initialCategory: categoryTitle),
          );
        },
        backgroundColor: AppColors.financial,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
