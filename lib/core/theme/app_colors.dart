import 'package:flutter/material.dart';

/// Dual-theme color system — Electric Blue & Cyan.
/// All tokens branch on [isDark] to return correct light or dark value.
class AppColors {
  final bool isDark;

  const AppColors({this.isDark = true});

  /// Convenience: derive from current theme brightness.
  static AppColors of(BuildContext context) {
    return AppColors(isDark: Theme.of(context).brightness == Brightness.dark);
  }

  // ── Backgrounds ────────────────────────────────────────────────────────────

  Color get bgPage => isDark ? const Color(0xFF080F1E) : const Color(0xFFF5F7FA);
  Color get bgCard => isDark ? const Color(0xFF0E1A2E) : const Color(0xFFFFFFFF);
  Color get navbar => isDark ? const Color(0xFF050D1A) : const Color(0xFFFFFFFF);
  Color get bgElevated => isDark ? const Color(0xFF162236) : const Color(0xFFEEF2F7);

  // ── Brand ──────────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  Color get accent => isDark ? const Color(0xFF00D4FF) : const Color(0xFF0099DD);
  Color get accentDark => isDark ? const Color(0xFF00A8CC) : const Color(0xFF007AB8);

  // ── Text ───────────────────────────────────────────────────────────────────

  Color get textPrimary => isDark ? const Color(0xFFE8F4FF) : const Color(0xFF0A1628);
  Color get textSecondary => isDark ? const Color(0xFFB0C4D8) : const Color(0xFF334155);
  Color get textMuted => isDark ? const Color(0xFF4A6A8A) : const Color(0xFF64748B);
  Color get textDisabled => isDark ? const Color(0xFF2A3A4A) : const Color(0xFFCBD5E1);

  // ── Borders ────────────────────────────────────────────────────────────────

  Color get border => isDark ? const Color(0xFF1A2A44) : const Color(0xFFDDE3ED);
  Color get borderLight => isDark ? const Color(0xFF243650) : const Color(0xFFEEF2F7);

  // ── Status ─────────────────────────────────────────────────────────────────

  Color get success => isDark ? const Color(0xFF00E676) : const Color(0xFF059669);
  Color get successBg => isDark ? const Color(0xFF0A2A1A) : const Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFFFB300);
  Color get warningBg => isDark ? const Color(0xFF2A2000) : const Color(0xFFFEF9C3);
  Color get danger => isDark ? const Color(0xFFFF5252) : const Color(0xFFDC2626);
  Color get dangerBg => isDark ? const Color(0xFF2A0A0A) : const Color(0xFFFFE4E4);

  // ── Ball colours (same in both themes) ─────────────────────────────────────

  static const Color ballYellow = Color(0xFFFFD700);
  static const Color ballGreen = Color(0xFF22C55E);
  static const Color ballBrown = Color(0xFF92400E);
  static const Color ballBlue = Color(0xFF3B82F6);
  static const Color ballPink = Color(0xFFEC4899);
  static const Color ballBlack = Color(0xFF1F2937);
  static const Color ballRed = Color(0xFFEF4444);

  // ── Player colours ──────────────────────────────────────────────────────────

  static const List<Color> playerColors = [
    Color(0xFF0066FF),  // 0  electric blue
    Color(0xFF00D4FF),  // 1  cyan
    Color(0xFF00E676),  // 2  green
    Color(0xFFFFB300),  // 3  amber
    Color(0xFFFF5252),  // 4  red
    Color(0xFFAA66FF),  // 5  purple
    Color(0xFFFF66CC),  // 6  pink
    Color(0xFFFF8C00),  // 7  orange
    Color(0xFF26C6DA),  // 8  teal
    Color(0xFF9CCC65),  // 9  lime
    Color(0xFFEF9A9A),  // 10 rose
    Color(0xFF80CBC4),  // 11 mint
  ];

  // ── Gradients ──────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  LinearGradient get cardGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF0D2D6B), Color(0xFF071A40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFDBEAFF), Color(0xFFEEF5FF)],
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
