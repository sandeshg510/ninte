import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  static const Duration extraLongDuration = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutExpo;

  // Scale animation for card press
  static Animation<double> cardScale(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
        reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  // Slide animation for staggered content
  static Animation<Offset> slideAnimation(
    AnimationController controller, {
    required double delay,
    Offset? begin,
    Offset? end,
  }) {
    return Tween<Offset>(
      begin: begin ?? const Offset(0, 0.2),
      end: end ?? Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          delay + 0.4,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  // Fade animation for content
  static Animation<double> fadeAnimation(
    AnimationController controller, {
    required double delay,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          delay + 0.4,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  // Scale animation for achievements
  static Animation<double> achievementScale(
    AnimationController controller, {
    required double delay,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          delay + 0.4,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  // Progress animation
  static Animation<double> progressAnimation(
    AnimationController controller, {
    required double begin,
    required double end,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0,
          0.8,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
} 