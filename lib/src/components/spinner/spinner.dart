import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'spinner_size.dart';

/// An indeterminate loading indicator built from `CustomPaint` +
/// `RotationTransition` (no Material `CircularProgressIndicator`).
///
/// Mirrors the private spinner `Button` already paints for its own
/// `loading` state (see `_ButtonSpinner`/`_SpinnerPainter` in
/// `button.dart`) but exposed as a standalone component with its own size
/// scale and an [inverted] flag for placement on dark/brand surfaces.
class Spinner extends StatefulWidget {
  const Spinner({
    super.key,
    this.size = SpinnerSize.md,
    this.inverted = false,
  });

  /// Physical size — see [SpinnerSize].
  final SpinnerSize size;

  /// Swaps to the on-brand foreground color for use on dark/brand-colored
  /// backgrounds (e.g. inside a primary [Button] or on `surface.inverted`).
  /// When false (default), uses the muted secondary content color, which
  /// is correct for use on `canvas`/`surface.base`.
  final bool inverted;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner>
    with SingleTickerProviderStateMixin {
  // A spinner is indeterminate — it has no "finished" state — so the
  // controller just repeats forever from initState to dispose, same
  // lifecycle shape as Button's private `_ButtonSpinnerState`.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties ------------------------------------------------
    final diameter = _resolveDiameter(widget.size);
    final strokeWidth = _resolveStrokeWidth(widget.size);
    final color = _resolveColor(colors, widget.inverted);

    // --- Layout ---------------------------------------------------------------
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: CustomPaint(
          painter: _SpinnerPainter(color: color, strokeWidth: strokeWidth),
        ),
      ),
    );
  }
}

/// Paints a three-quarter arc, so the ring reads as spinning while
/// [RotationTransition] rotates it, rather than as a static ring — the
/// same shape Button's private `_SpinnerPainter` paints in `button.dart`.
class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    // Three-quarter arc (in radians): drawn from angle 0 sweeping ~270°.
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 4.71, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Style/layout resolvers for Spinner. One pure function per resolved
// property, same convention as Button/Badge's `_resolve*` split — kept
// inline here (no separate `_style_resolvers.dart` part file) since
// Spinner has no variant x state matrix, just two small, single-axis
// resolvers plus a boolean color switch, the same shape as Separator's
// inline resolvers.

double _resolveDiameter(SpinnerSize size) {
  switch (size) {
    case SpinnerSize.sm:
      return 16;
    case SpinnerSize.md:
      return 24;
    case SpinnerSize.lg:
      return 32;
  }
}

double _resolveStrokeWidth(SpinnerSize size) {
  switch (size) {
    case SpinnerSize.sm:
      return 2;
    case SpinnerSize.md:
      return 2.5;
    case SpinnerSize.lg:
      return 3;
  }
}

Color _resolveColor(SemanticColors colors, bool inverted) {
  return inverted ? colors.content.onBrand : colors.content.secondary;
}
