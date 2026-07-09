import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // ─── Base Scale ───────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ─── Semantic Layout Constants ────────────────────────────────────────────
  static const double section = 24.0;
  static const double page = 16.0;
  static const double card = 12.0;
  static const double dialog = 20.0;
  static const double button = 12.0;

  // ─── Reusable EdgeInsets Helpers ──────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.all(page);
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: page);
  static const EdgeInsets cardPadding = EdgeInsets.all(card);
  static const EdgeInsets dialogPadding = EdgeInsets.all(dialog);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: button);

  // ─── Reusable SizedBox Spacers ────────────────────────────────────────────
  static const SizedBox h4 = SizedBox(width: xs);
  static const SizedBox h8 = SizedBox(width: sm);
  static const SizedBox h12 = SizedBox(width: 12.0);
  static const SizedBox h16 = SizedBox(width: md);
  static const SizedBox h24 = SizedBox(width: lg);
  static const SizedBox h32 = SizedBox(width: xl);

  static const SizedBox v4 = SizedBox(height: xs);
  static const SizedBox v8 = SizedBox(height: sm);
  static const SizedBox v12 = SizedBox(height: 12.0);
  static const SizedBox v16 = SizedBox(height: md);
  static const SizedBox v24 = SizedBox(height: lg);
  static const SizedBox v32 = SizedBox(height: xl);
  static const SizedBox v48 = SizedBox(height: xxl);
}
