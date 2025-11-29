// lib/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EduConnect Typography System
/// Headings: Poppins (Modern, Geometric, Clear)
/// Body: Inter (Readable, Professional)
class AppTypography {
  AppTypography._();

  // ==================== FONT FAMILIES ====================
  static String get headingFontFamily => GoogleFonts.poppins().fontFamily!;
  static String get bodyFontFamily => GoogleFonts.inter().fontFamily!;

  // ==================== LIGHT THEME TEXT THEME ====================
  static TextTheme lightTextTheme = TextTheme(
    // Display styles - Used for hero sections, splash screens
    displayLarge: GoogleFonts.poppins(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: const Color(0xFF212529),
      height: 1.12,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.16,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.22,
    ),

    // Headline styles - Used for screen titles, major sections
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.29,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.33,
    ),

    // Title styles - Used for card titles, list headers
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF212529),
      height: 1.27,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFF212529),
      height: 1.50,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFF212529),
      height: 1.43,
    ),

    // Body styles - Used for main content
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: const Color(0xFF212529),
      height: 1.50,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFF212529),
      height: 1.43,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFF6C757D),
      height: 1.33,
    ),

    // Label styles - Used for buttons, chips, tabs
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFF212529),
      height: 1.43,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: const Color(0xFF212529),
      height: 1.33,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: const Color(0xFF6C757D),
      height: 1.45,
    ),
  );

  // ==================== DARK THEME TEXT THEME ====================
  static TextTheme darkTextTheme = TextTheme(
    // Display styles
    displayLarge: GoogleFonts.poppins(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: const Color(0xFFF0F6FC),
      height: 1.12,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.16,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.22,
    ),

    // Headline styles
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.29,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.33,
    ),

    // Title styles
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFF0F6FC),
      height: 1.27,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFFF0F6FC),
      height: 1.50,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFFF0F6FC),
      height: 1.43,
    ),

    // Body styles
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: const Color(0xFFF0F6FC),
      height: 1.50,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFFF0F6FC),
      height: 1.43,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFF8B949E),
      height: 1.33,
    ),

    // Label styles
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFFF0F6FC),
      height: 1.43,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: const Color(0xFFF0F6FC),
      height: 1.33,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: const Color(0xFF8B949E),
      height: 1.45,
    ),
  );
}
