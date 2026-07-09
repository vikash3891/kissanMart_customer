import 'package:flutter/material.dart';

enum AppThemePreset {
  kisaanGreen,
  blinkitYellow,
  zeptoPurple,
  bigBasketGreen,
  oceanBlue,
  modernOrange,
  minimalBlack,
  elegantDark,
}

extension AppThemePresetExtension on AppThemePreset {
  String get nameDisplay {
    switch (this) {
      case AppThemePreset.kisaanGreen:
        return 'Kisaan Green';
      case AppThemePreset.blinkitYellow:
        return 'Blinkit Yellow';
      case AppThemePreset.zeptoPurple:
        return 'Zepto Purple';
      case AppThemePreset.bigBasketGreen:
        return 'BigBasket Green';
      case AppThemePreset.oceanBlue:
        return 'Ocean Blue';
      case AppThemePreset.modernOrange:
        return 'Modern Orange';
      case AppThemePreset.minimalBlack:
        return 'Minimal Black';
      case AppThemePreset.elegantDark:
        return 'Elegant Dark';
    }
  }

  Color get previewColor {
    switch (this) {
      case AppThemePreset.kisaanGreen:
        return const Color(0xFF168A3A);
      case AppThemePreset.blinkitYellow:
        return const Color(0xFFF8C000);
      case AppThemePreset.zeptoPurple:
        return const Color(0xFF4C0082);
      case AppThemePreset.bigBasketGreen:
        return const Color(0xFF689F38);
      case AppThemePreset.oceanBlue:
        return const Color(0xFF0066CC);
      case AppThemePreset.modernOrange:
        return const Color(0xFFFF6E14);
      case AppThemePreset.minimalBlack:
        return const Color(0xFF222222);
      case AppThemePreset.elegantDark:
        return const Color(0xFF1A237E);
    }
  }
}

class AppColorTokens {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color disabled;
  final Color hint;
  final Color badge;
  final Color coupon;
  final Color rating;
  final Color organic;
  final Color offer;
  final Color delivery;
  final Color wishlist;
  final Color flashSale;
  final Color searchBg;
  final Color navigationBg;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color skeleton;

  const AppColorTokens({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.disabled,
    required this.hint,
    required this.badge,
    required this.coupon,
    required this.rating,
    required this.organic,
    required this.offer,
    required this.delivery,
    required this.wishlist,
    required this.flashSale,
    required this.searchBg,
    required this.navigationBg,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.skeleton,
  });
}

class AppColors {
  AppColors._();

  // Legacy fallbacks for compatibility with existing imports
  static const Color kGreen = Color(0xFF168A3A);
  static const Color kDarkGreen = Color(0xFF075C2A);
  static const Color kLightGreen = Color(0xFFEAF8EC);
  static const Color kBg = Color(0xFFF6F7FB);
  static const Color kOrange = Color(0xFFFF8A3D);
  static const Color kYellow = Color(0xFFFFF1C2);
  static const Color kDark = Color(0xFF24272D);

  // Common universal colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static AppColorTokens getTokens(
    AppThemePreset preset,
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    final bool isDark = brightness == Brightness.dark;

