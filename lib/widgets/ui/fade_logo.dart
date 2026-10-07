import 'package:flutter/material.dart';

import '../../theme/theme.dart';

// Vector logo drawn in code from the same geometry as assets/brand/svg/*.svg,
// so it needs no pubspec asset entry and stays crisp at any size.
// Grid: cap height = 100 units. The F's stem "fades" into slices of shrinking
// height: the brand's signature detail.

Path _fPath({double ox = 0, bool icon = false}) {
  final p = Path()
    ..moveTo(ox, 0)
    ..relativeLineTo(62, 0)
    ..relativeLineTo(0, 22)
    ..relativeLineTo(-40, 0)
    ..relativeLineTo(0, 18)
    ..relativeLineTo(32, 0)
    ..relativeLineTo(0, 20)
    ..relativeLineTo(-32, 0)
    ..relativeLineTo(0, icon ? 3 : 4)
    ..relativeLineTo(-22, 0)
    ..close();
  final slices = icon
      ? const [(69.0, 12.0), (86.0, 8.0)]
      : const [(68.0, 11.0), (83.0, 8.0), (95.0, 5.0)];
  for (final (y, h) in slices) {
    p.addRect(Rect.fromLTWH(ox, y, 22, h));
  }
  return p;
}

Path _restOfWordmark() {
  const a = 66.0, d = 166.0, e = 268.0;
  final p = Path()..fillType = PathFillType.evenOdd;
  // A
  p
    ..moveTo(a + 0, 100)
    ..lineTo(a + 30, 0)
    ..lineTo(a + 58, 0)
    ..lineTo(a + 88, 100)
    ..lineTo(a + 64, 100)
    ..lineTo(a + 57.4, 78)
    ..lineTo(a + 30.6, 78)
    ..lineTo(a + 24, 100)
    ..close()
    ..moveTo(a + 44, 33.33)
    ..lineTo(a + 52, 60)
    ..lineTo(a + 36, 60)
    ..close();
  // D
  p
    ..moveTo(d, 0)
    ..lineTo(d + 38, 0)
    ..arcToPoint(const Offset(d + 38, 100), radius: const Radius.circular(50))
    ..lineTo(d, 100)
    ..close()
    ..moveTo(d + 22, 22)
    ..lineTo(d + 38, 22)
    ..arcToPoint(const Offset(d + 38, 78), radius: const Radius.circular(28))
    ..lineTo(d + 22, 78)
    ..close();
  // E
  p
    ..moveTo(e, 0)
    ..relativeLineTo(62, 0)
    ..relativeLineTo(0, 22)
    ..relativeLineTo(-40, 0)
    ..relativeLineTo(0, 17)
    ..relativeLineTo(34, 0)
    ..relativeLineTo(0, 22)
    ..relativeLineTo(-34, 0)
    ..relativeLineTo(0, 17)
    ..relativeLineTo(40, 0)
    ..relativeLineTo(0, 22)
    ..relativeLineTo(-62, 0)
    ..close();
  return p;
}

const double _wordmarkWidth = 330;

/// The FADE wordmark. Defaults: bone letters + gold F on dark, ink on light.
class FadeWordmark extends StatelessWidget {
  const FadeWordmark({
    super.key,
    this.height = 24,
    this.color,
    this.accentColor,
  });

  final double height;

  /// Letter color. Defaults to text primary.
  final Color? color;

  /// Color of the F. Defaults to gold in dark mode, [color] in light mode.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final letters = color ?? c.textPrimary;
    final f = accentColor ?? (context.isDarkMode ? FadePalette.gold : letters);
    return Semantics(
      label: 'Fade',
      image: true,
      child: CustomPaint(
        size: Size(height * _wordmarkWidth / 100, height),
        painter: _WordmarkPainter(letters, f),
      ),
    );
  }
}

/// The fading-F logomark on its own.
class FadeLogomark extends StatelessWidget {
  const FadeLogomark({super.key, this.height = 32, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Fade',
      image: true,
      child: CustomPaint(
        size: Size(height * 0.62, height),
        painter: _MarkPainter(color ?? context.fadeColors.accentText),
      ),
    );
  }
}

/// App-icon style badge (gold square, ink F). For headers, splash, empty states.
class FadeAppBadge extends StatelessWidget {
  const FadeAppBadge({super.key, this.size = 48, this.inverted = false});

  final double size;

  /// Ink square with gold F.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? FadePalette.ink : FadePalette.gold,
        borderRadius: BorderRadius.circular(size * 0.225),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: size * 0.04),
      child: CustomPaint(
        size: Size(size * 0.58 * 0.62, size * 0.58),
        painter: _MarkPainter(
          inverted ? FadePalette.gold : FadePalette.ink,
          icon: true,
        ),
      ),
    );
  }
}

class _WordmarkPainter extends CustomPainter {
  _WordmarkPainter(this.letters, this.f);
  final Color letters;
  final Color f;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 100;
    canvas.save();
    canvas.scale(s);
    canvas.drawPath(_fPath(), Paint()..color = f);
    canvas.drawPath(_restOfWordmark(), Paint()..color = letters);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) =>
      old.letters != letters || old.f != f;
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color, {this.icon = false});
  final Color color;
  final bool icon;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.height / 100);
    canvas.drawPath(_fPath(icon: icon), Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.icon != icon;
}
