import 'package:flutter/material.dart';

/// Electric Blue & Cyan dark theme color system.
class AppColors {
  final bool isDark;

  const AppColors({this.isDark = true});

  // ── Backgrounds ────────────────────────────────────────────────────────────

  static const Color bgPage = Color(0xFF080F1E);
  static const Color bgCard = Color(0xFF0E1A2E);
  static const Color navbar = Color(0xFF050D1A);
  static const Color bgElevated = Color(0xFF162236);

  // ── Brand ──────────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentDark = Color(0xFF00A8CC);

  // ── Text ───────────────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFFB0C4D8);
  static const Color textMuted = Color(0xFF4A6A8A);
  static const Color textDisabled = Color(0xFF2A3A4A);

  // ── Borders ────────────────────────────────────────────────────────────────

  static const Color border = Color(0xFF1A2A44);
  static const Color borderLight = Color(0xFF243650);

  // ── Status ─────────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF00E676);
  static const Color successBg = Color(0xFF0A2A1A);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningBg = Color(0xFF2A2000);
  static const Color danger = Color(0xFFFF5252);
  static const Color dangerBg = Color(0xFF2A0A0A);

  // ── Ball colours ───────────────────────────────────────────────────────────

  static const Color ballYellow = Color(0xFFFFD700);
  static const Color ballGreen = Color(0xFF22C55E);
  static const Color ballBrown = Color(0xFF92400E);
  static const Color ballBlue = Color(0xFF3B82F6);
  static const Color ballPink = Color(0xFFEC4899);
  static const Color ballBlack = Color(0xFF1F2937);
  static const Color ballRed = Color(0xFFEF4444);

  // ── Gradients ──────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0E2A5A), Color(0xFF061428)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtractGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ── Shadow helpers ─────────────────────────────────────────────────────────

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  List<BoxShadow> activeCardShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
