import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum FadeTone { neutral, accent, success, warning, danger, info }

/// Small status label ("Confirmed", "Paid", "No-show", "Payouts paused").
/// Always pair color with a word (and optionally an icon/dot); never rely on
/// color alone.
class FadeTag extends StatelessWidget {
  const FadeTag({
    super.key,
    required this.label,
    this.tone = FadeTone.neutral,
    this.icon,
    this.dot = false,
  });

  final String label;
  final FadeTone tone;
  final IconData? icon;

  /// Leading status dot instead of an icon.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final (Color bg, Color fg) = switch (tone) {
      FadeTone.neutral => (c.surfaceHigh, c.textSecondary),
      FadeTone.accent => (c.accentSoft, c.accentText),
      FadeTone.success => (c.successSoft, c.success),
      FadeTone.warning => (c.warningSoft, c.warning),
      FadeTone.danger => (c.dangerSoft, c.danger),
      FadeTone.info => (c.infoSoft, c.info),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FadeSpace.s8,
        vertical: FadeSpace.s4,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: FadeRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: FadeSpace.s4 + 2),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: FadeSpace.s4),
          ],
          Text(
            label,
            style: FadeType.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable pill (service categories, day pickers, filters).
class FadeChip extends StatelessWidget {
  const FadeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: context.reduceMotion ? Duration.zero : FadeMotion.fast,
        curve: FadeMotion.standard,
        decoration: BoxDecoration(
          color: selected ? c.accent : c.surface,
          borderRadius: FadeRadius.fullAll,
          border: Border.all(color: selected ? c.accent : c.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onSelected == null ? null : () => onSelected!(!selected),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FadeSpace.s16,
                  vertical: FadeSpace.s8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: selected ? c.onAccent : c.textSecondary,
                      ),
                      const SizedBox(width: FadeSpace.s4 + 2),
                    ],
                    Text(
                      label,
                      style: FadeType.labelSm.copyWith(
                        color: selected ? c.onAccent : c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