    // AMOLED background overrides when dark mode + AMOLED is enabled
    final Color bg = isDark
        ? (isAmoled ? const Color(0xFF000000) : const Color(0xFF121212))
        : const Color(0xFFF6F7FB);
    final Color surface = isDark
        ? (isAmoled ? const Color(0xFF090909) : const Color(0xFF1E1E1E))
        : const Color(0xFFFFFFFF);
    final Color card = isDark
        ? (isAmoled ? const Color(0xFF101010) : const Color(0xFF242424))
        : const Color(0xFFFFFFFF);
    final Color border =
        isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color divider =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEDF2F7);
    final Color textPri =
        isDark ? const Color(0xFFF7FAFC) : const Color(0xFF1A202C);
    final Color textSec =
        isDark ? const Color(0xFFA0AEC0) : const Color(0xFF718096);
    final Color disabled =
        isDark ? const Color(0xFF4A5568) : const Color(0xFFCBD5E0);
    final Color hint =
        isDark ? const Color(0xFF718096) : const Color(0xFFA0AEC0);
    final Color search = isDark
        ? (isAmoled ? const Color(0xFF1A1A1A) : const Color(0xFF2D3748))
        : const Color(0xFFEDF2F7);
    final Color nav = isDark
        ? (isAmoled ? const Color(0xFF050505) : const Color(0xFF1A202C))
        : const Color(0xFFFFFFFF);
    final Color shimmerB =
        isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);
    final Color shimmerH =
        isDark ? const Color(0xFF4A5568) : const Color(0xFFF7FAFC);
    final Color skeleton =
        isDark ? const Color(0xFF2A2E37) : const Color(0xFFE8ECEF);

    // Common semantic colors across presets
    final Color success =
        isDark ? const Color(0xFF48BB78) : const Color(0xFF38A169);
    final Color warning =
        isDark ? const Color(0xFFECC94B) : const Color(0xFFD69E2E);
    final Color danger =
        isDark ? const Color(0xFFF56565) : const Color(0xFFE53E3E);
    const Color rating = Color(0xFFFFB800);
    final Color wishlist =
        isDark ? const Color(0xFFFC8181) : const Color(0xFFE53E3E);

    switch (preset) {
      case AppThemePreset.kisaanGreen:
        return AppColorTokens(
          primary: isDark ? const Color(0xFF2F9E54) : const Color(0xFF168A3A),
          secondary: isDark ? const Color(0xFF38B260) : const Color(0xFF075C2A),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFF2F9E54) : const Color(0xFF168A3A),
          coupon: const Color(0xFFFF8A3D),
          rating: rating,
          organic: const Color(0xFF2E7D32),
          offer: const Color(0xFFE65100),
          delivery: isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0288D1),
          wishlist: wishlist,
          flashSale: const Color(0xFFD32F2F),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.blinkitYellow:
        return AppColorTokens(
          primary: const Color(0xFFF8C000),
          secondary: isDark ? const Color(0xFF48BB78) : const Color(0xFF0C831F),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: const Color(0xFFF8C000),
          coupon: const Color(0xFF0C831F),
          rating: rating,
          organic: const Color(0xFF0C831F),
          offer: const Color(0xFFD32F2F),
          delivery: isDark ? const Color(0xFF63B3ED) : const Color(0xFF3182CE),
          wishlist: wishlist,
          flashSale: const Color(0xFFE53E3E),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.zeptoPurple:
        return AppColorTokens(
          primary: isDark ? const Color(0xFF9F7AEA) : const Color(0xFF5A189A),
          secondary: isDark ? const Color(0xFFF687B3) : const Color(0xFFD84315),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFF9F7AEA) : const Color(0xFF5A189A),
          coupon: const Color(0xFFFF6E40),
          rating: rating,
          organic: const Color(0xFF38A169),
          offer: const Color(0xFFD53F8C),
          delivery: isDark ? const Color(0xFF63B3ED) : const Color(0xFF2B6CB0),
          wishlist: wishlist,
          flashSale: const Color(0xFFE53E3E),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.bigBasketGreen:
        return AppColorTokens(
          primary: isDark ? const Color(0xFF81C784) : const Color(0xFF689F38),
          secondary: const Color(0xFFD32F2F),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFF81C784) : const Color(0xFF689F38),
          coupon: const Color(0xFFFFA000),
          rating: rating,
          organic: const Color(0xFF558B2F),
          offer: const Color(0xFFD32F2F),
          delivery: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
          wishlist: wishlist,
          flashSale: const Color(0xFFC62828),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.oceanBlue:
        return AppColorTokens(
          primary: isDark ? const Color(0xFF42A5F5) : const Color(0xFF0066CC),
          secondary: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFF42A5F5) : const Color(0xFF0066CC),
          coupon: const Color(0xFFFF9800),
          rating: rating,
          organic: const Color(0xFF388E3C),
          offer: const Color(0xFFD32F2F),
          delivery: isDark ? const Color(0xFF81D4FA) : const Color(0xFF0288D1),
          wishlist: wishlist,
          flashSale: const Color(0xFFE53E3E),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.modernOrange:
        return AppColorTokens(
          primary: const Color(0xFFFF6E14),
          secondary: isDark ? const Color(0xFF48BB78) : const Color(0xFF168A3A),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: const Color(0xFFFF6E14),
          coupon: const Color(0xFF38A169),
          rating: rating,
          organic: const Color(0xFF2F855A),
          offer: const Color(0xFFDD6B20),
          delivery: isDark ? const Color(0xFF63B3ED) : const Color(0xFF3182CE),
          wishlist: wishlist,
          flashSale: const Color(0xFFE53E3E),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.minimalBlack:
        return AppColorTokens(
          primary: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
          secondary: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF4A5568),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
          coupon: const Color(0xFFD69E2E),
          rating: rating,
          organic: const Color(0xFF38A169),
          offer: const Color(0xFFE53E3E),
          delivery: isDark ? const Color(0xFF63B3ED) : const Color(0xFF3182CE),
          wishlist: wishlist,
          flashSale: const Color(0xFFF56565),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );

      case AppThemePreset.elegantDark:
        return AppColorTokens(
          primary: isDark ? const Color(0xFF8C9EFF) : const Color(0xFF1A237E),
          secondary: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
          success: success,
          warning: warning,
          danger: danger,
          background: bg,
          surface: surface,
          card: card,
          border: border,
          divider: divider,
          textPrimary: textPri,
          textSecondary: textSec,
          disabled: disabled,
          hint: hint,
          badge: isDark ? const Color(0xFF8C9EFF) : const Color(0xFF1A237E),
          coupon: const Color(0xFFFFB74D),
          rating: rating,
          organic: const Color(0xFF66BB6A),
          offer: const Color(0xFFFF5252),
          delivery: isDark ? const Color(0xFF80D8FF) : const Color(0xFF00B0FF),
          wishlist: wishlist,
          flashSale: const Color(0xFFFF1744),
          searchBg: search,
          navigationBg: nav,
          shimmerBase: shimmerB,
          shimmerHighlight: shimmerH,
          skeleton: skeleton,
        );
    }
  }
}
