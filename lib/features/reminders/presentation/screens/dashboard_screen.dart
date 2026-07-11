import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_localization.dart';
import '../../../../core/widgets/reminder_tile.dart';
import '../providers/reminder_providers.dart';
import '../widgets/add_reminder_sheet.dart';
import 'reminder_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todayReminders = ref.watch(todayRemindersProvider);
    final overdueReminders = ref.watch(overdueRemindersProvider);
    final allReminders = ref.watch(allRemindersProvider);

    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    final upcomingReminders = allReminders.where((r) {
      return r.dateTime.isAfter(now) &&
          r.dateTime.isBefore(threeDaysLater) &&
          !r.isCompleted;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png.jpeg',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(l10n),
                              style: AppTextStyles.greeting,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.appName ?? 'Remindly',
                              style: AppTextStyles.h1,
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddReminderSheet(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.financial,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Date display
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  DateFormat('EEEE, MMMM d', Localizations.localeOf(context).languageCode).format(now),
                  style: AppTextStyles.dateDisplay,
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.today_rounded,
                        label: l10n?.today ?? 'Today',
                        count: todayReminders.length,
                        color: AppColors.financial,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.warning_rounded,
                        label: l10n?.overdue ?? 'Overdue',
                        count: overdueReminders.length,
                        color: AppColors.overdue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.upcoming_rounded,
                        label: l10n?.upcoming ?? 'Upcoming',
                        count: upcomingReminders.length,
                        color: AppColors.upcoming,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overdue Section
            if (overdueReminders.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  l10n?.overdue ?? 'Overdue',
                  AppColors.overdue,
                  overdueReminders.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reminder = overdueReminders[index];
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
                  childCount: overdueReminders.length,
                ),
              ),
            ],

            // Today Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                l10n?.today ?? 'Today',
                AppColors.financial,
                todayReminders.length,
              ),
            ),
            if (todayReminders.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  message: l10n?.noTodayReminders ?? 'No reminders for today',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reminder = todayReminders[index];
                    return ReminderTile(
                      title: reminder.title,
                      category: reminder.category,
                      localizedCategory: l10n?.getCategoryLocalizedName(reminder.category),
                      dateTime: reminder.dateTime,
                      isCompleted: reminder.isCompleted,
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
                  childCount: todayReminders.length,
                ),
              ),

            // Upcoming Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                l10n?.upcoming ?? 'Upcoming',
                AppColors.upcoming,
                upcomingReminders.length,
              ),
            ),
            if (upcomingReminders.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(
                  icon: Icons.event_available_rounded,
                  message: l10n?.noUpcomingReminders ?? 'No upcoming reminders',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reminder = upcomingReminders[index];
                    return ReminderTile(
                      title: reminder.title,
                      category: reminder.category,
                      localizedCategory: l10n?.getCategoryLocalizedName(reminder.category),
                      dateTime: reminder.dateTime,
                      isCompleted: reminder.isCompleted,
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
                  childCount: upcomingReminders.length > 5 ? 5 : upcomingReminders.length,
                ),
              ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  l10n?.quickAdd ?? 'Quick Add',
                  style: AppTextStyles.sectionHeader,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildQuickAction(
                      icon: Icons.phone_android_rounded,
                      label: l10n?.recharge ?? 'Recharge',
                      color: AppColors.financial,
                      onTap: () => _showAddWithCategory(context, 'Mobile Recharge'),
                    ),
                    _buildQuickAction(
                      icon: Icons.electric_bolt_rounded,
                      label: l10n?.electricity ?? 'Electricity',
                      color: AppColors.utility,
                      onTap: () => _showAddWithCategory(context, 'Electricity Bill'),
                    ),
                    _buildQuickAction(
                      icon: Icons.credit_card_rounded,
                      label: l10n?.creditCard ?? 'Credit Card',
                      color: AppColors.subscription,
                      onTap: () => _showAddWithCategory(context, 'Credit Card Bill'),
                    ),
                    _buildQuickAction(
                      icon: Icons.home_rounded,
                      label: l10n?.rent ?? 'Rent',
                      color: AppColors.personal,
                      onTap: () => _showAddWithCategory(context, 'Rent'),
                    ),
                    _buildQuickAction(
                      icon: Icons.school_rounded,
                      label: l10n?.exam ?? 'Exam',
                      color: AppColors.personal,
                      onTap: () => _showAddWithCategory(context, 'Exams'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(AppLocalizations? l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n?.goodMorning ?? 'Good Morning';
    if (hour < 17) return l10n?.goodAfternoon ?? 'Good Afternoon';
    return l10n?.goodEvening ?? 'Good Evening';
  }

  void _showAddWithCategory(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(initialCategory: category),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(count.toString(), style: AppTextStyles.statCount),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.sectionHeader),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.badgeCount.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.quickActionLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
