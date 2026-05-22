// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display — Cormorant Garamond (emotional, cinematic) ──────
  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
    fontSize: 42,
    fontWeight: FontWeight.w300,
    color: AppColors.starWhite,
    letterSpacing: 1.5,
    height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.cormorantGaramond(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppColors.starWhite,
    letterSpacing: 1.2,
    height: 1.15,
  );

  static TextStyle get displaySmall => GoogleFonts.cormorantGaramond(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.starWhite,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static TextStyle get titleLarge => GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.starWhite,
    letterSpacing: 0.5,
  );

  // ── UI — Space Grotesk (modern, technical) ───────────────────
  static TextStyle get labelLarge => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.dimGrey,
    letterSpacing: 2.5,
  );

  static TextStyle get labelMedium => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.dimGrey,
    letterSpacing: 2.0,
  );

  static TextStyle get labelSmall => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.dimGrey,
    letterSpacing: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.softWhite,
    height: 1.7,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.dimGrey,
    height: 1.6,
  );

  // ── Accent — Space Mono (sci-fi data feel) ───────────────────
  static TextStyle get monoLarge => GoogleFonts.spaceMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.glowGold,
    letterSpacing: 1.0,
  );

  static TextStyle get monoSmall => GoogleFonts.spaceMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.dimGrey,
    letterSpacing: 0.5,
  );

  // ── Specific Styles ──────────────────────────────────────────
  static TextStyle get yearMarker => GoogleFonts.cormorantGaramond(
    fontSize: 64,
    fontWeight: FontWeight.w200,
    color: AppColors.starWhite.withValues(alpha: 0.08),
    letterSpacing: 8,
  );

  static TextStyle get monthLabel => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.dimGrey,
    letterSpacing: 3.0,
  );

  static TextStyle get activeMonthLabel => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.glowGold,
    letterSpacing: 3.0,
  );

  static TextStyle get nodeTitleStyle => GoogleFonts.cormorantGaramond(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.softWhite,
    letterSpacing: 0.3,
  );

  static TextStyle get nodeDateStyle => GoogleFonts.spaceGrotesk(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.dimGrey,
    letterSpacing: 1.0,
  );

  static TextStyle get statusTag => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.cosmicTeal,
    letterSpacing: 2.5,
  );

  static TextStyle get tagChip => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.glowGold,
    letterSpacing: 1.5,
  );

  static TextStyle get quoteText => GoogleFonts.cormorantGaramond(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    color: AppColors.softWhite,
    height: 1.8,
    letterSpacing: 0.3,
  );

  static TextStyle get appBarTitle => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.glowGold,
    letterSpacing: 4.0,
  );

  static TextStyle get coordinateText => GoogleFonts.spaceMono(
    fontSize: 10,
    color: AppColors.dimGrey,
    letterSpacing: 0.5,
  );
}
