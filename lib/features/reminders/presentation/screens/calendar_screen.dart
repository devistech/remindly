import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localization.dart';
import '../../../../core/widgets/reminder_tile.dart';
import '../providers/reminder_providers.dart';
import 'reminder_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final reminders = ref.read(allRemindersProvider);
    return reminders.where((r) {
      final reminderDate = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
      final checkDate = DateTime(day.year, day.month, day.day);
      return reminderDate.isAtSameMomentAs(checkDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allReminders = ref.watch(allRemindersProvider);
    final selectedDayReminders = allReminders.where((r) {
      if (_selectedDay == null) return false;
      final reminderDate = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
      final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      return reminderDate.isAtSameMomentAs(selectedDate);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n?.calendar ?? 'Calendar',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.financial.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.inter(
                  color: AppColors.financial,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.financial,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.personal,
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                formatButtonTextStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.financial,
                ),
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.financial),
                  borderRadius: BorderRadius.circular(8),
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Selected Day Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormat('EEEE, MMM d', Localizations.localeOf(context).languageCode).format(_selectedDay!)
                      : l10n?.selectADay ?? 'Select a day',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.financial.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedDayReminders.length} ${l10n?.reminders ?? 'reminders'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.financial,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reminders List
          Expanded(
            child: selectedDayReminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 48,
                          color: AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.noRemindersForDay ?? 'No reminders for this day',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                    itemCount: selectedDayReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = selectedDayReminders[index];
                      return ReminderTile(
                        title: reminder.title,
                        category: reminder.category,
                        localizedCategory: l10n?.getCategoryLocalizedName(reminder.category),
                        dateTime: reminder.dateTime,
                        isCompleted: reminder.isCompleted,
                        isOverdue: reminder.isOverdue,
                        useGlassEffect: false,
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
          ),
        ],
      ),
    );
  }
}
