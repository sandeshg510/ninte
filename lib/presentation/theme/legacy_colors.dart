import 'package:flutter/material.dart';

/// This class helps maintain backward compatibility with the old color system
@Deprecated('Use AppColors from app_theme.dart instead')
class LegacyColors {
  // Base colors
  static const deepBlack = Color(0xFF1C1B1F);
  static const surfaceBlack = Color(0xFF252429);
  
  // Text colors
  static const pureWhite = Color(0xFFFFFFFF);
  static const textGrey = Color(0xFFB4B4BB);
  static const subtleGrey = Color(0xFF8E8E96);
  
  // Accent colors
  static const accentBlue = Color(0xFF4A9FFF);
  
  // Gradient colors
  static const gradientStart = Color(0xFFFF6B4A);
  static const gradientEnd = Color(0xFFFF8A6F);
} 