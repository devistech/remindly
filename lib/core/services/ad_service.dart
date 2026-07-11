import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;
  static InterstitialAd? _interstitialAd;
  static int _saveCount = 0;
  static int _interstitialRetryCount = 0;
  static int _bannerRetryCount = 0;

  // Real ad unit IDs
  static const String _bannerAdUnitId =
      'ca-app-pub-9258385386513304/9097319486';
  static const String _interstitialAdUnitId =
      'ca-app-pub-9258385386513304/7922848932';

  // Test ad unit IDs (for fallback in debug mode)
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get _effectiveBannerAdUnitId =>
      kReleaseMode ? _bannerAdUnitId : _testBannerAdUnitId;

  static String get _effectiveInterstitialAdUnitId =>
      kReleaseMode ? _interstitialAdUnitId : _testInterstitialAdUnitId;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      debugPrint('AdMob SDK initialized successfully');
      if (!kReleaseMode) {
        debugPrint('  - Using TEST ad unit IDs (debug mode)');
      }
      _initialized = true;
      _interstitialRetryCount = 0;
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdMob SDK initialization FAILED: $e');
      rethrow;
    }
  }

  static void _loadInterstitial() {
    final retryDelay = _calculateBackoff(_interstitialRetryCount);
    InterstitialAd.load(
      adUnitId: _effectiveInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _interstitialRetryCount = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _interstitialRetryCount++;
          debugPrint(
            'Interstitial failed to load (attempt $_interstitialRetryCount): '
            'code=${error.code}, message=${error.message}',
          );
          _logAdError('Interstitial', error.code, error.message);
          if (_interstitialRetryCount < 10) {
            Future.delayed(Duration(seconds: retryDelay), _loadInterstitial);
          }
        },
      ),
    );
  }

  static Future<void> showInterstitial() async {
    _saveCount++;
    if (_saveCount % 2 != 0) return;
    if (_interstitialAd == null) {
      debugPrint('Interstitial not ready, loading...');
      _loadInterstitial();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial dismissed by user');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: code=${error.code}, '
            'message=${error.message}');
        _logAdError('Interstitial show', error.code, error.message);
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial ad shown to user');
      },
      onAdImpression: (ad) {
        debugPrint('Interstitial impression recorded');
      },
    );

    await _interstitialAd!.show();
  }

  static Future<BannerAd?> createAdaptiveBannerAd(
    double width, {
    void Function(BannerAd ad)? onLoaded,
    void Function(Ad ad, LoadAdError error)? onFailed,
  }) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );

    return BannerAd(
      adUnitId: _effectiveBannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerRetryCount = 0;
          debugPrint('Banner ad loaded successfully');
          onLoaded?.call(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          _bannerRetryCount++;
          debugPrint(
            'Banner ad failed to load (attempt $_bannerRetryCount): '
            'code=${error.code}, message=${error.message}',
          );
          _logAdError('Banner', error.code, error.message);
          onFailed?.call(ad, error);
          ad.dispose();
        },
      ),
    );
  }

  static int _calculateBackoff(int attempt) {
    // Exponential backoff: 10s, 20s, 40s, 80s... capped at 120s
    const base = 10;
    final delay = base * (1 << attempt); // 10 * 2^attempt
    return delay > 120 ? 120 : delay;
  }

  static void _logAdError(String adType, int code, String message) {
    // Android AdMob error codes:
    // 0 = ERROR_CODE_INTERNAL_ERROR, 1 = ERROR_CODE_INVALID_REQUEST,
    // 2 = ERROR_CODE_NETWORK_ERROR,  3 = ERROR_CODE_NO_FILL
    String reason;
    switch (code) {
      case 0:
        reason = 'Internal error - check AdMob app ID and ad unit config';
        break;
      case 1:
        reason = 'Invalid request - check ad unit ID format';
        break;
      case 2:
        reason = 'Network error - check internet connection';
        break;
      case 3:
        reason = 'No fill - '
            '${kReleaseMode ? "app may not have enough traffic yet or needs Play Store publication" : "test ads should fill; check test device ID"}';
        break;
      default:
        reason = 'Unknown error code: $code';
    }
    debugPrint('AdMob $adType error diagnosis: $reason');
  }

  static void dispose() {
    _interstitialAd?.dispose();
  }
}
