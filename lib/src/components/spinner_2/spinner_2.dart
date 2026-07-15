import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import 'spinner_2_variants.dart';

// The `resolveDsSpinnerStyle` function consumed by `build()` below lives in
// spinner_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsSpinner while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'spinner_2_style_resolver.dart';

/// An indeterminate loading indicator built on top of the `remix` package's
/// [RemixSpinner], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `Spinner` (a private `CustomPaint` +
/// `RotationTransition` pair), [DsSpinner] delegates all animation and
/// painting to [RemixSpinner] and only supplies a resolved
/// [RemixSpinnerStyle] — see [resolveDsSpinnerStyle] — for [size] and
/// [inverted].
///
/// No variant axis — like [DsSwitch], a spinner has no visual skin to pick
/// between, just a size scale and a boolean color switch for placement on
/// light vs. dark/brand surfaces.
class DsSpinner extends StatelessWidget {
  const DsSpinner({
    super.key,
    this.size = DsSpinnerSize.md,
    this.inverted = false,
    this.style = const RemixSpinnerStyle.create(),
    this.styleSpec,
  });

  /// Physical size — see [DsSpinnerSize].
  final DsSpinnerSize size;

  /// Public state: swaps to the on-brand foreground color for use on
  /// dark/brand-colored surfaces (e.g. inside a primary [DsButton] or on
  /// `surface.inverted`). When false (default), uses the muted secondary
  /// content color, correct for use on `canvas`/`surface.base`. Never
  /// inferred — always driven by this constructor param.
  final bool inverted;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsSpinnerStyle]'s output) — e.g. to
  /// add a track via `.spinnerTrackColor(...)`.
  final RemixSpinnerStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixSpinnerSpec] directly, bypassing style resolution entirely.
  /// Unlike [DsButton]/[DsInput]'s own `styleSpec` (a bare `*Spec?`),
  /// [RemixSpinner] extends `StyleWidget<RemixSpinnerSpec>`, so this must
  /// be the wrapped `StyleSpec<RemixSpinnerSpec>?` its `super.styleSpec`
  /// expects.
  final StyleSpec<RemixSpinnerSpec>? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSpinnerStyle(
      size: size,
      inverted: inverted,
    ).merge(style);

    return RemixSpinner(style: resolvedStyle, styleSpec: styleSpec);
  }
}
