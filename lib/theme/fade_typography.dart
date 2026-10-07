import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fade type system: ONE family, Plus Jakarta Sans (Google Fonts, OFL),
/// shared with the landing site. Styles here are colorless; color comes from
/// the theme / [DefaultTextStyle] or is applied by the widget.
///
/// Scale (size / line height / weight / tracking):
///   display  40/44 w800 -0.8   hero numbers, onboarding headline
///   h1       32/38 w800 -0.5   screen titles (large)
///   h2       24/30 w700 -0.3   section titles, sheet titles
///   h3       20/26 w700 -0.2   card titles
///   title    17/24 w600  0     list row titles, app bar
///   body     16/24 w400  0     default copy
///   bodySm   14/20 w400  0     supporting copy
///   label    15/20 w600  0     buttons, input labels
///   caption  12/16 w500  0.1   metadata, timestamps
///   overline 11/16 w700  0.9   UPPERCASE section labels
abstract final class FadeType {
  static const String fontFamilyName = 'Plus Jakarta Sans';

  /// Tabular (fixed-width) figures. Use for prices, times, totals and
  /// anything that lines up in a column or updates live.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle _base({
    required double size,
    required double height,
    required FontWeight weight,
    double tracking = 0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  static TextStyle get display =>
      _base(size: 40, height: 44, weight: FontWeight.w800, tracking: -0.8);
  static TextStyle get h1 =>
      _base(size: 32, height: 38, weight: FontWeight.w800, tracking: -0.5);
  static TextStyle get h2 =>
      _base(size: 24, height: 30, weight: FontWeight.w700, tracking: -0.3);
  static TextStyle get h3 =>
      _base(size: 20, height: 26, weight: FontWeight.w700, tracking: -0.2);
  static TextStyle get title =>
      _base(size: 17, height: 24, weight: FontWeight.w600);
  static TextStyle get body =>
      _base(size: 16, height: 24, weight: FontWeight.w400);
  static TextStyle get bodySm =>
      _base(size: 14, height: 20, weight: FontWeight.w400);
  static TextStyle get label =>
      _base(size: 15, height: 20, weight: FontWeight.w600);
  static TextStyle get labelSm =>
      _base(size: 13, height: 18, weight: FontWeight.w600);
  static TextStyle get caption =>
      _base(size: 12, height: 16, weight: FontWeight.w500, tracking: 0.1);
  static TextStyle get overline =>
      _base(size: 11, height: 16, weight: FontWeight.w700, tracking: 0.9);

  /// Big money figure (earnings hero). Tabular.
  static TextStyle get moneyLg => _base(
    size: 36,
    height: 40,
    weight: FontWeight.w800,
    tracking: -0.6,
  ).copyWith(fontFeatures: tabular);

  /// Inline price / time. Tabular.
  static TextStyle get numeric => _base(
    size: 15,
    height: 20,
    weight: FontWeight.w600,
  ).copyWith(fontFeatures: tabular);

  /// Material [TextTheme] mapped onto the Fade scale, colored for a palette.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    return TextTheme(
      displayLarge: display.copyWith(color: primary),
      displayMedium: _base(
        size: 36,
        height: 40,
        weight: FontWeight.w800,
        tracking: -0.7,
      ).copyWith(color: primary),
      displaySmall: h1.copyWith(color: primary),
      headlineLarge: h1.copyWith(color: primary),
      headlineMedium: h2.copyWith(color: primary),
      headlineSmall: h3.copyWith(color: primary),
      titleLarge: h3.copyWith(color: primary),
      titleMedium: title.copyWith(color: primary),
      titleSmall: label.copyWith(color: primary),
      bodyLarge: body.copyWith(color: primary),
      bodyMedium: bodySm.copyWith(color: primary),
      bodySmall: caption.copyWith(color: tertiary),
      labelLarge: label.copyWith(color: primary),
      labelMedium: labelSm.copyWith(color: secondary),
      labelSmall: overline.copyWith(color: tertiary),
    );
  }
}
