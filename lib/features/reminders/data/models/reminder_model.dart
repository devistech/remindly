import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final String repeatType;

  @HiveField(5)
  final int? customInterval;

  @HiveField(6)
  final List<int> notifyOffsets;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.repeatType = 'None',
    this.customInterval,
    this.notifyOffsets = const [0],
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    return dateTime.isBefore(DateTime.now()) && !isCompleted && repeatType == 'None';
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dateTime,
    String? repeatType,
    int? customInterval,
    List<int>? notifyOffsets,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      repeatType: repeatType ?? this.repeatType,
      customInterval: customInterval ?? this.customInterval,
      notifyOffsets: notifyOffsets ?? this.notifyOffsets,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
