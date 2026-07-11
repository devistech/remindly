import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base colors
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F5);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Category accent colors
  static const Color financial = Color(0xFF4F46E5);
  static const Color subscription = Color(0xFF7C3AED);
  static const Color personal = Color(0xFFEC4899);
  static const Color utility = Color(0xFF0EA5E9);

  // Status colors
  static const Color overdue = Color(0xFFEF4444);
  static const Color completed = Color(0xFF10B981);
  static const Color upcoming = Color(0xFFF59E0B);

  // Glass effect colors
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Category color map
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mobile recharge':
      case 'electricity bill':
      case 'water bill':
      case 'credit card bill':
      case 'loan emi':
      case 'rent':
      case 'insurance premium':
      case 'sip investment':
      case 'gst filing':
      case 'income tax filing':
        return financial;
      case 'ott':
      case 'music':
      case 'app subscriptions':
        return subscription;
      case 'exams':
      case 'fees':
      case 'medicine':
      case 'gym':
      case 'birthdays':
      case 'anniversaries':
        return personal;
      case 'vehicle service':
      case 'insurance renewal':
      case 'pollution (puc)':
        return utility;
      default:
        return financial;
    }
  }

  // Category icon map
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mobile recharge':
        return Icons.phone_android;
      case 'electricity bill':
        return Icons.electric_bolt;
      case 'water bill':
        return Icons.water_drop;
      case 'credit card bill':
        return Icons.credit_card;
      case 'loan emi':
        return Icons.account_balance;
      case 'rent':
        return Icons.home;
      case 'insurance premium':
        return Icons.shield;
      case 'sip investment':
        return Icons.trending_up;
      case 'gst filing':
        return Icons.receipt_long;
      case 'income tax filing':
        return Icons.description;
      case 'ott':
        return Icons.movie;
      case 'music':
        return Icons.music_note;
      case 'app subscriptions':
        return Icons.apps;
      case 'exams':
        return Icons.school;
      case 'fees':
        return Icons.payment;
      case 'medicine':
        return Icons.medication;
      case 'gym':
        return Icons.fitness_center;
      case 'birthdays':
        return Icons.cake;
      case 'anniversaries':
        return Icons.favorite;
      case 'vehicle service':
        return Icons.directions_car;
      case 'insurance renewal':
        return Icons.policy;
      case 'pollution (puc)':
        return Icons.eco;
      default:
        return Icons.notifications;
    }
  }
}
