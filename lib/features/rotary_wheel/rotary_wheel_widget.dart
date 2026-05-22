// lib/features/rotary_wheel/rotary_wheel_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'rotary_wheel_controller.dart';

const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

class RotaryWheelWidget extends StatelessWidget {
  final RotaryWheelController controller;
  final double glowIntensity;
  
  const RotaryWheelWidget({
    super.key,
    required this.controller,
    required this.glowIntensity,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cx = constraints.maxWidth / 2;
        // Steeper arc: smaller radius, center brought up higher
        final radius = constraints.maxWidth * 0.70; 
        final cy = constraints.maxHeight + radius * 0.25;
        final center = Offset(cx, cy);

        return GestureDetector(
          onPanStart: (d) => controller.onPanStart(d.localPosition, center),
          onPanUpdate: (d) => controller.onPanUpdate(d.localPosition, center),
          onPanEnd: (d) => controller.onPanEnd(d.velocity.pixelsPerSecond, center),
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: RotaryWheelPainter(
              angle: controller.angle,
              glowIntensity: glowIntensity,
              radius: radius,
              center: center,
            ),
          ),
        );
      }
    );
  }
}

class RotaryWheelPainter extends CustomPainter {
  final double angle;
  final double glowIntensity;
  final double radius;
  final Offset center;
  
  RotaryWheelPainter({
    required this.angle,
    required this.glowIntensity,
    required this.radius,
    required this.center,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final cx = center.dx;
    final cy = center.dy;
    
    // 1. Intense central background glow (the energy aura)
    final glowRadius = 120.0 + 30.0 * glowIntensity;
    final glowRect = Rect.fromCircle(center: Offset(cx, cy - radius), radius: glowRadius);
    canvas.drawCircle(
      Offset(cx, cy - radius),
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.glowGold.withValues(alpha: 0.35 + 0.15 * glowIntensity),
            AppColors.glowGold.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(glowRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // 2. Faint dashed outer track for extreme detail
    _drawDashedArc(canvas, center, radius + 14, -math.pi * 0.85, math.pi * 0.7, size.width);

    // 3. Inner solid thin track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = LinearGradient(
          colors: [Colors.transparent, Colors.white.withValues(alpha: 0.2), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, cy - radius, size.width, 10)),
    );

    // 4. The main thick glass-like arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.95),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ).createShader(Rect.fromLTWH(0, cy - radius - 20, size.width, 40)),
    );
    
    // 5. Highly detailed ticks (10 subdivisions per month)
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final fractionalMonth = (angle / (2 * math.pi)) * 12;
    const subdivisionsPerMonth = 10;
    final centerTickIndex = (fractionalMonth * subdivisionsPerMonth).round();
    
    for (int i = centerTickIndex - 60; i <= centerTickIndex + 60; i++) {
      final double m = i / subdivisionsPerMonth;
      final distance = m - fractionalMonth;
      
      // Spread angle per month = 0.32 radians
      final visualAngle = -math.pi / 2 + distance * 0.32; 
      if (visualAngle < -math.pi * 0.9 || visualAngle > -math.pi * 0.1) continue;
      
      final fade = (1.0 - (distance.abs() / 3.5)).clamp(0.0, 1.0);
      if (fade <= 0.0) continue;
      
      final isMajor = i % subdivisionsPerMonth == 0;
      final isMedium = i % (subdivisionsPerMonth / 2) == 0 && !isMajor;
      
      final tickLength = isMajor ? 26.0 : (isMedium ? 14.0 : 6.0);
      final tickWidth = isMajor ? 2.5 : (isMedium ? 1.5 : 1.0);
      final tickAlpha = isMajor ? 0.9 : (isMedium ? 0.5 : 0.25);
      final color = isMajor && distance.abs() < 0.5 ? AppColors.glowGold : Colors.white;
      
      // Draw tick pointing UPWARDS from the main line
      canvas.drawLine(
        Offset(cx + radius * math.cos(visualAngle), cy + radius * math.sin(visualAngle)),
        Offset(cx + (radius - tickLength) * math.cos(visualAngle), cy + (radius - tickLength) * math.sin(visualAngle)),
        Paint()
          ..color = color.withValues(alpha: fade * tickAlpha)
          ..strokeWidth = tickWidth
          ..strokeCap = StrokeCap.round,
      );
      
      // Draw Month Label BELOW the main line
      if (isMajor) {
        final monthIndex = (m.round() % 12 + 12) % 12;
        final isActive = distance.abs() < 0.5;
        
        tp.text = TextSpan(
          text: _months[monthIndex],
          style: TextStyle(
            color: isActive ? AppColors.glowGold : Colors.white.withValues(alpha: fade * 0.7),
            fontSize: isActive ? 13 : 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 2.0,
          ),
        );
        tp.layout();
        
        canvas.save();
        // Position label 24 pixels below the line
        canvas.translate(cx + (radius + 24) * math.cos(visualAngle), cy + (radius + 24) * math.sin(visualAngle));
        canvas.rotate(visualAngle + math.pi / 2);
        tp.paint(canvas, Offset(-tp.width / 2, 0));
        canvas.restore();
      }
    }

    // 6. Highly detailed Center Knob at 12 o'clock
    final knobCenter = Offset(cx, cy - radius);
    
    // Outer glass drop shadow
    canvas.drawCircle(
      knobCenter,
      16,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Outer glass ring
    canvas.drawCircle(
      knobCenter,
      16,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Inner dark background
    canvas.drawCircle(
      knobCenter,
      15.5,
      Paint()..color = const Color(0xFF0F0F0F),
    );
    // Inner thick white ring
    canvas.drawCircle(
      knobCenter,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    // Glowing core dot
    canvas.drawCircle(
      knobCenter,
      3.5,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
    );
  }

  void _drawDashedArc(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, double width) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withValues(alpha: 0.4), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, center.dy - radius, width, 10));
      
    const int dashCount = 60;
    final double dashSweep = sweepAngle / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + i * dashSweep,
          dashSweep * 0.5, // 50% dash, 50% gap
          false,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant RotaryWheelPainter old) => 
      old.angle != angle || old.glowIntensity != glowIntensity;
}
