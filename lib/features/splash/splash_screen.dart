// lib/features/splash/splash_screen.dart
//
// Cinematic splash — the portal into the memory universe.
// Sequence:
//  1. Deep space fades in (200ms delay)
//  2. CHRONOS ARCHIVE wordmark materializes (letter by letter feel via opacity)
//  3. Tagline drifts up
//  4. Globe materializes from bottom
//  5. Crossfades to Cosmos screen after 3s

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../cosmos/cosmos_screen.dart';
import '../rotary_wheel/rotary_wheel_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _globeCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.cosmosBlack,
    ));

    _globeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Navigate after cinematic intro
    Future.delayed(const Duration(milliseconds: 3200), _navigateToCosmos);
  }

  void _navigateToCosmos() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CosmosScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _globeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.cosmosBlack,
      body: Stack(
        children: [
          // ── Space background particles ──────────────────────
          _SplashStars(size: size),

          // ── Content ────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo mark
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glowGold.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowGold.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.glowGold,
                    size: 26,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 800.ms)
                .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOut),

                const SizedBox(height: 28),

                // Wordmark
                Text(
                  'CHRONOS ARCHIVE',
                  style: AppTextStyles.appBarTitle.copyWith(
                    fontSize: 16,
                    letterSpacing: 7,
                    color: AppColors.warmAmber,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 1000.ms),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'your memory universe',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.dimGrey,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontStyle: FontStyle.italic,
                  ),
                )
                .animate()
                .fadeIn(delay: 900.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),

          // ── Globe materializing from bottom ────────────────
          Positioned(
            bottom: -size.height * 0.22,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: AnimatedBuilder(
              animation: Listenable.merge([_globeCtrl, _glowCtrl]),
              builder: (context, child) => CustomPaint(
                painter: RotaryWheelPainter(
                  angle: _globeCtrl.value * math.pi * 2,
                  glowIntensity: _glowCtrl.value,
                  radius: size.width * 0.65,
                  center: Offset(size.width / 2, size.height * 0.55 + size.width * 0.65 * 0.15),
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(delay: 400.ms, duration: 1200.ms)
          .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

// Static star background for splash
class _SplashStars extends StatelessWidget {
  final Size size;
  const _SplashStars({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _SplashStarPainter(),
    );
  }
}

class _SplashStarPainter extends CustomPainter {
  static final _stars = _gen();

  static List<({double x, double y, double r, double o})> _gen() {
    final rand = math.Random(99);
    return List.generate(180, (_) => (
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      r: 0.3 + rand.nextDouble() * 1.2,
      o: 0.1 + rand.nextDouble() * 0.5,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in _stars) {
      paint.color = Colors.white.withValues(alpha: s.o);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
