import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// 4-pt spacing scale. Name = value in logical pixels, so there is no
/// guessing what "md" means.
abstract final class FadeSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;

  /// Horizontal page gutter on phones.
  static const double gutter = 20;

  /// Minimum touch target.
  static const double minTap = 44;
}

/// Corner radii.
abstract final class FadeRadius {
  /// Tags, small badges.
  static const double sm = 8;

  /// Buttons, inputs, list-row highlights.
  static const double md = 12;

  /// Cards.
  static const double lg = 16;

  /// Sheets, dialogs, hero cards.
  static const double xl = 24;

  /// Pills, avatars, search field.
  static const double full = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}

/// Elevation. Dark mode separates layers with surface color + hairline
/// borders (shadows are invisible on near-black); light mode uses these soft
/// shadows sparingly (cards: none or [e1], sheets/menus: [e2], dialogs: [e3]).
abstract final class FadeShadows {
  static const List<BoxShadow> none = [];
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x0F141416), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A141416), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x14141416), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F141416), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(color: Color(0x1F141416), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14141416), blurRadius: 48, offset: Offset(0, 16)),
  ];

  /// Gold focus/selection glow. Use only on the single primary element of a
  /// screen (never on lists).
  static const List<BoxShadow> accentGlow = [
    BoxShadow(color: Color(0x33F5B82E), blurRadius: 20, offset: Offset(0, 6)),
  ];
}

/// Motion. Short and functional: things move to explain change, never to
/// decorate. Honour MediaQuery.disableAnimations (widgets in lib/widgets/ui do).
abstract final class FadeMotion {
  /// Press feedback, toggles, color changes.
  static const Duration fast = Duration(milliseconds: 120);

  /// Most transitions: expand/collapse, fades, chips.
  static const Duration base = Duration(milliseconds: 200);

  /// Sheets, page-level transitions, success moments.
  static const Duration slow = Duration(milliseconds: 320);

  /// Default easing for things entering / changing.
  static const Curve standard = Curves.easeOutCubic;

  /// Things leaving the screen.
  static const Curve exit = Curves.easeInCubic;

  /// Larger, more expressive moves (sheet open, booking confirmed).
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}
