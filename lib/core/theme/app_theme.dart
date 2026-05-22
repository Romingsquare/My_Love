// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.cosmosBlack,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.glowGold,
      secondary: AppColors.cosmicTeal,
      tertiary: AppColors.softPurple,
      surface: AppColors.deepNavy,
      onPrimary: AppColors.cosmosBlack,
      onSecondary: AppColors.cosmosBlack,
      onSurface: AppColors.starWhite,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      titleLarge: AppTextStyles.titleLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.cosmosBlack,
      ),
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: const IconThemeData(color: AppColors.glowGold),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

// ── Animation Curves ─────────────────────────────────────────────────────────
class AppCurves {
  AppCurves._();

  /// Smooth orbital drift — primary navigation
  static const Curve cosmicEase    = Cubic(0.25, 0.46, 0.45, 0.94);

  /// Weighted planetary settle — snapping, landing
  static const Curve planetaryEase = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Memory reveal — content appearing
  static const Curve memoryReveal  = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Star drift — background animations
  static const Curve starDrift     = Cubic(0.45, 0.0, 0.55, 1.0);
}

// ── Durations ─────────────────────────────────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration instant   = Duration(milliseconds: 150);
  static const Duration quick     = Duration(milliseconds: 300);
  static const Duration standard  = Duration(milliseconds: 500);
  static const Duration cinematic = Duration(milliseconds: 800);
  static const Duration epic      = Duration(milliseconds: 1200);
  static const Duration splashFade = Duration(milliseconds: 2000);
}
