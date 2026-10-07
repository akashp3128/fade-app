import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum FadeButtonVariant {
  /// Gold fill. ONE per screen: the action that moves the barber forward.
  primary,

  /// Outlined, neutral. Alternative actions ("Preview", "Skip for now").
  secondary,

  /// Text-only. Low-emphasis actions in rows, headers, dialogs.
  ghost,

  /// Red fill. Irreversible actions ("Cancel appointment", "Delete service").
  destructive,
}

enum FadeButtonSize { small, medium, large }

/// Fade's button. Handles variant colors, sizes, leading/trailing icons,
/// a loading state that keeps the button's width stable, and full-width.
///
/// ```dart
/// FadeButton.primary(label: 'Save hours', onPressed: save, loading: saving, expand: true)
/// FadeButton.destructive(label: 'Cancel appointment', onPressed: cancel)
/// ```
class FadeButton extends StatelessWidget {
  const FadeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FadeButtonVariant.primary,
    this.size = FadeButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  });

  const FadeButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = FadeButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = FadeButtonVariant.primary;

  const FadeButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = FadeButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = FadeButtonVariant.secondary;

  const FadeButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = FadeButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = FadeButtonVariant.ghost;

  const FadeButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = FadeButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = FadeButtonVariant.destructive;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final FadeButtonVariant variant;
  final FadeButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Shows a spinner and ignores taps, without changing the button's size.
  final bool loading;

  /// Stretch to the parent's width.
  final bool expand;
  final String? semanticLabel;

  double get _height => switch (size) {
    FadeButtonSize.small => 36,
    FadeButtonSize.medium => 44,
    FadeButtonSize.large => 52,
  };

  double get _hPad => switch (size) {
    FadeButtonSize.small => FadeSpace.s12,
    FadeButtonSize.medium => FadeSpace.s16,
    FadeButtonSize.large => FadeSpace.s20,
  };

  double get _iconSize => size == FadeButtonSize.small ? 16 : 20;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final enabled = onPressed != null || loading;

    final (
      Color bg,
      Color fg,
      Color pressed,
      BorderSide side,
    ) = switch (variant) {
      FadeButtonVariant.primary => (
        c.accent,
        c.onAccent,
        c.accentPressed,
        BorderSide.none,
      ),
      FadeButtonVariant.secondary => (
        Colors.transparent,
        c.textPrimary,
        c.surfaceHigh,
        BorderSide(color: c.borderStrong),
      ),
      FadeButtonVariant.ghost => (
        Colors.transparent,
        c.accentText,
        c.surfaceHigh,
        BorderSide.none,
      ),
      FadeButtonVariant.destructive => (
        c.danger,
        c.onDanger,
        Color.lerp(c.danger, Colors.black, 0.12)!,
        BorderSide.none,
      ),
    };

    final bool filled =
        variant == FadeButtonVariant.primary ||
        variant == FadeButtonVariant.destructive;
    final Color disabledBg = filled ? c.surfaceHigh : Colors.transparent;
    final Color disabledFg = c.textTertiary;

    final textStyle = (size == FadeButtonSize.small
        ? FadeType.labelSm
        : FadeType.label);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _iconSize),
          const SizedBox(width: FadeSpace.s8),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: FadeSpace.s8),
          Icon(trailingIcon, size: _iconSize),
        ],
      ],
    );

    final button = TextButton(
      onPressed: loading ? () {} : onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, _height),
        ),
        maximumSize: WidgetStatePropertyAll(Size(double.infinity, _height)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: _hPad),
        ),
        textStyle: WidgetStatePropertyAll(textStyle),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: FadeRadius.mdAll),
        ),
        side: WidgetStateProperty.resolveWith((s) {
          if (side == BorderSide.none) return BorderSide.none;
          return s.contains(WidgetState.disabled)
              ? BorderSide(color: c.border)
              : side;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return disabledBg;
          if (s.contains(WidgetState.pressed) && !loading) return pressed;
          return bg;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return disabledFg;
          return fg;
        }),
        overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.06)),
        tapTargetSize: MaterialTapTargetSize.padded,
        animationDuration: FadeMotion.fast,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: loading ? 0 : 1, child: content),
          if (loading)
            SizedBox.square(
              dimension: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: enabled ? fg : disabledFg,
              ),
            ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled && !loading,
      label: loading ? '${semanticLabel ?? label}, loading' : semanticLabel,
      excludeSemantics: loading,
      child: IgnorePointer(ignoring: loading, child: button),
    );
  }
}

/// Square icon-only button with a 44pt touch target and a required tooltip
/// (doubles as the accessibility label).
class FadeIconButton extends StatelessWidget {
  const FadeIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Surface-filled circle (for use over images / in app bars).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: filled ? c.surfaceRaised : Colors.transparent,
        foregroundColor: c.textPrimary,
        disabledForegroundColor: c.textTertiary,
        shape: const CircleBorder(),
        side: filled ? BorderSide(color: c.border) : BorderSide.none,
      ),
    );
  }
}
