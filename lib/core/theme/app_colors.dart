// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color cosmosBlack = Color(0xFF060911);
  static const Color deepNavy    = Color(0xFF0D1220);
  static const Color midNavy     = Color(0xFF111827);

  // ── Accent / Glow ────────────────────────────────────────────
  static const Color glowGold    = Color(0xFFD4A843);
  static const Color warmAmber   = Color(0xFFE8C170);
  static const Color paleGold    = Color(0xFFF5E6B8);
  static const Color cosmicTeal  = Color(0xFF2DD4BF);
  static const Color softPurple  = Color(0xFF8B5CF6);
  static const Color roseGlow    = Color(0xFFE879A0);

  // ── Text ─────────────────────────────────────────────────────
  static const Color starWhite   = Color(0xFFF0EEE9);
  static const Color softWhite   = Color(0xFFD1CCBf);
  static const Color dimGrey     = Color(0xFF6B7280);
  static const Color mutedGrey   = Color(0xFF374151);

  // ── Glass Panels ─────────────────────────────────────────────
  static const Color glassFill   = Color(0x14FFFFFF);  // 8% white
  static const Color glassBorder = Color(0x26FFFFFF);  // 15% white
  static const Color glassShine  = Color(0x0DFFFFFF);  // 5% white

  // ── Mood Colors (for memory emotional tags) ───────────────────
  static const Color moodJoy      = Color(0xFFFFD166);
  static const Color moodPeace    = Color(0xFF06D6A0);
  static const Color moodLove     = Color(0xFFEF476F);
  static const Color moodNostalgia = Color(0xFF8B5CF6);
  static const Color moodAwe      = Color(0xFF3B82F6);
  static const Color moodMelancholy = Color(0xFF6B7280);
  static const Color moodGratitude = Color(0xFFD4A843);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient cosmosBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF060911),
      Color(0xFF0A1018),
      Color(0xFF0D1525),
      Color(0xFF081018),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient globeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1205),
      Color(0xFF0D0A02),
    ],
  );

  static const RadialGradient nodeGlow = RadialGradient(
    colors: [
      Color(0x80D4A843),
      Color(0x00D4A843),
    ],
  );

  static LinearGradient detailBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF060911),
      const Color(0xFF0D1525),
      const Color(0xFF061318),
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}
