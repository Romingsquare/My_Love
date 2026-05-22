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

    // Sort memories by date for proper left-to-right ordering
    final sortedMemories = memories.toList()..sort((a, b) => a.date.compareTo(b.date));
    
    // Group memories by day to handle same-day positioning
    final memoriesByDay = <int, List<Memory>>{};
    for (var memory in sortedMemories) {
      memoriesByDay.putIfAbsent(memory.date.day, () => []).add(memory);
    }
    
    // Calculate positions with collision avoidance
    final positions = _calculatePositions(sortedMemories, memoriesByDay, fieldWidth, fieldHeight);
    
    return Positioned(
      top: 0, left: 0, right: 0,
      height: fieldHeight,
      child: Stack(
        children: sortedMemories.asMap().entries.map((e) {
          final index  = e.key;
          final memory = e.value;
          final pos = positions[memory.id]!;

          final parallax = (cosmosShift * 0.05) % 1.0;
          final px = ((pos.xNorm - parallax) % 1.0) * fieldWidth;
          final py = pos.yNorm * fieldHeight;

          final distFromCenter = (pos.xNorm - 0.5).abs();
          final scale   = (1.0 - distFromCenter * 0.25).clamp(0.75, 1.0);
          final opacity = (1.0 - distFromCenter * 0.4).clamp(0.5, 1.0);

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

  Map<int, _NodePosition> _calculatePositions(
    List<Memory> sortedMemories,
    Map<int, List<Memory>> memoriesByDay,
    double fieldWidth,
    double fieldHeight,
  ) {
    final positions = <int, _NodePosition>{};
    final placedPositions = <_NodePosition>[];
    
    const minDistance = 0.08; // Minimum distance between nodes (8% of screen)
    const maxAttempts = 50; // Max collision resolution attempts
    
    for (var memory in sortedMemories) {
      final dayOfMonth = memory.date.day;
      final daysInMonth = DateTime(memory.date.year, memory.date.month + 1, 0).day;
      
      // X position based on day of month with margins
      final dayProgress = (dayOfMonth - 1) / math.max(1, daysInMonth - 1);
      final baseXNorm = 0.20 + dayProgress * 0.60; // 20% to 80% range
      
      // Y position: Use full vertical space more evenly
      final sameDayMemories = memoriesByDay[dayOfMonth]!;
      final sameDayIndex = sameDayMemories.indexOf(memory);
      final sameDayCount = sameDayMemories.length;
      
      // Distribute vertically across the full range
      // Use cosmosOffsetY for base randomness, then spread same-day memories
      final baseY = 0.50; // Center
      final verticalSpread = 1.0; // Use full vertical range
      
      // Random offset from cosmosOffsetY (-0.5 to +0.5) * full spread
      var yOffset = memory.cosmosOffsetY * verticalSpread;
      
      // For same-day memories, add vertical spacing
      if (sameDayCount > 1) {
        // Spread same-day memories vertically
        final sameDaySpread = 0.15; // 15% spread per memory
        yOffset += (sameDayIndex - sameDayCount / 2) * sameDaySpread;
      }
      
      var xNorm = baseXNorm + memory.cosmosOffsetX * 0.08; // Small horizontal jitter
      var yNorm = baseY + yOffset;
      
      // Clamp to safe bounds with good margins
      xNorm = xNorm.clamp(0.20, 0.80);
      yNorm = yNorm.clamp(0.20, 0.80);
      
      // Collision avoidance: try to find a position without overlap
      var attempts = 0;
      var hasCollision = true;
      
      while (hasCollision && attempts < maxAttempts) {
        hasCollision = false;
        
        for (var placed in placedPositions) {
          final dx = xNorm - placed.xNorm;
          final dy = yNorm - placed.yNorm;
          final distance = math.sqrt(dx * dx + dy * dy);
          
          if (distance < minDistance) {
            hasCollision = true;
            
            // Push away from collision
            final angle = math.atan2(dy, dx);
            xNorm += math.cos(angle) * 0.03;
            yNorm += math.sin(angle) * 0.03;
            
            // Re-clamp
            xNorm = xNorm.clamp(0.20, 0.80);
            yNorm = yNorm.clamp(0.20, 0.80);
            break;
          }
        }
        
        attempts++;
      }
      
      final position = _NodePosition(xNorm: xNorm, yNorm: yNorm);
      positions[memory.id] = position;
      placedPositions.add(position);
    }
    
    return positions;
  }
}

class _NodePosition {
  final double xNorm;
  final double yNorm;
  
  const _NodePosition({required this.xNorm, required this.yNorm});
}
