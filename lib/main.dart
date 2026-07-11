import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ad_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize services
  await HiveService.init();
  try {
    await NotificationService.init();
    // Permission request + rescheduleAll moved to SplashScreen
    // to ensure Activity is visible (required for Android 13+)
  } catch (e) {
    debugPrint('Notification service init failed: $e');
  }
  try {
    // Configure test device only in debug mode (not in release/production)
    if (!kReleaseMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['EC86C167F0A8B6AF3D2A6836EE51F568'],
        ),
      );
    }
    await AdService.init();
  } catch (e) {
    debugPrint('Ad service init failed: $e');
  }

  runApp(const ProviderScope(child: RemindlyApp()));
}
