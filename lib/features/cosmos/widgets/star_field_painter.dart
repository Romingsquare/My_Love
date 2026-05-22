// lib/features/cosmos/widgets/star_field_painter.dart
//
// StarFieldPainter renders the deep-space background: a layered field of
// micro-stars at varying depths, soft nebula fog patches, and the
// constellation lines connecting memory nodes.
//
// Performance: uses RepaintBoundary at the call site. The painter only
// repaints when cosmosShift changes (i.e., when time navigates).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BackgroundStar {
  final double x; // normalized 0..1
  final double y;
  final double size;
  final double opacity;
  final int layer; // 0=far, 1=mid, 2=near

  const BackgroundStar({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.layer,
  });
}

// Pre-generate stars once to avoid per-frame allocation
List<BackgroundStar> _generateStars(int count, int seed) {
  final rand = math.Random(seed);
  return List.generate(count, (i) {
    final layer = (rand.nextDouble() > 0.7)
        ? 2
        : (rand.nextDouble() > 0.5 ? 1 : 0);
    return BackgroundStar(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: 0.4 + rand.nextDouble() * (layer == 2 ? 1.8 : layer == 1 ? 1.2 : 0.7),
      opacity: 0.15 + rand.nextDouble() * 0.5,
      layer: layer,
    );
  });
}

final _stars = _generateStars(220, 77);

class StarFieldPainter extends CustomPainter {
  /// Horizontal cosmos shift from rotary wheel (0..1 representing full month range)
  final double cosmosShift;
  final double twinklePhase; // 0..2π for subtle brightness animation

  const StarFieldPainter({
    required this.cosmosShift,
    required this.twinklePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawNebulaPatch(canvas, size);
    _drawStars(canvas, size);
  }

  void _drawNebulaPatch(Canvas canvas, Size size) {
    // Soft atmospheric fog patches — very subtle
    final patches = [
      _NebulaPatch(Offset(size.width * 0.15, size.height * 0.25), size.width * 0.4, AppColors.softPurple.withValues(alpha: 0.04)),
      _NebulaPatch(Offset(size.width * 0.8, size.height * 0.15), size.width * 0.35, AppColors.cosmicTeal.withValues(alpha: 0.03)),
      _NebulaPatch(Offset(size.width * 0.5, size.height * 0.6), size.width * 0.5, AppColors.glowGold.withValues(alpha: 0.025)),
    ];

    for (final patch in patches) {
      // Apply parallax shift based on cosmos navigation
      final dx = (cosmosShift * size.width * 0.08 * (1 + patches.indexOf(patch) * 0.3));
      final adjustedCenter = Offset(patch.center.dx - dx % size.width, patch.center.dy);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [patch.color, Colors.transparent],
        ).createShader(Rect.fromCenter(
          center: adjustedCenter,
          width: patch.radius * 2,
          height: patch.radius * 2,
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.drawCircle(adjustedCenter, patch.radius, paint);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in _stars) {
      // Parallax offset — farther stars move less
      final parallaxFactor = 0.02 + star.layer * 0.04;
      final dx = (cosmosShift * size.width * parallaxFactor) % size.width;
      final px = (star.x * size.width - dx + size.width) % size.width;
      final py = star.y * size.height;

      // Twinkle: near stars sparkle slightly
      final twinkleMod = star.layer == 2
          ? 0.8 + 0.2 * math.sin(twinklePhase + star.x * 6.28)
          : 1.0;

      paint.color = AppColors.starWhite.withValues(alpha: star.opacity * twinkleMod);

      if (star.layer == 2 && star.size > 1.5) {
        // Bright near star — add tiny glow
        final glowPaint = Paint()
          ..color = AppColors.starWhite.withValues(alpha: star.opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(px, py), star.size * 1.8, glowPaint);
      }

      canvas.drawCircle(Offset(px, py), star.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter old) =>
      old.cosmosShift != cosmosShift || old.twinklePhase != twinklePhase;
}

class _NebulaPatch {
  final Offset center;
  final double radius;
  final Color color;
  const _NebulaPatch(this.center, this.radius, this.color);
}
