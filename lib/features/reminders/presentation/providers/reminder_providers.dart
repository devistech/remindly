import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/reminder_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});

final allRemindersProvider = StateNotifierProvider<RemindersNotifier, List<ReminderModel>>((ref) {
  return RemindersNotifier(ref.watch(reminderRepositoryProvider));
});

final todayRemindersProvider = Provider<List<ReminderModel>>((ref) {
  ref.watch(allRemindersProvider);
  return HiveService.getTodayReminders();
});

final upcomingRemindersProvider = Provider<List<ReminderModel>>((ref) {
  ref.watch(allRemindersProvider);
  return HiveService.getUpcomingReminders();
});

final overdueRemindersProvider = Provider<List<ReminderModel>>((ref) {
  ref.watch(allRemindersProvider);
  return HiveService.getOverdueReminders();
});

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class RemindersNotifier extends StateNotifier<List<ReminderModel>> {
  final ReminderRepository _repository;

  RemindersNotifier(this._repository) : super(_repository.getAllReminders());

  Future<void> addReminder(ReminderModel reminder) async {
    await _repository.saveReminder(reminder);
    state = _repository.getAllReminders();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _repository.saveReminder(reminder);
    state = _repository.getAllReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _repository.deleteReminder(id);
    state = _repository.getAllReminders();
  }

  Future<void> toggleComplete(String id) async {
    await _repository.toggleComplete(id);
    state = _repository.getAllReminders();
  }

  Future<void> clearAll() async {
    final reminders = _repository.getAllReminders();
    for (final reminder in reminders) {
      await _repository.deleteReminder(reminder.id);
    }
    state = [];
  }
}

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(HiveService.getLanguage());

  Future<void> setLanguage(String lang) async {
    await HiveService.setLanguage(lang);
    state = lang;
  }
}
