import 'package:flutter/material.dart';

/// Sealed color token system for Songify (Juicy Aesthetic).
/// Matches the deep, neon-purple dark mode aesthetic from the mockup.
abstract final class AppColors {
  // --- Background ---
  static const Color background = Color(0xFF070709); // Deepest black
  static const Color surface = Color(0xFF101015);    // Slightly elevated
  static const Color surfaceElevated = Color(0xFF181820); // Cards

  // --- Brand / Accent (The "Juicy" Purple) ---
  static const Color accent = Color(0xFFA724FF);       // Neon purple
  static const Color accentSoft = Color(0xFFD67BFF);   // Lighter pink/purple
  static const Color accentDark = Color(0xFF4A0E7A);   // Deep purple for backgrounds
  static const Color accentGlow = Color(0x66A724FF);   // Neon purple glow

  // --- Text ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textMuted = Color(0xFF606075);

  // --- Controls ---
  static const Color divider = Color(0xFF20202A);
  static const Color iconDefault = Color(0xFF808095);
  static const Color iconActive = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF4ECCA3);
  static const Color error = Color(0xFFFF4B4B);

  // --- Glass / Frosted ---
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // --- Gradients ---
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C16E0), Color(0xFFD546F9)],
  );
  
  static const LinearGradient subtlePurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x336C16E0), Color(0x1AD546F9)],
  );
}
