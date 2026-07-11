import '../../data/models/reminder_model.dart';

abstract class ReminderRepository {
  List<ReminderModel> getAllReminders();
  ReminderModel? getReminder(String id);
  Future<void> saveReminder(ReminderModel reminder);
  Future<void> deleteReminder(String id);
  Future<void> toggleComplete(String id);
  List<ReminderModel> getTodayReminders();
  List<ReminderModel> getUpcomingReminders();
  List<ReminderModel> getOverdueReminders();
}
