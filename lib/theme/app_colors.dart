import 'package:flutter/material.dart';

/// Skillora Global Color System - Clean Modern Productivity Theme
class AppColors {
  // Brand Primary (Rich Violet-Purple Gradient #6C5CE7 to #8B7CF6)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF6);
  static const Color primaryDark = Color(0xFF5B4BC4);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Surface & Background Colors (Clean White Throughout)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);

  // Soft Subtle Card Shadow (No borders, no glow)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  // Typography Colors
  static const Color headingDark = Color(0xFF0F172A); // Bold near-black
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B); // Medium-gray
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Pastel Stat/Status Tile Color Palette
  static const Color pastelMintBg = Color(0xFFE6FFFA);
  static const Color pastelMintText = Color(0xFF0D9488);

  static const Color pastelOrangeBg = Color(0xFFFFF7ED);
  static const Color pastelOrangeText = Color(0xFFEA580C);

  static const Color pastelPinkBg = Color(0xFFFDF2F8);
  static const Color pastelPinkText = Color(0xFFDB2777);

  static const Color pastelBlueBg = Color(0xFFF0F9FF);
  static const Color pastelBlueText = Color(0xFF0284C7);

  // Legacy & Compatibility Aliases
  static const Color cyan = Color(0xFF8B7CF6);
  static const Color cyanLight = Color(0xFFF0F9FF);
  static const Color cyanSoft = Color(0x1F6C5CE7);
  static const Color accentPurple = Color(0xFF6C5CE7);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderCyanGlow = Color(0x336C5CE7);

  static const Color softBlue = Color(0x1F6C5CE7);
  static const Color softBlueDark = Color(0x336C5CE7);
  static const Color softBlueBackground = Color(0xFFF8FAFC);
  static const Color lavender = Color(0xFF6C5CE7);
  static const Color lavenderLight = Color(0x266C5CE7);
  static const Color lavenderSoft = Color(0x336C5CE7);

  // Status & Badges
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x2610B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0x26F59E0B);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0x26EF4444);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0x263B82F6);
}
