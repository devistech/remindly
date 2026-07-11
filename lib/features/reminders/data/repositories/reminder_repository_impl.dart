import 'package:flutter/foundation.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/reminder_model.dart';
import '../../domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  @override
  List<ReminderModel> getAllReminders() {
    return HiveService.getAllReminders();
  }

  @override
  ReminderModel? getReminder(String id) {
    return HiveService.getReminder(id);
  }

  @override
  Future<void> saveReminder(ReminderModel reminder) async {
    try {
      await HiveService.saveReminder(reminder);
      try {
        await NotificationService.scheduleReminder(reminder);
      } catch (e) {
        debugPrint('Notification scheduling failed: $e');
      }
    } catch (e) {
      debugPrint('Save reminder failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await NotificationService.cancelReminder(id);
    } catch (e) {
      debugPrint('Cancel notification failed: $e');
    }
    await HiveService.deleteReminder(id);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final reminder = HiveService.getReminder(id);
    if (reminder != null) {
      reminder.isCompleted = !reminder.isCompleted;
      await reminder.save();
      if (reminder.isCompleted) {
        // Cancel notification when marked complete
        try {
          await NotificationService.cancelReminder(reminder.id);
        } catch (e) {
          debugPrint('Cancel notification on complete failed: $e');
        }
      } else {
        // Re-schedule notification when unmarked
        try {
          await NotificationService.scheduleReminder(reminder);
        } catch (e) {
          debugPrint('Reschedule notification on uncomplete failed: $e');
        }
      }
    }
  }

  @override
  List<ReminderModel> getTodayReminders() {
    return HiveService.getTodayReminders();
  }

  @override
  List<ReminderModel> getUpcomingReminders() {
    return HiveService.getUpcomingReminders();
  }

  @override
  List<ReminderModel> getOverdueReminders() {
    return HiveService.getOverdueReminders();
  }
}
