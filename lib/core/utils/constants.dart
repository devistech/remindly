class AppConstants {
  AppConstants._();

  static const String appName = 'Remindly';
  static const String hiveBoxReminders = 'reminders';
  static const String hiveBoxSettings = 'settings';
  static const String languageKey = 'language';
  static const String firstLaunchKey = 'first_launch';

  static const List<Map<String, dynamic>> financialTemplates = [
    {'name': 'Mobile Recharge', 'icon': 'phone_android'},
    {'name': 'Electricity Bill', 'icon': 'electric_bolt'},
    {'name': 'Water Bill', 'icon': 'water_drop'},
    {'name': 'Credit Card Bill', 'icon': 'credit_card'},
    {'name': 'Loan EMI', 'icon': 'account_balance'},
    {'name': 'Rent', 'icon': 'home'},
    {'name': 'Insurance Premium', 'icon': 'shield'},
    {'name': 'SIP Investment', 'icon': 'trending_up'},
    {'name': 'GST Filing', 'icon': 'receipt_long'},
    {'name': 'Income Tax Filing', 'icon': 'description'},
  ];

  static const List<Map<String, dynamic>> subscriptionTemplates = [
    {'name': 'OTT', 'icon': 'movie'},
    {'name': 'Music', 'icon': 'music_note'},
    {'name': 'App Subscriptions', 'icon': 'apps'},
  ];

  static const List<Map<String, dynamic>> personalTemplates = [
    {'name': 'Exams', 'icon': 'school'},
    {'name': 'Fees', 'icon': 'payment'},
    {'name': 'Medicine', 'icon': 'medication'},
    {'name': 'Gym', 'icon': 'fitness_center'},
    {'name': 'Birthdays', 'icon': 'cake'},
    {'name': 'Anniversaries', 'icon': 'favorite'},
  ];

  static const List<Map<String, dynamic>> utilityTemplates = [
    {'name': 'Vehicle Service', 'icon': 'directions_car'},
    {'name': 'Insurance Renewal', 'icon': 'policy'},
    {'name': 'Pollution (PUC)', 'icon': 'eco'},
  ];

  static const List<String> repeatTypes = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
  ];
}
