// lib/features/cosmos/cosmos_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/memory_model.dart';
import '../rotary_wheel/rotary_wheel_controller.dart';
import '../rotary_wheel/rotary_wheel_widget.dart';
import 'widgets/star_field_painter.dart';
import 'widgets/memory_node_widget.dart';
import 'providers/cosmos_providers.dart';
import '../memory_detail/memory_detail_screen.dart';

class CosmosScreen extends ConsumerStatefulWidget {
  const CosmosScreen({super.key});

  @override
  ConsumerState<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends ConsumerState<CosmosScreen> with TickerProviderStateMixin {
  late final RotaryWheelController _wheelController;
  late final AnimationController _glowBreathCtrl;
  late final AnimationController _twinkleCtrl;

  @override
  void initState() {
    super.initState();
    _wheelController = RotaryWheelController(this);
    _glowBreathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _twinkleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _wheelController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _glowBreathCtrl.dispose();
    _twinkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final year  = _wheelController.currentYear;
    final month = _wheelController.currentMonth;
    final rotAngle = _wheelController.angle;

    final dialAreaHeight = size.height * 0.35; // The bottom area strictly for the dial

    final memories = ref.watch(visibleMemoriesProvider((year: year, month: month)));

    return Scaffold(
      backgroundColor: AppColors.cosmosBlack,
      body: Stack(
        children: [
          // ── Background ────────────────────────────
          Container(decoration: const BoxDecoration(gradient: AppColors.cosmosBackground)),

          // ── Stars ──────────────────────────────────────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _twinkleCtrl,
              builder: (context, child) => CustomPaint(
                size: Size(size.width, size.height * 0.75),
                painter: StarFieldPainter(
                  cosmosShift: rotAngle / (2 * math.pi),
                  twinklePhase: _twinkleCtrl.value * math.pi * 2,
                ),
              ),
            ),
          ),

          // ── Year Watermark ──────────────────────────────────
          Positioned(
            top: size.height * 0.10,
            left: 0, right: 0,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: AppDurations.cinematic,
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: Text(
                  '$year',
                  key: ValueKey(year),
                  style: AppTextStyles.yearMarker,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // ── Constellations ────────────────────────────────────
          _MemoryConstellation(
            memories: memories,
            screenSize: size,
            cosmosShift: rotAngle / (2 * math.pi),
            year: year,
            month: month,
            onNodeTap: _onNodeTap,
          ),

          // ── Depth Gradient ────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.45,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.cosmosBlack.withValues(alpha: 0.45),
                      AppColors.cosmosBlack,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Top Bar ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(child: _TopBar(memoryCount: memories.length)),
          ),

          // ── Rotary Arc Wheel ─────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: dialAreaHeight,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _glowBreathCtrl,
                builder: (context, child) => RotaryWheelWidget(
                  controller: _wheelController,
                  glowIntensity: _glowBreathCtrl.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNodeTap(Memory memory) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MemoryDetailScreen(memory: memory),
        transitionsBuilder: (context, anim, secondaryAnimation, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: AppCurves.memoryReveal),
          child: child,
        ),
        transitionDuration: AppDurations.cinematic,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int memoryCount;
  const _TopBar({required this.memoryCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [_dot(1), const SizedBox(width: 4), _dot(1), const SizedBox(width: 4), _dot(0.5)]),
              const SizedBox(height: 4),
              Row(children: [_dot(1), const SizedBox(width: 4), _dot(0.5), const SizedBox(width: 4), _dot(1)]),
            ],
          ),
          const Spacer(),
          Text('CHRONOS ARCHIVE', style: AppTextStyles.appBarTitle),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.glowGold)),
                const SizedBox(width: 5),
                Text('$memoryCount', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _dot(double opacity) => Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.glowGold.withValues(alpha: opacity * 0.8)));
}

class _MemoryConstellation extends StatelessWidget {
  final List<Memory> memories;
  final Size screenSize;
  final double cosmosShift;
  final int year;
  final int month;
  final void Function(Memory) onNodeTap;

  const _MemoryConstellation({
    required this.memories,
    required this.screenSize,
    required this.cosmosShift,
    required this.year,
    required this.month,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) return const SizedBox.shrink();

    final fieldWidth  = screenSize.width;
    final fieldHeight = screenSize.height * 0.65;

    return Positioned(
      top: 0, left: 0, right: 0,
      height: fieldHeight,
      child: Stack(
        children: memories.asMap().entries.map((e) {
          final index  = e.key;
          final memory = e.value;

          final monthDiff = (memory.date.year - year) * 12 + (memory.date.month - month);
          final xNorm = 0.5 + memory.cosmosOffsetX + monthDiff * 0.14;
          // Use memory's own cosmosOffsetY for positioning (no index stacking)
          // This allows multiple memories on same day to appear at different heights
          final yNorm = 0.35 + memory.cosmosOffsetY;

          final parallax = (cosmosShift * 0.05) % 1.0;
          final px = ((xNorm - parallax) % 1.0) * fieldWidth;
          final py = yNorm.clamp(0.20, 0.75) * fieldHeight;

          final distFromCenter = (xNorm - 0.5).abs();
          final scale   = (1.0 - distFromCenter * 0.4).clamp(0.65, 1.0);
          final opacity = (1.0 - distFromCenter * 0.6).clamp(0.3, 1.0);

          return Positioned(
            left: px - 60,
            top:  py - 30,
            child: MemoryNodeWidget(
              memory: memory,
              onTap: () => onNodeTap(memory),
              scale: scale,
              opacity: opacity,
              animIndex: index,
            ).animate().fadeIn(
              delay: Duration(milliseconds: 80 + index * 70),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }).toList(),
      ),
    );
  }
}
