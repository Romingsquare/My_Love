// lib/features/cosmos/widgets/memory_node_widget.dart
//
// Each memory appears as a glowing constellation node in the cosmos.
// Nodes have:
//  - A pulsing glow ring
//  - An emoji/icon center
//  - Title + date label below (with dotted connector line)
//  - Floating vertical oscillation animation
//  - Scale based on depth layer

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/memory_model.dart';

class MemoryNodeWidget extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;
  final double scale;      // 0.6..1.0 based on depth layer
  final double opacity;    // fade based on temporal distance
  final int animIndex;     // stagger offset for floating animation

  const MemoryNodeWidget({
    super.key,
    required this.memory,
    required this.onTap,
    this.scale   = 1.0,
    this.opacity = 1.0,
    this.animIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = Color(memory.moodColorValue);
    final icon = _iconForKey(memory.iconKey);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Glow Node ───────────────────────────────
              _GlowNode(color: nodeColor, icon: icon, index: animIndex),

              // ── Dotted connector line ───────────────────
              _DottedLine(color: nodeColor),

              const SizedBox(height: 4),

              // ── Memory title ────────────────────────────
              Text(
                memory.title,
                style: AppTextStyles.nodeTitleStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),

              const SizedBox(height: 2),

              // ── Date label ──────────────────────────────
              Text(
                _formatDate(memory.date),
                style: AppTextStyles.nodeDateStyle,
              ),
            ],
          ),
        )
        // Floating oscillation animation
        .animate(
          onPlay: (c) => c.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -5,
          duration: Duration(milliseconds: 2800 + animIndex * 300),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case MemoryIcon.camera:  return Icons.photo_camera_outlined;
      case MemoryIcon.heart:   return Icons.favorite_outline;
      case MemoryIcon.music:   return Icons.music_note_outlined;
      case MemoryIcon.plane:   return Icons.flight_outlined;
      case MemoryIcon.book:    return Icons.menu_book_outlined;
      case MemoryIcon.coffee:  return Icons.coffee_outlined;
      case MemoryIcon.sparkle: return Icons.auto_awesome_outlined;
      case MemoryIcon.leaf:    return Icons.eco_outlined;
      default:                 return Icons.star_outline;
    }
  }
}

// ── Glow Node ──────────────────────────────────────────────────────────────
class _GlowNode extends StatelessWidget {
  final Color color;
  final IconData icon;
  final int index;

  const _GlowNode({required this.color, required this.icon, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer atmospheric glow
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.25),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0, end: 1.3,
            duration: Duration(milliseconds: 2200 + index * 200),
            curve: Curves.easeInOut,
          ),

          // Mid ring
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
          ),

          // Core circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, size: 13, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Dotted connector line ──────────────────────────────────────────────────
class _DottedLine extends StatelessWidget {
  final Color color;
  const _DottedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(1, 16),
      painter: _DottedLinePainter(color: color),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  const _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const dotSpacing = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + 1.5), paint);
      y += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
