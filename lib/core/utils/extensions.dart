import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension LocalizedCategory on AppLocalizations {
  String getCategoryLocalizedName(String categoryName) {
    switch (categoryName) {
      case 'Mobile Recharge':
        return mobileRecharge;
      case 'Electricity Bill':
        return electricityBill;
      case 'Water Bill':
        return waterBill;
      case 'Credit Card Bill':
        return creditCardBill;
      case 'Loan EMI':
        return loanEmi;
      case 'Rent':
        return rent;
      case 'Insurance Premium':
        return insurancePremium;
      case 'SIP Investment':
        return sipInvestment;
      case 'GST Filing':
        return gstFiling;
      case 'Income Tax Filing':
        return incomeTaxFiling;
      case 'OTT':
        return ott;
      case 'Music':
        return music;
      case 'App Subscriptions':
        return appSubscriptions;
      case 'Exams':
        return exams;
      case 'Fees':
        return fees;
      case 'Medicine':
        return medicine;
      case 'Gym':
        return gym;
      case 'Birthdays':
        return birthdays;
      case 'Anniversaries':
        return anniversaries;
      case 'Vehicle Service':
        return vehicleService;
      case 'Insurance Renewal':
        return insuranceRenewal;
      case 'Pollution (PUC)':
        return pollutionPuc;
      default:
        return categoryName;
    }
  }

  String getRepeatTypeLocalizedName(String repeatType) {
    switch (repeatType) {
      case 'None':
        return none;
      case 'Daily':
        return daily;
      case 'Weekly':
        return weekly;
      case 'Monthly':
        return monthly;
      case 'Yearly':
        return yearly;
      case 'Custom':
        return custom;
      default:
        return repeatType;
    }
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isOverdue {
    return isBefore(DateTime.now()) && !isToday;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return isAfter(now) && isBefore(nextWeek) && !isToday;
  }

  String get formattedDate {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String get formattedTime {
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
