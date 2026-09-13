import 'package:flutter/material.dart';

/// Skillora Global Color System - Premium Dark Theme (Skill Pathways Aesthetic)
class AppColors {
  // Brand Primary (Vibrant Purple Accent #6C5CE7 / #7C5CFC)
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
    colors: [Color(0xFF0F1017), Color(0xFF13141C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Surface & Background Colors (Dark Charcoal Aesthetic)
  static const Color backgroundLight = Color(0xFF0F1017); // Default to Dark System
  static const Color surfaceLight = Color(0xFF181924);
  static const Color cardLight = Color(0xFF181924);
  
  static const Color backgroundDark = Color(0xFF0F1017);
  static const Color surfaceDark = Color(0xFF181924);
  static const Color cardDark = Color(0xFF181924);
  static const Color navBackgroundDark = Color(0xFF12131C);
  static const Color inputBackgroundDark = Color(0xFF181924);

  // Soft Subtle Card Shadow & Borders
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  // Typography Colors (Dark Mode Default)
  static const Color headingDark = Color(0xFFFFFFFF); // Pure white bold
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF94A3B8);
  static const Color textMutedLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Badges (Dark Mode Adapted)
  static const Color pastelMintBg = Color(0x1F0D9488);
  static const Color pastelMintText = Color(0xFF2DD4BF);

  static const Color pastelOrangeBg = Color(0x1FEA580C);
  static const Color pastelOrangeText = Color(0xFFFB923C);

  static const Color pastelPinkBg = Color(0x1FDB2777);
  static const Color pastelPinkText = Color(0xFFF472B6);

  static const Color pastelBlueBg = Color(0x1F0284C7);
  static const Color pastelBlueText = Color(0xFF38BDF8);

  static const Color pastelPurpleBg = Color(0x266C5CE7);
  static const Color pastelPurpleText = Color(0xFFA78BFA);

  // Legacy & Compatibility Aliases
  static const Color cyan = Color(0xFF8B7CF6);
  static const Color cyanLight = Color(0x1F8B7CF6);
  static const Color cyanSoft = Color(0x1F6C5CE7);
  static const Color accentPurple = Color(0xFF6C5CE7);
  static const Color borderLight = Color(0xFF262836);
  static const Color borderDark = Color(0xFF262836);
  static const Color borderCyanGlow = Color(0x336C5CE7);

  static const Color softBlue = Color(0x1F6C5CE7);
  static const Color softBlueDark = Color(0x336C5CE7);
  static const Color softBlueBackground = Color(0xFF181924);
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
