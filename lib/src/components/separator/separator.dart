import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import 'separator_orientation.dart';

/// A thin dividing line built from a plain `ColoredBox` sized via
/// `FractionallySizedBox` (no Material `Divider`/`VerticalDivider`).
///
/// Mirrors shadcn's `Separator`: purely decorative (it carries no
/// semantics beyond a visual break between content) and, by default,
/// fills 100% of the space its parent gives it along its own axis — the
/// same "just works" behavior as shadcn's Separator rendering `w-full` /
/// `h-full` in CSS. [length] generalizes that to any percentage, letting a
/// caller draw a partial-width/height rule (e.g. a short divider under a
/// section title) without needing to wrap the widget in a sizing box
/// themselves.
///
/// Because [length] is resolved as a *fraction of the incoming layout
/// constraints* (via `FractionallySizedBox`), this widget requires a
/// bounded constraint along its [orientation] axis — e.g. inside a
/// `Column` (for horizontal) or a sized `Row` cell / `SizedBox` (for
/// vertical). This is the direct Flutter analogue of the CSS requirement
/// that a `width: 100%` element's ancestor chain resolve to a definite
/// width; an unbounded ancestor (e.g. a bare `Row` for a vertical
/// separator with no height constraint) will hit the same
/// "unbounded constraints" error `FractionallySizedBox` always raises in
/// that situation.
class Separator extends StatelessWidget {
  const Separator({
    super.key,
    this.orientation = SeparatorOrientation.horizontal,
    this.length = 100,
  }) : assert(
          length > 0 && length <= 100,
          'length is a percentage of the available space and must be in '
          'the range (0, 100].',
        );

  /// Which axis the line is drawn along — see [SeparatorOrientation].
  final SeparatorOrientation orientation;

  /// How much of the available space (as a percentage, 0 exclusive to 100
  /// inclusive) the line spans along [orientation]'s axis. Defaults to
  /// 100, i.e. the full width (horizontal) or full height (vertical) of
  /// whatever bounded space the parent provides — matching shadcn's
  /// full-bleed default.
  final double length;

  @override
  Widget build(BuildContext context) {
    // --- Tokens ---------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties ---------------------------------------------
    final isHorizontal = _resolveIsHorizontal(orientation);
    final lengthFactor = _resolveLengthFactor(length);
    final thickness = _resolveThickness();

    // --- Layout -----------------------------------------------------------
    // The outer FractionallySizedBox constrains only the `orientation`
    // axis to `lengthFactor` of the available space; the other axis is
    // left null so it falls through to the inner SizedBox's fixed
    // `thickness`, giving a hairline in the cross axis regardless of how
    // much space the parent offers there.
    return FractionallySizedBox(
      widthFactor: isHorizontal ? lengthFactor : null,
      heightFactor: isHorizontal ? null : lengthFactor,
      child: SizedBox(
        width: isHorizontal ? null : thickness,
        height: isHorizontal ? thickness : null,
        child: ColoredBox(color: colors.border.base),
      ),
    );
  }
}

// Style/layout resolvers for Separator. One pure function per resolved
// property, same convention as Button/Badge's `_resolve*` split — kept
// inline here (no separate `_style_resolvers.dart` part file) since
// Separator has no variant x state matrix, just three small, single-axis
// resolvers.

bool _resolveIsHorizontal(SeparatorOrientation orientation) {
  return orientation == SeparatorOrientation.horizontal;
}

/// Converts the public 0–100 percentage into the 0.0–1.0 factor
/// `FractionallySizedBox` expects.
double _resolveLengthFactor(double length) {
  return length / 100;
}

/// Fixed hairline thickness for the cross axis, independent of
/// [Separator.length] (which only ever governs the *long* axis).
double _resolveThickness() {
  return 1;
}
