import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../../features/reminders/data/models/reminder_model.dart';

class HiveService {
  static late Box<ReminderModel> _remindersBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ReminderModelAdapter());

    // Open settings box first (never delete it to preserve first launch state)
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxSettings);

    // Open reminders box with error recovery
    try {
      _remindersBox = await Hive.openBox<ReminderModel>(AppConstants.hiveBoxReminders);
    } catch (e) {
      // Only delete reminders box if corrupted, not settings
      await Hive.deleteBoxFromDisk(AppConstants.hiveBoxReminders);
      _remindersBox = await Hive.openBox<ReminderModel>(AppConstants.hiveBoxReminders);
    }
  }

  // Reminders
  static List<ReminderModel> getAllReminders() {
    return _remindersBox.values.toList();
  }

  static ReminderModel? getReminder(String id) {
    return _remindersBox.get(id);
  }

  static Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  static List<ReminderModel> getTodayReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _remindersBox.values.where((r) {
      final reminderDate = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
      return reminderDate.isAtSameMomentAs(today) ||
          (r.repeatType != 'None' && r.dateTime.isBefore(tomorrow));
    }).toList();
  }

  static List<ReminderModel> getUpcomingReminders() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    return _remindersBox.values.where((r) {
      return r.dateTime.isAfter(tomorrow) && r.dateTime.isBefore(nextWeek) && !r.isCompleted;
    }).toList();
  }

  static List<ReminderModel> getOverdueReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _remindersBox.values.where((r) {
      final reminderDate = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
      return reminderDate.isBefore(today) && !r.isCompleted && r.repeatType == 'None';
    }).toList();
  }

  // Settings
  static String getLanguage() {
    return _settingsBox.get(AppConstants.languageKey, defaultValue: 'en');
  }

  static Future<void> setLanguage(String lang) async {
    await _settingsBox.put(AppConstants.languageKey, lang);
  }

  static bool isFirstLaunch() {
    return _settingsBox.get(AppConstants.firstLaunchKey, defaultValue: true);
  }

  static Future<void> setFirstLaunchComplete() async {
    await _settingsBox.put(AppConstants.firstLaunchKey, false);
  }
}
