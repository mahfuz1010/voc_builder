import 'package:flutter/material.dart';
import '../enums/article.dart';

class AppColors {
  AppColors._();

  // Gender colors
  static const Color derColor = Color(0xFF4FC3F7);   // blue – der
  static const Color dieColor = Color(0xFFEF9A9A);   // red  – die
  static const Color dasColor = Color(0xFFA5D6A7);   // green – das
  static const Color noneColor = Color(0xFFB0BEC5);  // grey – no article

  // Review button colors
  static const Color againColor = Color(0xFFEF5350);
  static const Color hardColor  = Color(0xFFFF7043);
  static const Color goodColor  = Color(0xFF66BB6A);
  static const Color easyColor  = Color(0xFF42A5F5);

  // Stage badge colors
  static const Color newStageColor       = Color(0xFF78909C);
  static const Color shortTermStageColor = Color(0xFFFFCA28);
  static const Color longTermStageColor  = Color(0xFF66BB6A);

  // Surfaces (dark theme defaults)
  static const Color background  = Color(0xFF121212);
  static const Color surface     = Color(0xFF1E1E1E);
  static const Color surfaceVar  = Color(0xFF2A2A2A);
  static const Color onSurface   = Color(0xFFE0E0E0);
  static const Color primary     = Color(0xFF7C4DFF);
  static const Color primaryVar  = Color(0xFF651FFF);
  static const Color secondary   = Color(0xFF03DAC6);

  static Color articleColor(Article article) {
    switch (article) {
      case Article.der:
        return derColor;
      case Article.die:
        return dieColor;
      case Article.das:
        return dasColor;
      case Article.none:
        return noneColor;
    }
  }
}
