import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // ─── Numeric Constants ────────────────────────────────────────────────────
  static const double xsVal = 4.0;
  static const double smVal = 8.0;
  static const double mdVal = 12.0;
  static const double lgVal = 16.0;
  static const double xlVal = 24.0;
  static const double pillVal = 100.0;
  static const double circleVal = 999.0;

  // ─── Radius Objects ───────────────────────────────────────────────────────
  static const Radius xs = Radius.circular(xsVal);
  static const Radius sm = Radius.circular(smVal);
  static const Radius md = Radius.circular(mdVal);
  static const Radius lg = Radius.circular(lgVal);
  static const Radius xl = Radius.circular(xlVal);
  static const Radius pill = Radius.circular(pillVal);
  static const Radius circle = Radius.circular(circleVal);

  // ─── BorderRadius Objects ─────────────────────────────────────────────────
  static const BorderRadius borderXs = BorderRadius.all(xs);
  static const BorderRadius borderSm = BorderRadius.all(sm);
  static const BorderRadius borderMd = BorderRadius.all(md);
  static const BorderRadius borderLg = BorderRadius.all(lg);
  static const BorderRadius borderXl = BorderRadius.all(xl);
  static const BorderRadius borderPill = BorderRadius.all(pill);
  static const BorderRadius borderCircle = BorderRadius.all(circle);

  // ─── Semantic Component Radii ─────────────────────────────────────────────
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: xl);
  static const BorderRadius dialog = borderLg;
  static const BorderRadius card = borderMd;
  static const BorderRadius button = borderSm;
  static const BorderRadius search = borderMd;
}
