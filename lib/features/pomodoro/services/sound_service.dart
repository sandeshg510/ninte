import 'package:flutter/services.dart';
import 'dart:developer' as dev;

/// Service for handling Pomodoro timer feedback
class SoundService {
  bool _isInitialized = false;
  
  Future<void> init() async {
    try {
      dev.log('[SoundService] Initializing feedback service');
      await HapticFeedback.mediumImpact(); // Initial test vibration
      _isInitialized = true;
      dev.log('[SoundService] Feedback service initialized successfully');
    } catch (e) {
      dev.log('[SoundService] Failed to initialize feedback service: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> playTick() async {
    try {
      dev.log('[SoundService] Playing tick feedback');
      await HapticFeedback.selectionClick();
      dev.log('[SoundService] Tick feedback played successfully');
    } catch (e) {
      dev.log('[SoundService] Error playing tick feedback: $e');
      // Try fallback vibration
      try {
        await HapticFeedback.vibrate();
        dev.log('[SoundService] Fallback vibration successful');
      } catch (e) {
        dev.log('[SoundService] Fallback vibration failed: $e');
      }
    }
  }
  
  Future<void> playStart() async {
    try {
      dev.log('[SoundService] Playing start feedback');
      await HapticFeedback.heavyImpact();
      dev.log('[SoundService] Start feedback played successfully');
    } catch (e) {
      dev.log('[SoundService] Error playing start feedback: $e');
    }
  }
  
  Future<void> playPause() async {
    try {
      dev.log('[SoundService] Playing pause feedback');
      await HapticFeedback.mediumImpact();
      dev.log('[SoundService] Pause feedback played successfully');
    } catch (e) {
      dev.log('[SoundService] Error playing pause feedback: $e');
    }
  }
  
  Future<void> playReset() async {
    try {
      dev.log('[SoundService] Playing reset feedback');
      await HapticFeedback.lightImpact();
      dev.log('[SoundService] Reset feedback played successfully');
    } catch (e) {
      dev.log('[SoundService] Error playing reset feedback: $e');
    }
  }
  
  Future<void> playTimerComplete() async {
    try {
      dev.log('[SoundService] Playing complete feedback');
      // Pattern: heavy - delay - medium - delay - light
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.lightImpact();
      dev.log('[SoundService] Complete feedback played successfully');
    } catch (e) {
      dev.log('[SoundService] Error playing complete feedback: $e');
      // Try fallback vibration
      try {
        await HapticFeedback.vibrate();
        dev.log('[SoundService] Fallback vibration successful');
      } catch (e) {
        dev.log('[SoundService] Fallback vibration failed: $e');
      }
    }
  }
  
  void dispose() {
    _isInitialized = false;
    dev.log('[SoundService] Feedback service disposed');
  }
} 