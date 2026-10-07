import 'package:flutter/material.dart';

/// Raw Fade brand palette. Prefer the semantic [FadeColors] tokens in UI code;
/// reach for these only for brand moments (logo, illustrations, marketing).
abstract final class FadePalette {
  /// Primary brand black. Dark-mode background.
  static const ink = Color(0xFF0B0B0C);

  /// Fade Gold. Accent / primary action fill. Evolved from the old #D4AF37:
  /// warmer and cleaner, reads as "signal" rather than "luxury trim".
  static const gold = Color(0xFFF5B82E);

  /// Pressed / hover-down gold.
  static const goldPressed = Color(0xFFE0A31A);

  /// Brass. Gold-family color that passes WCAG AA as text on light surfaces.
  static const brass = Color(0xFF7A5600);

  /// Bone. Warm off-white. Light-mode background and on-dark wordmark color.
  static const bone = Color(0xFFF6F3EC);

  static const white = Color(0xFFFFFFFF);

  // Graphite ramp (dark surfaces)
  static const graphite900 = Color(0xFF141416);
  static const graphite800 = Color(0xFF1C1C1F);
  static const graphite700 = Color(0xFF26262A);
  static const graphite600 = Color(0xFF2E2E33);
  static const graphite500 = Color(0xFF45454C);

  // Sand ramp (light surfaces)
  static const sand100 = Color(0xFFEFEBE2);
  static const sand200 = Color(0xFFE3DED3);
  static const sand300 = Color(0xFFCFC8BA);
}

/// Semantic color tokens, exposed as a [ThemeExtension] so every widget can
/// read the right value for the current brightness via `context.fadeColors`.
@immutable
class FadeColors extends ThemeExtension<FadeColors> {
  const FadeColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHigh,
    required this.surfaceSunken,
    required this.inputFill,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentPressed,
    required this.accentSoft,
    required this.accentText,
    required this.onAccent,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.onDanger,
    required this.info,
    required this.infoSoft,
    required this.scrim,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  /// App canvas (Scaffold background).
  final Color background;

  /// Default card / sheet surface.
  final Color surface;

  /// Raised surface on top of [surface] (menus, nested cards, selected rows).
  final Color surfaceRaised;

  /// Highest surface (pressed rows, segmented control thumb track).
  final Color surfaceHigh;

  /// Recessed areas (calendar gutters, grouped list backgrounds).
  final Color surfaceSunken;

  /// Text field fill.
  final Color inputFill;

  /// Hairline borders and dividers.
  final Color border;

  /// Emphasised borders (inputs, outlined buttons).
  final Color borderStrong;

  /// Headlines and body copy.
  final Color textPrimary;

  /// Supporting copy, labels, metadata.
  final Color textSecondary;

  /// Placeholders, captions, disabled-but-visible text. Meets AA (≥4.5:1)
  /// on [background] in both modes.
  final Color textTertiary;

  /// Fade Gold. Fill for primary actions, selection, focus.
  final Color accent;

  /// Pressed state for [accent] fills.
  final Color accentPressed;

  /// Gold-tinted background (selected chips, highlighted cards).
  final Color accentSoft;

  /// Gold-family color safe to use as TEXT on [background]/[surface].
  /// Dark: Fade Gold. Light: Brass (gold text on white fails contrast).
  final Color accentText;

  /// Text / icons on [accent] fills. Always ink.
  final Color onAccent;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;

  /// Text / icons on [danger] fills.
  final Color onDanger;
  final Color info;
  final Color infoSoft;

  /// Modal barrier.
  final Color scrim;
  final Color skeletonBase;
  final Color skeletonHighlight;

  static const dark = FadeColors(
    background: FadePalette.ink,
    surface: FadePalette.graphite900,
    surfaceRaised: FadePalette.graphite800,
    surfaceHigh: FadePalette.graphite700,
    surfaceSunken: Color(0xFF080809),
    inputFill: FadePalette.graphite800,
    border: FadePalette.graphite600,
    borderStrong: FadePalette.graphite500,
    textPrimary: Color(0xFFF4F2ED),
    textSecondary: Color(0xFFA9A7A1),
    textTertiary: Color(0xFF85837E),
    accent: FadePalette.gold,
    accentPressed: FadePalette.goldPressed,
    accentSoft: Color(0xFF2A2210),
    accentText: FadePalette.gold,
    onAccent: FadePalette.ink,
    success: Color(0xFF3DD68C),
    successSoft: Color(0xFF0F2A1D),
    warning: Color(0xFFFF9F43),
    warningSoft: Color(0xFF2E1D0C),
    danger: Color(0xFFFF6B6B),
    dangerSoft: Color(0xFF2E1314),
    onDanger: FadePalette.ink,
    info: Color(0xFF6CB4FF),
    infoSoft: Color(0xFF0F1E2E),
    scrim: Color(0xB3000000),
    skeletonBase: FadePalette.graphite800,
    skeletonHighlight: Color(0xFF2A2A2F),
  );

  static const light = FadeColors(
    background: FadePalette.bone,
    surface: FadePalette.white,
    surfaceRaised: FadePalette.white,
    surfaceHigh: FadePalette.sand100,
    surfaceSunken: FadePalette.sand100,
    inputFill: FadePalette.white,
    border: FadePalette.sand200,
    borderStrong: FadePalette.sand300,
    textPrimary: FadePalette.graphite900,
    textSecondary: Color(0xFF5B5953),
    textTertiary: Color(0xFF6F6C65),
    accent: FadePalette.gold,
    accentPressed: FadePalette.goldPressed,
    accentSoft: Color(0xFFFBEFD0),
    accentText: FadePalette.brass,
    onAccent: FadePalette.ink,
    success: Color(0xFF1A7F4B),
    successSoft: Color(0xFFE3F4EA),
    warning: Color(0xFFA64B00),
    warningSoft: Color(0xFFFCEBDD),
    danger: Color(0xFFC8281E),
    dangerSoft: Color(0xFFFBE4E2),
    onDanger: FadePalette.white,
    info: Color(0xFF1E63C4),
    infoSoft: Color(0xFFE1ECFA),
    scrim: Color(0x80141416),
    skeletonBase: Color(0xFFEAE6DD),
    skeletonHighlight: Color(0xFFF5F2EB),
  );

  @override
  FadeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceHigh,
    Color? surfaceSunken,
    Color? inputFill,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentPressed,
    Color? accentSoft,
    Color? accentText,
    Color? onAccent,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? onDanger,
    Color? info,
    Color? infoSoft,
    Color? scrim,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return FadeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      inputFill: inputFill ?? this.inputFill,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentSoft: accentSoft ?? this.accentSoft,
      accentText: accentText ?? this.accentText,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      onDanger: onDanger ?? this.onDanger,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      scrim: scrim ?? this.scrim,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  FadeColors lerp(ThemeExtension<FadeColors>? other, double t) {
    if (other is! FadeColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return FadeColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      inputFill: l(inputFill, other.inputFill),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      accent: l(accent, other.accent),
      accentPressed: l(accentPressed, other.accentPressed),
      accentSoft: l(accentSoft, other.accentSoft),
      accentText: l(accentText, other.accentText),
      onAccent: l(onAccent, other.onAccent),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      onDanger: l(onDanger, other.onDanger),
      info: l(info, other.info),
      infoSoft: l(infoSoft, other.infoSoft),
      scrim: l(scrim, other.scrim),
      skeletonBase: l(skeletonBase, other.skeletonBase),
      skeletonHighlight: l(skeletonHighlight, other.skeletonHighlight),
    );
  }
}
