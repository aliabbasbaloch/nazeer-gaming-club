import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material 3 themes — Light & Dark with Electric Blue & Cyan palette.
class AppTheme {
  static final _dark = const AppColors(isDark: true);
  static final _light = const AppColors(isDark: false);

  // ── Light Theme ──────────────────────────────────────────────────────────

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _light.bgPage,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: _light.accent,
      surface: _light.bgCard,
      error: _light.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _light.navbar,
      foregroundColor: _light.textPrimary,
      elevation: 0,
      centerTitle: true,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _light.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _light.navbar,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: _light.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: _light.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _light.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _light.bgElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _light.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? const Color(0xFFFFFFFF)
              : _light.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? AppColors.primary
              : _light.border),
    ),
    textTheme: GoogleFonts.syneTextTheme(ThemeData.light().textTheme).copyWith(
      bodyMedium: GoogleFonts.dmSans(color: _light.textSecondary),
      bodySmall: GoogleFonts.dmSans(color: _light.textMuted),
    ),
    fontFamily: GoogleFonts.syne().fontFamily,
  );

  // ── Dark Theme ───────────────────────────────────────────────────────────

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _dark.bgPage,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: _dark.accent,
      surface: _dark.bgCard,
      error: _dark.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _dark.navbar,
      foregroundColor: _dark.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _dark.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _dark.navbar,
      selectedItemColor: _dark.accent,
      unselectedItemColor: _dark.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: _dark.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _dark.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _dark.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _dark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? _dark.accent
              : _dark.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.4)
              : _dark.border),
    ),
    textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyMedium: GoogleFonts.dmSans(color: _dark.textSecondary),
      bodySmall: GoogleFonts.dmSans(color: _dark.textMuted),
    ),
    fontFamily: GoogleFonts.syne().fontFamily,
  );
}
