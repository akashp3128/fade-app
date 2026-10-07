import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// A single row for settings, services, appointments and payouts.
///
/// ```dart
/// FadeListRow(
///   leading: const FadeAvatar(name: 'Marcus T.'),
///   title: 'Skin fade',
///   subtitle: '45 min',
///   value: '\$40',
///   onTap: () {},
/// )
/// ```
class FadeListRow extends StatelessWidget {
  const FadeListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.destructive = false,
    this.enabled = true,
    this.dense = false,
    this.divider = false,
  });

  final String title;
  final String? subtitle;

  /// Any widget (avatar, thumbnail). Takes precedence over [leadingIcon].
  final Widget? leading;

  /// Icon in a tinted rounded square.
  final IconData? leadingIcon;

  /// Right-aligned value text (price, time, status). Tabular figures.
  final String? value;

  /// Custom trailing widget (switch, tag). Shown after [value].
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to true when [onTap] is set and no [trailing] widget is given.
  final bool? showChevron;
  final bool destructive;
  final bool enabled;
  final bool dense;

  /// Draws a hairline under the row (for rows inside a card).
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final titleColor = !enabled
        ? c.textTertiary
        : (destructive ? c.danger : c.textPrimary);
    final chevron = showChevron ?? (onTap != null && trailing == null);

    Widget? lead = leading;
    if (lead == null && leadingIcon != null) {
      lead = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: destructive ? c.dangerSoft : c.surfaceHigh,
          borderRadius: FadeRadius.mdAll,
        ),
        child: Icon(
          leadingIcon,
          size: 20,
          color: destructive ? c.danger : c.textPrimary,
        ),
      );
    }

    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 48 : 60),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FadeSpace.s16,
          vertical: dense ? FadeSpace.s8 : FadeSpace.s12,
        ),
        child: Row(
          children: [
            if (lead != null) ...[lead, const SizedBox(width: FadeSpace.s12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: FadeType.title.copyWith(
                      color: titleColor,
                      fontSize: dense ? 15 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: FadeSpace.s2),
                    Text(
                      subtitle!,
                      style: FadeType.bodySm.copyWith(color: c.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: FadeSpace.s12),
              Text(
                value!,
                style: FadeType.numeric.copyWith(
                  color: enabled ? c.textPrimary : c.textTertiary,
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: FadeSpace.s12),
              trailing!,
            ],
            if (chevron) ...[
              const SizedBox(width: FadeSpace.s8),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: c.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: enabled ? onTap : null, child: row),
        ),
        if (divider)
          Divider(
            height: 1,
            thickness: 1,
            indent: lead != null ? 68 : 16,
            color: c.border,
          ),
      ],
    );
  }
}

/// Section title with an optional action ("See all", "Edit").
class FadeSectionHeader extends StatelessWidget {
  const FadeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.overline = false,
    this.padding = const EdgeInsets.fromLTRB(
      FadeSpace.gutter,
      FadeSpace.s24,
      FadeSpace.gutter,
      FadeSpace.s8,
    ),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Small uppercase label style (for grouped settings lists).
  final bool overline;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                overline ? title.toUpperCase() : title,
                style: overline
                    ? FadeType.overline.copyWith(color: c.textTertiary)
                    : FadeType.h3.copyWith(color: c.textPrimary, fontSize: 18),
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: c.accentText,
                textStyle: FadeType.labelSm,
                padding: const EdgeInsets.symmetric(horizontal: FadeSpace.s8),
                minimumSize: const Size(44, 36),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
