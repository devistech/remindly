import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/reminder_tile.dart';
import '../providers/reminder_providers.dart';
import '../screens/reminder_detail_screen.dart';

class OverdueReminders extends ConsumerWidget {
  const OverdueReminders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(overdueRemindersProvider);
    final l10n = AppLocalizations.of(context);

    if (reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ReminderTile(
          title: reminder.title,
          category: reminder.category,
          localizedCategory: l10n?.getCategoryLocalizedName(reminder.category),
          dateTime: reminder.dateTime,
          isCompleted: reminder.isCompleted,
          isOverdue: true,
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
    );
  }
}
