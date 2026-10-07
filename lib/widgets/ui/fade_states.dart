import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'fade_button.dart';

/// "Nothing here yet" with a next step. Write the copy as an invitation:
/// title says what's missing, message says why it matters, action fixes it.
///
/// ```dart
/// FadeEmptyState(
///   icon: Icons.event_available_outlined,
///   title: 'No bookings yet',
///   message: 'Share your booking link and clients can grab a time in seconds.',
///   actionLabel: 'Copy booking link',
///   onAction: copyLink,
/// )
/// ```
class FadeEmptyState extends StatelessWidget {
  const FadeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Smaller version for use inside a card/section.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      compact: compact,
      badge: _IconBadge(icon: icon, tone: _BadgeTone.accent, compact: compact),
      title: title,
      message: message,
      actions: [
        if (actionLabel != null)
          FadeButton.primary(
            label: actionLabel!,
            onPressed: onAction,
            size: compact ? FadeButtonSize.medium : FadeButtonSize.large,
          ),
        if (secondaryLabel != null)
          FadeButton.ghost(label: secondaryLabel!, onPressed: onSecondary),
      ],
    );
  }
}

/// Something failed. Say what happened in plain words, reassure, offer retry.
/// Never show raw exception text to barbers; log it instead.
class FadeErrorState extends StatelessWidget {
  const FadeErrorState({
    super.key,
    this.title = "Couldn't load this",
    this.message = 'Check your connection and try again. Your data is safe.',
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      compact: compact,
      liveRegion: true,
      badge: _IconBadge(
        icon: Icons.error_outline_rounded,
        tone: _BadgeTone.danger,
        compact: compact,
      ),
      title: title,
      message: message,
      actions: [
        if (onRetry != null)
          FadeButton.secondary(
            label: retryLabel,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            size: compact ? FadeButtonSize.medium : FadeButtonSize.large,
          ),
      ],
    );
  }
}

/// Centered spinner with optional label. Prefer [FadeSkeleton] for content
/// that has a known shape (lists, cards); use this for short, shapeless waits.
class FadeLoadingState extends StatelessWidget {
  const FadeLoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: label ?? 'Loading',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: c.accent,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: FadeSpace.s16),
              Text(
                label!,
                style: FadeType.bodySm.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pulsing placeholder block. Compose into the shape of the content.
class FadeSkeleton extends StatefulWidget {
  const FadeSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = FadeRadius.sm,
    this.circle = false,
  });

  /// A circular skeleton (avatar).
  const FadeSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = FadeRadius.full,
      circle = true;

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<FadeSkeleton> createState() => _FadeSkeletonState();
}

class _FadeSkeletonState extends State<FadeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              c.skeletonBase,
              c.skeletonHighlight,
              Curves.easeInOut.transform(_ctrl.value),
            ),
            borderRadius: widget.circle
                ? null
                : BorderRadius.circular(widget.radius),
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
      ),
    );
  }
}

/// Skeleton shaped like a [FadeListRow] (avatar + two lines + value).
class FadeSkeletonRow extends StatelessWidget {
  const FadeSkeletonRow({super.key, this.avatar = true});

  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FadeSpace.s16,
        vertical: FadeSpace.s12,
      ),
      child: Row(
        children: [
          if (avatar) ...[
            const FadeSkeleton.circle(size: 40),
            const SizedBox(width: FadeSpace.s12),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSkeleton(width: 140, height: 14),
                SizedBox(height: FadeSpace.s8),
                FadeSkeleton(width: 90, height: 12),
              ],
            ),
          ),
          const FadeSkeleton(width: 44, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton list for initial loads. Announces "Loading" once to screen readers.
class FadeSkeletonList extends StatelessWidget {
  const FadeSkeletonList({super.key, this.count = 5, this.avatar = true});

  final int count;
  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) FadeSkeletonRow(avatar: avatar),
        ],
      ),
    );
  }
}

enum _BadgeTone { accent, danger }

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.tone,
    required this.compact,
  });

  final IconData icon;
  final _BadgeTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final size = compact ? 48.0 : 64.0;
    final (Color bg, Color fg) = tone == _BadgeTone.accent
        ? (c.accentSoft, c.accentText)
        : (c.dangerSoft, c.danger);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 14 : 20),
      ),
      child: Icon(icon, color: fg, size: compact ? 24 : 30),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.badge,
    required this.title,
    required this.message,
    required this.actions,
    required this.compact,
    this.liveRegion = false,
  });

  final Widget badge;
  final String title;
  final String? message;
  final List<Widget> actions;
  final bool compact;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? FadeSpace.s16 : FadeSpace.s32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Semantics(
            liveRegion: liveRegion,
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                badge,
                SizedBox(height: compact ? FadeSpace.s12 : FadeSpace.s20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: (compact ? FadeType.title : FadeType.h3).copyWith(
                    color: c.textPrimary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: FadeSpace.s8),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: FadeType.bodySm.copyWith(color: c.textSecondary),
                  ),
                ],
                if (actions.isNotEmpty) ...[
                  SizedBox(height: compact ? FadeSpace.s16 : FadeSpace.s24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: FadeSpace.s8,
                    runSpacing: FadeSpace.s8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
