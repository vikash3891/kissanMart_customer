import 'package:flutter/material.dart';

class AppAnimation {
  AppAnimation._();

  // ─── Durations ────────────────────────────────────────────────────────────
  static const Duration d100 = Duration(milliseconds: 100);
  static const Duration d150 = Duration(milliseconds: 150);
  static const Duration d200 = Duration(milliseconds: 200);
  static const Duration d300 = Duration(milliseconds: 300);
  static const Duration d500 = Duration(milliseconds: 500);

  // ─── Curves ───────────────────────────────────────────────────────────────
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;

  // ─── Reusable Transition Builders ─────────────────────────────────────────

  /// Fade Transition wrapper
  static Widget fade({
    required Widget child,
    required Duration duration,
    Key? key,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration,
      switchInCurve: easeOut,
      switchOutCurve: easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }

  /// Scale Transition wrapper
  static Widget scale({
    required Widget child,
    required Duration duration,
    Key? key,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration,
      switchInCurve: fastOutSlowIn,
      switchOutCurve: fastOutSlowIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }

  /// Slide Transition wrapper
  static Widget slide({
    required Widget child,
    required Duration duration,
    Offset beginOffset = const Offset(0, 0.1),
    Key? key,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration,
      switchInCurve: fastOutSlowIn,
      switchOutCurve: fastOutSlowIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
              .animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }

  /// Ripple InkWell wrapper
  static Widget ripple({
    required Widget child,
    required VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      splashColor: splashColor ?? Colors.black.withOpacity(0.08),
      highlightColor: Colors.transparent,
      child: child,
    );
  }

  /// Page Transition Route Builder
  static PageRouteBuilder<T> pageTransition<T>({
    required Widget page,
    Duration duration = d300,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
