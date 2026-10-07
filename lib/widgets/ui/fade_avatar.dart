import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum FadeAvatarSize { xs, sm, md, lg, xl }

/// Circular avatar: photo when available, otherwise initials on a neutral
/// fill. Optional gold ring (e.g. "your profile") and status dot.
class FadeAvatar extends StatelessWidget {
  const FadeAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = FadeAvatarSize.md,
    this.ring = false,
    this.statusColor,
  });

  final String name;
  final String? imageUrl;
  final FadeAvatarSize size;
  final bool ring;

  /// Small dot bottom-right (e.g. success = available today).
  final Color? statusColor;

  double get _d => switch (size) {
    FadeAvatarSize.xs => 24,
    FadeAvatarSize.sm => 32,
    FadeAvatarSize.md => 40,
    FadeAvatarSize.lg => 56,
    FadeAvatarSize.xl => 96,
  };

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final d = _d;

    final initials = Center(
      child: Text(
        initialsOf(name),
        style: FadeType.label.copyWith(
          color: c.textSecondary,
          fontSize: d * 0.38,
          height: 1,
        ),
      ),
    );

    Widget face = Container(
      width: d,
      height: d,
      decoration: BoxDecoration(color: c.surfaceHigh, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? initials
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: d,
              height: d,
              errorBuilder: (_, _, _) => initials,
            ),
    );

    if (ring) {
      face = Container(
        padding: EdgeInsets.all(d >= 56 ? 3 : 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.accent, width: d >= 56 ? 2 : 1.5),
        ),
        child: face,
      );
    }

    if (statusColor != null) {
      final dot = (d * 0.28).clamp(8.0, 16.0);
      face = Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: c.background, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: name,
      image: true,
      child: ExcludeSemantics(child: face),
    );
  }
}
