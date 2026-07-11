import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/reminder_tile.dart';
import '../providers/reminder_providers.dart';
import 'reminder_detail_screen.dart';

class RemindersListScreen extends ConsumerStatefulWidget {
  const RemindersListScreen({super.key});

  @override
  ConsumerState<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends ConsumerState<RemindersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allReminders = ref.watch(allRemindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n?.dashboard ?? 'Reminders',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.financial,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.financial,
          tabs: [
            Tab(text: l10n?.pending ?? 'Pending'),
            Tab(text: l10n?.completed ?? 'Completed'),
            Tab(text: l10n?.overdue ?? 'Overdue'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending tab
          _buildRemindersList(
            allReminders.where((r) => !r.isCompleted && !r.isOverdue).toList(),
            l10n?.noTodayReminders ?? 'No pending reminders',
          ),
          // Completed tab
          _buildRemindersList(
            allReminders.where((r) => r.isCompleted).toList(),
            l10n?.noCompletedReminders ?? 'No completed reminders',
          ),
          // Overdue tab
          _buildRemindersList(
            allReminders.where((r) => r.isOverdue).toList(),
            l10n?.noOverdueReminders ?? 'No overdue reminders',
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(List reminders, String emptyMessage) {
    final l10n = AppLocalizations.of(context);

    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
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
    );
  }
}
