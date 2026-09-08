import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_radius.dart';

export '../design_system/app_colors.dart';
export '../design_system/app_typography.dart';
export '../design_system/app_radius.dart';

/// Central dynamic ThemeData generator.
class AppTheme {
  AppTheme._();

  static ThemeData getTheme({
    required AppThemePreset preset,
    required Brightness brightness,
    bool isAmoled = false,
  }) {
    final AppColorTokens tokens =
        AppColors.getTokens(preset, brightness, isAmoled: isAmoled);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [tokens],
      scaffoldBackgroundColor: tokens.background,
      primaryColor: tokens.primary,
      dividerColor: tokens.divider,
      disabledColor: tokens.disabled,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.primary,
        onPrimary: Colors.white,
        secondary: tokens.secondary,
        onSecondary: Colors.white,
        error: tokens.danger,
        onError: Colors.white,
        surface: tokens.surface,
        onSurface: tokens.textPrimary,
      ),

      // ─── Card Theme ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
      ),

      // ─── AppBar Theme ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: tokens.textPrimary),
        titleTextStyle: AppTypography.titleLarge(color: tokens.textPrimary),
      ),

      // ─── Bottom Sheet Theme ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        modalBackgroundColor: tokens.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
      ),

      // ─── Dialog Theme ───────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
      ),

      // ─── Input Decoration Theme ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.searchBg,
        hintStyle: AppTypography.bodyMedium(color: tokens.hint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
      ),

      // ─── ElevatedButton Theme ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.button(color: Colors.white),
        ),
      ),

      // ─── Text Theme ─────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: tokens.textPrimary),
        displayMedium: AppTypography.displayMedium(color: tokens.textPrimary),
        headlineLarge: AppTypography.headline(color: tokens.textPrimary),
        titleLarge: AppTypography.titleLarge(color: tokens.textPrimary),
        titleMedium: AppTypography.titleMedium(color: tokens.textPrimary),
        bodyLarge: AppTypography.bodyLarge(color: tokens.textPrimary),
        bodyMedium: AppTypography.bodyMedium(color: tokens.textPrimary),
        bodySmall: AppTypography.bodySmall(color: tokens.textSecondary),
        labelLarge: AppTypography.button(color: tokens.textPrimary),
      ),

      // ─── Navigation Bar Theme ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tokens.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.primary, size: 24);
          }
          return IconThemeData(color: tokens.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: tokens.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(
            color: tokens.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
    );
  }

  // Legacy static fallbacks
  static ThemeData get light => getTheme(
      preset: AppThemePreset.kisaanGreen, brightness: Brightness.light);
  static ThemeData get dark =>
      getTheme(preset: AppThemePreset.kisaanGreen, brightness: Brightness.dark);
}
