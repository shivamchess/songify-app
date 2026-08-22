import 'package:flutter/material.dart';

/// JUICY — Juicy Lofi Aesthetic color system.
abstract final class AppColors {
  // --- Backgrounds ---
  static const Color background     = Color(0xFF08081A);  // Deep navy black
  static const Color surface        = Color(0xFF0F0F28);  // Card surface
  static const Color surfaceElevated= Color(0xFF181836);  // Elevated card

  // --- Primary Accent (Violet) ---
  static const Color accent         = Color(0xFF7C3AED);
  static const Color accentSoft     = Color(0xFFA78BFA);
  static const Color accentGlow     = Color(0x447C3AED);

  // --- Warm Secondary (for "corny" feel) ---
  static const Color warm           = Color(0xFFF59E0B);  // Amber
  static const Color pink           = Color(0xFFEC4899);  // Pink for liked

  // --- Text ---
  static const Color textPrimary    = Color(0xFFF0F0FF);
  static const Color textSecondary  = Color(0xFF8888AA);
  static const Color textMuted      = Color(0xFF444466);

  // --- UI ---
  static const Color divider        = Color(0xFF1E1E40);
  static const Color iconDefault    = Color(0xFF6666AA);
  static const Color iconActive     = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success        = Color(0xFF34D399);
  static const Color error          = Color(0xFFFF6B6B);

  // --- Glass ---
  static const Color glassFill      = Color(0x14FFFFFF);
  static const Color glassBorder    = Color(0x20FFFFFF);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  );
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );
}
