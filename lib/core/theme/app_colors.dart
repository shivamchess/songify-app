import 'package:flutter/material.dart';

/// JUICY color system — deep black + neon purple from mockup.
abstract final class AppColors {
  // --- Background ---
  static const Color background = Color(0xFF070709);
  static const Color surface = Color(0xFF0D0D12);
  static const Color surfaceElevated = Color(0xFF1A1A24);

  // --- Accent (Neon Purple) ---
  static const Color accent = Color(0xFFA724FF);
  static const Color accentSoft = Color(0xFFC77DFF);
  static const Color accentGlow = Color(0x33A724FF);

  // --- Text ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color textMuted = Color(0xFF5A5A72);

  // --- Controls ---
  static const Color divider = Color(0xFF2A2A38);
  static const Color iconDefault = Color(0xFF7070A0);
  static const Color iconActive = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF4ECCA3);
  static const Color error = Color(0xFFFF6B6B);

  // --- Glass ---
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
}
