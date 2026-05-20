import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surface ladder (Raycast-inspired, never pure black)
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceElevated = Color(0xFF242424);
  static const surfaceOverlay = Color(0xFF2C2C2E);

  // Accents
  static const accent = Color(0xFF39FF14);
  static const accentOrange = Color(0xFFFF6B35);
  static const accentBlue = Color(0xFF4FC3F7);
  static const accentPurple = Color(0xFFCE93D8);
  static const accentYellow = Color(0xFFFFD54F);
  static const accentRed = Color(0xFFEF5350);

  // Text
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textMuted = Color(0xFF666666);

  // Borders
  static const borderSubtle = Color(0x0FFFFFFF);
  static const borderHairline = Color(0x1AFFFFFF);

  // Functional
  static const error = Color(0xFFFF4444);
  static const success = Color(0xFF39FF14);

  static const categoryColors = {
    'Coding': Color(0xFF39FF14),
    'Study': Color(0xFF4FC3F7),
    'Reading': Color(0xFFCE93D8),
    'Gym': Color(0xFFFF6B35),
    'Freelance': Color(0xFFFFD54F),
    'Deep Work': Color(0xFFEF5350),
  };
}
