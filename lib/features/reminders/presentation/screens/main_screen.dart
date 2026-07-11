import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/add_reminder_sheet.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  static const double _bannerMinHeight = 50;

  static const _screens = [
    DashboardScreen(),
    CalendarScreen(),
    CategoriesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
  }

  Future<void> _loadBannerAd() async {
    try {
      final width = MediaQuery.of(context).size.width;
      final ad = await AdService.createAdaptiveBannerAd(
        width,
        onLoaded: (loadedAd) {
          if (mounted) {
            setState(() {
              _bannerAd = loadedAd;
              _isBannerLoaded = true;
            });
          }
        },
        onFailed: (ad, error) {
          debugPrint('Banner failed: ${error.message} (code: ${error.code})');
          if (mounted) {
            setState(() => _isBannerLoaded = false);
            // Retry with exponential backoff: 15s, 30s, 60s... capped at 120s
            Future.delayed(const Duration(seconds: 30), _loadBannerAd);
          }
        },
      );
      if (ad != null) {
        ad.load();
      } else {
        Future.delayed(const Duration(seconds: 15), _loadBannerAd);
      }
    } catch (e) {
      debugPrint('Banner ad creation error: $e');
      if (mounted) {
        Future.delayed(const Duration(seconds: 30), _loadBannerAd);
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddReminderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: _screens,
            ),
          ),
          // Banner ad area — always takes space to prevent layout shift
          SizedBox(
            width: double.infinity,
            height: _isBannerLoaded && _bannerAd != null
                ? _bannerAd!.size.height.toDouble()
                : _bannerMinHeight,
            child: _isBannerLoaded && _bannerAd != null
                ? Center(child: AdWidget(ad: _bannerAd!))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: l10n?.dashboard ?? 'Home',
                  index: 0,
                  isSelected: currentTab == 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_month_rounded,
                  label: l10n?.calendar ?? 'Calendar',
                  index: 1,
                  isSelected: currentTab == 1,
                ),
                _buildAddButton(),
                _buildNavItem(
                  icon: Icons.category_rounded,
                  label: l10n?.categories ?? 'Categories',
                  index: 2,
                  isSelected: currentTab == 2,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: l10n?.settings ?? 'Settings',
                  index: 3,
                  isSelected: currentTab == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.financial.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.financial : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: isSelected ? AppTextStyles.navLabelSelected : AppTextStyles.navLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddReminderSheet,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.financial, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.financial.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
