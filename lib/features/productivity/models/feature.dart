import 'package:flutter/material.dart';

enum FeatureType {
  pomodoro,
  sleepHelper,
  fatLoss,
  meditation,
  habitTracking,
  moodTracking,
  journaling,
  goalSetting,
  waterTracking,
  exerciseTracking,
}

class ProductivityFeature {
  final String name;
  final String description;
  final FeatureType type;
  final IconData icon;
  final bool isPremium;

  const ProductivityFeature({
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    this.isPremium = false,
  });

  static List<ProductivityFeature> get allFeatures => [
    ProductivityFeature(
      name: 'Pomodoro Timer',
      description: 'Focus timer with customizable work/break intervals',
      type: FeatureType.pomodoro,
      icon: Icons.timer,
    ),
    ProductivityFeature(
      name: 'Sleep Helper',
      description: 'Track and improve your sleep patterns',
      type: FeatureType.sleepHelper,
      icon: Icons.bedtime,
      isPremium: true,
    ),
    ProductivityFeature(
      name: 'Fat Loss Tracker',
      description: 'Track your weight loss journey',
      type: FeatureType.fatLoss,
      icon: Icons.fitness_center,
    ),
    ProductivityFeature(
      name: 'Meditation',
      description: 'Guided meditation sessions',
      type: FeatureType.meditation,
      icon: Icons.self_improvement,
      isPremium: true,
    ),
    ProductivityFeature(
      name: 'Mood Tracking',
      description: 'Monitor your daily emotional state',
      type: FeatureType.moodTracking,
      icon: Icons.emoji_emotions,
    ),
    ProductivityFeature(
      name: 'Journaling',
      description: 'Daily reflection and gratitude journal',
      type: FeatureType.journaling,
      icon: Icons.book,
    ),
    // Add more features...
  ];
} 