import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/reminders/presentation/providers/reminder_providers.dart';
import 'features/reminders/presentation/screens/splash_screen.dart';


class RemindlyApp extends ConsumerWidget {
  const RemindlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    // Set Intl locale for DateFormat localization
    Intl.defaultLocale = currentLanguage == 'hi' ? 'hi_IN' : 'en_US';

    return MaterialApp(
      title: 'Remindly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(currentLanguage),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      home: const SplashScreen(),
    );
  }
}
