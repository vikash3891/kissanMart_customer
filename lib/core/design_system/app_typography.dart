import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _outfit({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      );
    } catch (_) {
      // Fallback if GoogleFonts font loading fails offline
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      );
    }
  }

  // ─── Display & Headline ───────────────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => _outfit(
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => _outfit(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle headline({Color? color}) => _outfit(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.25,
        color: color,
      );

  // ─── Titles ───────────────────────────────────────────────────────────────
  static TextStyle titleLarge({Color? color}) => _outfit(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => _outfit(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // ─── Body ─────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => _outfit(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => _outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  // ─── Semantic & Specialized ───────────────────────────────────────────────
  static TextStyle button({Color? color}) => _outfit(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: color,
      );

  static TextStyle caption({Color? color}) => _outfit(
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color,
      );

  static TextStyle label({Color? color}) => _outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle price({Color? color, double fontSize = 18.0}) => _outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle discount({Color? color, double fontSize = 12.0}) => _outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        color: color ?? Colors.grey,
      );

  static TextStyle offer({Color? color}) => _outfit(
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle productTitle({Color? color}) => _outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle sectionHeader({Color? color}) => _outfit(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle navigation({Color? color, bool isSelected = false}) =>
      _outfit(
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: color,
      );

  static TextStyle dialog({Color? color}) => _outfit(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );
}
