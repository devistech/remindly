class Reminder {
  final String id;
  final String title;
  final String category;
  final DateTime dateTime;
  final String repeatType;
  final int? customInterval;
  final List<int> notifyOffsets;
  final bool isCompleted;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.repeatType = 'None',
    this.customInterval,
    this.notifyOffsets = const [0],
    this.isCompleted = false,
    required this.createdAt,
  });

  bool get isOverdue {
    return dateTime.isBefore(DateTime.now()) && !isCompleted && repeatType == 'None';
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return dateTime.isAfter(now) && dateTime.isBefore(nextWeek);
  }
}
