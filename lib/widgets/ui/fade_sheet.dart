import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shows a Fade-styled modal bottom sheet: drag handle, rounded top, optional
/// title, keyboard-safe padding, and an optional sticky action area.
///
/// ```dart
/// final ok = await showFadeSheet<bool>(
///   context,
///   title: 'Cancel this appointment?',
///   child: const Text('Marcus will get a notification and a full refund.'),
///   actions: [
///     FadeButton.destructive(label: 'Cancel appointment', expand: true, onPressed: () => Navigator.pop(context, true)),
///     FadeButton.ghost(label: 'Keep it', expand: true, onPressed: () => Navigator.pop(context, false)),
///   ],
/// );
/// ```
Future<T?> showFadeSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  String? subtitle,
  List<Widget> actions = const [],
  bool isDismissible = true,
  bool scrollable = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FadeSheetBody(
      title: title,
      subtitle: subtitle,
      actions: actions,
      scrollable: scrollable,
      child: child,
    ),
  );
}

/// Layout used by [showFadeSheet]. Exposed for custom sheets.
class FadeSheetBody extends StatelessWidget {
  const FadeSheetBody({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.scrollable = true,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        FadeSpace.gutter,
        0,
        FadeSpace.gutter,
        FadeSpace.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Semantics(
              header: true,
              child: Text(
                title!,
                style: FadeType.h2.copyWith(color: c.textPrimary),
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: FadeSpace.s4),
            Text(
              subtitle!,
              style: FadeType.bodySm.copyWith(color: c.textSecondary),
            ),
          ],
          if (title != null || subtitle != null)
            const SizedBox(height: FadeSpace.s16),
          DefaultTextStyle.merge(
            style: FadeType.body.copyWith(color: c.textSecondary),
            child: child,
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: scrollable ? SingleChildScrollView(child: content) : content,
          ),
          if (actions.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  FadeSpace.gutter,
                  FadeSpace.s8,
                  FadeSpace.gutter,
                  FadeSpace.s16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(height: FadeSpace.s8),
                      SizedBox(width: double.infinity, child: actions[i]),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
