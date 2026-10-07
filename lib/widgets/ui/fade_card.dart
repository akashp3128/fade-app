import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum FadeCardTone {
  /// Surface + hairline border. The default.
  outlined,

  /// Raised surface; soft shadow in light mode, lighter fill in dark mode.
  raised,

  /// Gold-tinted. For the one thing that needs attention (setup step, payout issue).
  accent,
}

/// Container for grouped content. Tappable when [onTap] is set.
class FadeCard extends StatelessWidget {
  const FadeCard({
    super.key,
    required this.child,
    this.tone = FadeCardTone.outlined,
    this.padding = const EdgeInsets.all(FadeSpace.s16),
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final FadeCardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final dark = context.isDarkMode;

    final (Color fill, Color border, List<BoxShadow> shadow) = switch (tone) {
      FadeCardTone.outlined => (c.surface, c.border, FadeShadows.none),
      FadeCardTone.raised => (
        dark ? c.surfaceRaised : c.surface,
        dark ? c.border : Colors.transparent,
        dark ? FadeShadows.none : FadeShadows.e1,
      ),
      FadeCardTone.accent => (
        c.accentSoft,
        c.accent.withValues(alpha: dark ? 0.35 : 0.6),
        FadeShadows.none,
      ),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: FadeRadius.lgAll,
      side: BorderSide(color: border),
    );

    Widget body = Padding(padding: padding, child: child);
    if (onTap != null) {
      body = InkWell(onTap: onTap, customBorder: shape, child: body);
    }

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: FadeRadius.lgAll,
          boxShadow: shadow,
        ),
        child: Material(
          color: fill,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      ),
    );
  }
}
