// lib/features/rotary_wheel/rotary_wheel_controller.dart
//
// Reverted to the original angular physics controller.
// Calculates angle from the globe center, snaps to months magnetically.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class RotaryWheelController extends ChangeNotifier {
  double _angle = 0.0;
  double _velocity = 0.0; 
  bool _isDragging = false;
  
  double? _lastTouchAngle;
  late final Ticker _ticker;
  Duration? _lastTickTime;
  
  int? _lastActiveMonth;
  
  static const int _baseYear = 2024;
  
  RotaryWheelController(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
    
    // Initialize with current month to prevent sound on app startup
    final fractionalMonth = (_angle / (2 * math.pi)) * 12;
    final nearestMonthTick = fractionalMonth.round();
    _lastActiveMonth = (nearestMonthTick % 12 + 12) % 12;
  }
  
  double get angle => _angle;
  
  double get fractionalMonth {
    final pos = (_angle / (2 * math.pi)) * 12;
    return pos % 12;
  }
  
  int get currentYear {
    final totalMonths = (_angle / (2 * math.pi) * 12).floor();
    return _baseYear + (totalMonths / 12).floor();
  }
  
  int get currentMonth {
    final m = fractionalMonth.round() % 12;
    return m <= 0 ? m + 12 : m;
  }
  
  void _onTick(Duration elapsed) {
    if (_isDragging || _lastTickTime == null) {
      _lastTickTime = elapsed;
      return;
    }
    
    final dt = (elapsed - _lastTickTime!).inMicroseconds / 1e6;
    _lastTickTime = elapsed;
    
    _velocity *= math.pow(0.88, dt * 60).toDouble();
    
    final oldAngle = _angle;
    _angle += _velocity * dt;
    
    // Check if we crossed a month boundary
    _checkMonthCrossing(oldAngle, _angle);
    
    if (_velocity.abs() < 0.08) {
      _velocity = 0;
      _snapToNearestMonth();
    } else {
      notifyListeners();
    }
  }
  
  void onPanStart(Offset position, Offset globeCenter) {
    _isDragging = true;
    _velocity = 0;
    _lastTouchAngle = _touchAngle(position, globeCenter);
    _lastTickTime = null;
  }
  
  void onPanUpdate(Offset position, Offset globeCenter) {
    final currentTouchAngle = _touchAngle(position, globeCenter);
    if (_lastTouchAngle == null) {
      _lastTouchAngle = currentTouchAngle;
      return;
    }
    
    var delta = currentTouchAngle - _lastTouchAngle!;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    
    // Invert delta so swiping right (positive delta) decreases angle,
    // making elements move right to follow the finger.
    final oldAngle = _angle;
    _angle -= delta;
    
    // Check if we crossed a month boundary during drag
    _checkMonthCrossing(oldAngle, _angle);
    
    _velocity = -delta * 60; 
    _lastTouchAngle = currentTouchAngle;
    notifyListeners();
  }
  
  void onPanEnd(Offset velocity, Offset globeCenter) {
    _isDragging = false;
    _velocity = velocity.dx / 200.0 * -1;
    _lastTickTime = null;
  }
  
  void _snapToNearestMonth() {
    final monthAngle = 2 * math.pi / 12;
    final nearest = (_angle / monthAngle).round() * monthAngle;
    final delta = nearest - _angle;
    
    if (delta.abs() < 0.001) {
      _angle = nearest;
      notifyListeners();
      return;
    }
    
    _angle += delta * 0.15;
    if ((nearest - _angle).abs() > 0.002) {
      _velocity = delta * 0.15 * 60;
    } else {
      _angle = nearest;
      HapticFeedback.lightImpact();
    }
    notifyListeners();
  }
  
  void _checkMonthCrossing(double oldAngle, double newAngle) {
    // Calculate fractional month position (same as in the painter)
    final fractionalMonth = (newAngle / (2 * math.pi)) * 12;
    
    // Find the nearest month tick
    final nearestMonthTick = fractionalMonth.round();
    final distance = (nearestMonthTick - fractionalMonth).abs();
    
    // A month is "active" (yellow) when distance < 0.5
    // This matches the visual logic in RotaryWheelPainter
    final isActive = distance < 0.5;
    
    if (isActive) {
      // Normalize month index to 0-11 range
      final activeMonthIndex = (nearestMonthTick % 12 + 12) % 12;
      
      // Play sound when a NEW month becomes active
      if (_lastActiveMonth != activeMonthIndex) {
        _lastActiveMonth = activeMonthIndex;
        _playTickSound();
      }
    }
  }
  
  void _playTickSound() async {
    try {
      // Create a new player instance for each tick to allow overlapping sounds
      final player = AudioPlayer();
      await player.setAsset('assets/sounds/tick.mp3');
      await player.setVolume(0.6);
      await player.play();
      
      // Dispose after playing
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      // Silently fail if audio can't play
    }
  }
  
  double _touchAngle(Offset position, Offset globeCenter) {
    final dx = position.dx - globeCenter.dx;
    final dy = position.dy - globeCenter.dy;
    return math.atan2(dx, -dy); 
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
