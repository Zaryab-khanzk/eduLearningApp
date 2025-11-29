// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

/// EduConnect Color Palette - Modern, Professional, Academic
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================
  // Deep Indigo - Professional and Academic
  static const Color primaryLight = Color(0xFF4C6EF5); // #4C6EF5
  static const Color primaryDark = Color(0xFF5C7CFF); // #5C7CFF

  static const Color primaryVariantLight = Color(0xFF3B5BDB); // #3B5BDB
  static const Color primaryVariantDark = Color(0xFF4263EB); // #4263EB

  // ==================== SECONDARY COLORS ====================
  // Vibrant Teal - Energetic and Modern
  static const Color secondaryLight = Color(0xFF06B6D4); // #06B6D4
  static const Color secondaryDark = Color(0xFF22D3EE); // #22D3EE

  static const Color secondaryVariantLight = Color(0xFF0891B2); // #0891B2
  static const Color secondaryVariantDark = Color(0xFF0EA5E9); // #0EA5E9

  // ==================== ACCENT COLORS ====================
  static const Color accentOrange = Color(0xFFFF922B); // #FF922B
  static const Color accentPurple = Color(0xFF9775FA); // #9775FA
  static const Color accentGreen = Color(0xFF51CF66); // #51CF66
  static const Color accentRed = Color(0xFFFF6B6B); // #FF6B6B

  // ==================== LIGHT THEME COLORS ====================
  static const Color backgroundLight = Color(0xFFF8F9FA); // #F8F9FA
  static const Color surfaceLight = Color(0xFFFFFFFF); // #FFFFFF
  static const Color cardLight = Color(0xFFFFFFFF); // #FFFFFF

  static const Color textPrimaryLight = Color(0xFF212529); // #212529
  static const Color textSecondaryLight = Color(0xFF6C757D); // #6C757D
  static const Color textTertiaryLight = Color(0xFF868E96); // #868E96

  static const Color dividerLight = Color(0xFFE9ECEF); // #E9ECEF
  static const Color borderLight = Color(0xFFDEE2E6); // #DEE2E6

  // ==================== DARK THEME COLORS ====================
  static const Color backgroundDark = Color(0xFF0D1117); // #0D1117
  static const Color surfaceDark = Color(0xFF161B22); // #161B22
  static const Color cardDark = Color(
    0xFF21262D,
  ); // #21262D - Darker for better contrast

  static const Color textPrimaryDark = Color(0xFFF0F6FC); // #F0F6FC
  static const Color textSecondaryDark = Color(0xFF8B949E); // #8B949E
  static const Color textTertiaryDark = Color(0xFF6E7681); // #6E7681

  static const Color dividerDark = Color(0xFF21262D); // #21262D
  static const Color borderDark = Color(0xFF30363D); // #30363D

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF51CF66); // #51CF66
  static const Color successDark = Color(0xFF5EDB75); // #5EDB75

  static const Color warning = Color(0xFFFCC419); // #FCC419
  static const Color warningDark = Color(0xFFFFD43B); // #FFD43B

  static const Color error = Color(0xFFFF6B6B); // #FF6B6B
  static const Color errorDark = Color(0xFFFF8787); // #FF8787

  static const Color info = Color(0xFF339AF0); // #339AF0
  static const Color infoDark = Color(0xFF4DABF7); // #4DABF7

  // ==================== GRADIENT COLORS ====================
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [Color(0xFF4C6EF5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF5C7CFF), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF9775FA), Color(0xFFFF922B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SHADOW COLORS ====================
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowDark = Color(0x33000000); // 20% black

  // ==================== OVERLAY COLORS ====================
  static const Color overlayLight = Color(0x0A000000); // 4% black
  static const Color overlayDark = Color(0x14FFFFFF); // 8% white
}
