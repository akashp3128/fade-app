// Compatibility layer for screens written against the old `lib/config/theme.dart`
// API (AppColors / AppTheme / AppSpacing / AppRadius).
//
// HOW TO ADOPT (owned by the Fade App workstream — a one-line change):
//   Replace the body of lib/config/theme.dart with
//       export 'package:fade_app/theme/legacy.dart';
//   Every existing `AppColors.accent`, `AppSpacing.md`, `AppTheme.darkTheme`...
//   keeps compiling and picks up the new brand tokens.
//
// This layer is DARK-ONLY on purpose: legacy screens hard-code AppColors
// constants, so they cannot react to light mode. New/migrated screens should
// use `context.fadeColors` + `lib/widgets/ui`, after which the app can switch
// to `themeMode: ThemeMode.system` with FadeTheme.light()/dark().
//
// Do not import this file together with lib/config/theme.dart (duplicate names).
import 'package:flutter/material.dart';

import 'fade_colors.dart';
import 'fade_theme.dart';
import 'fade_tokens.dart';

/// Legacy color names mapped to the new dark tokens.
///
/// For new code, use context.fadeColors (FadeColors) or FadePalette.
abstract final class AppColors {
  static const primary = FadePalette.graphite900;
  static const primaryLight = FadePalette.graphite800;

  static const accent = FadePalette.gold;
  static const accentLight = Color(0xFFFFC94D);
  static const accentDark = FadePalette.goldPressed;

  static const background = FadePalette.ink;
  static const surface = FadePalette.graphite900;

  static const textPrimary = Color(0xFFF4F2ED);
  static const textSecondary = Color(0xFFA9A7A1);
  static const textLight = Color(0xFF85837E);
  static const textOnAccent = FadePalette.ink;

  static const border = FadePalette.graphite600;
  static const divider = FadePalette.graphite600;

  static const success = Color(0xFF3DD68C);
  static const warning = Color(0xFFFF9F43);
  static const error = Color(0xFFFF6B6B);
  static const info = Color(0xFF6CB4FF);

  static const primaryGradient = LinearGradient(
    colors: [FadePalette.graphite900, FadePalette.graphite800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [FadePalette.goldPressed, FadePalette.gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get glowShadow => FadeShadows.accentGlow;

  static List<BoxShadow> get subtleShadow => const [
    BoxShadow(color: Color(0x80000000), blurRadius: 10, offset: Offset(0, 2)),
  ];
}

/// Legacy theme entry points.
///
/// For new code, use FadeTheme.dark() / FadeTheme.light().
abstract final class AppTheme {
  /// Intentionally dark until legacy screens stop hard-coding AppColors.
  static ThemeData get lightTheme => FadeTheme.dark();
  static ThemeData get darkTheme => FadeTheme.dark();
}

/// Legacy spacing (values unchanged so layouts do not shift).
///
/// For new code, use FadeSpace (s4, s8, s16...).
abstract final class AppSpacing {
  static const double xs = FadeSpace.s4;
  static const double sm = FadeSpace.s8;
  static const double md = FadeSpace.s16;
  static const double lg = FadeSpace.s24;
  static const double xl = FadeSpace.s32;
  static const double xxl = FadeSpace.s48;
}

/// Legacy radii, nudged to the new scale (softer, more modern corners).
///
/// For new code, use FadeRadius.
abstract final class AppRadius {
  static const double sm = FadeRadius.sm;
  static const double md = FadeRadius.md;
  static const double lg = FadeRadius.lg;
  static const double xl = FadeRadius.xl;
  static const double full = FadeRadius.full;
}
