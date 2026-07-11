import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/reminder_model.dart';
import '../providers/reminder_providers.dart';

class ReminderDetailScreen extends ConsumerWidget {
  final ReminderModel reminder;

  const ReminderDetailScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = AppColors.getCategoryColor(reminder.category);
    final categoryIcon = AppColors.getCategoryIcon(reminder.category);
    final l10n = AppLocalizations.of(context);
    final localizedCategory = l10n?.getCategoryLocalizedName(reminder.category) ?? reminder.category;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.overdue),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(categoryIcon, size: 16, color: categoryColor),
                  const SizedBox(width: 6),
                  Text(
                    localizedCategory,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              reminder.title,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Status
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: reminder.isCompleted
                          ? AppColors.completed.withValues(alpha: 0.15)
                          : AppColors.overdue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      reminder.isCompleted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                      color: reminder.isCompleted
                          ? AppColors.completed
                          : AppColors.overdue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.status ?? 'Status',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        reminder.isCompleted
                            ? (AppLocalizations.of(context)?.completed ?? 'Completed')
                            : (AppLocalizations.of(context)?.pending ?? 'Pending'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: reminder.isCompleted
                              ? AppColors.completed
                              : AppColors.overdue,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Switch(
                    value: reminder.isCompleted,
                    activeThumbColor: AppColors.completed,
                    onChanged: (_) {
                      ref
                          .read(allRemindersProvider.notifier)
                          .toggleComplete(reminder.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date & Time
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.financial.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: AppColors.financial,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.dateTime ?? 'Date & Time',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(reminder.dateTime),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Repeat
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.subscription.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.repeat,
                      color: AppColors.subscription,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.repeat ?? 'Repeat',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        reminder.repeatType == 'Custom'
                            ? '${l10n?.every ?? 'Every'} ${reminder.customInterval} ${l10n?.days ?? 'days'}'
                            : (l10n?.getRepeatTypeLocalizedName(reminder.repeatType) ?? reminder.repeatType),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notifications
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.personal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.personal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.notifications ?? 'Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        reminder.notifyOffsets.map((o) {
                          if (o == 0) return l10n?.sameDay ?? 'Same day';
                          if (o == 1) return l10n?.oneDayBefore ?? '1 day before';
                          final daysStr = l10n?.days ?? 'days';
                          return '$o $daysStr';
                        }).join(', '),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, ref),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(AppLocalizations.of(context)?.editReminder ?? 'Edit Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.financial,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)?.deleteReminder ?? 'Delete Reminder',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context)?.deleteConfirm ?? 'Are you sure you want to delete this reminder?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(allRemindersProvider.notifier).deleteReminder(reminder.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              AppLocalizations.of(context)?.delete ?? 'Delete',
              style: GoogleFonts.inter(
                color: AppColors.overdue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: reminder.title);
    DateTime selectedDate = reminder.dateTime;
    String selectedRepeat = reminder.repeatType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.of(context)?.editReminder ?? 'Edit Reminder',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.title ?? 'Title',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(selectedDate),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time == null || !context.mounted) return;
                    setState(() {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRepeat,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.repeat ?? 'Repeat',
                    border: const OutlineInputBorder(),
                  ),
                  items: ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRepeat = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                final updated = reminder.copyWith(
                  title: titleController.text,
                  dateTime: selectedDate,
                  repeatType: selectedRepeat,
                );
                ref.read(allRemindersProvider.notifier).updateReminder(updated);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)?.save ?? 'Save',
                style: GoogleFonts.inter(
                  color: AppColors.financial,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
