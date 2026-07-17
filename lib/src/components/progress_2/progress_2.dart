import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import 'progress_2_variants.dart';

// The `resolveDsProgressStyle` function consumed by `build()` below lives in
// progress_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsProgress while living in its
// own file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'progress_2_style_resolver.dart';

/// A determinate progress indicator built on top of the `remix` package's
/// [RemixProgress], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `Progress` (a `Stack` + `DecoratedBox` pair
/// with its own label/value annotation rows), [DsProgress] delegates all
/// layout and painting to [RemixProgress] and only supplies a resolved
/// [RemixProgressStyler] — see [resolveDsProgressStyle] — for [size].
///
/// No label/value slots — same as legacy `Progress`'s optional annotation
/// rows, [RemixProgress] has no such content slots to forward them to, so
/// composing adjacent label/value text is the caller's responsibility (e.g.
/// wrapping this widget in a `Column` with `Text` rows above/below), same
/// convention `DsSwitch` uses for its adjacent label.
///
/// No variant axis — like [DsSwitch]/[DsInput], a progress bar has no
/// visual-skin to pick between, just a size scale and its fill [value].
class DsProgress extends StatelessWidget {
  const DsProgress({
    super.key,
    required this.value,
    this.size = DsProgressSize.md,
    this.style = const RemixProgressStyler.create(),
    this.styleSpec,
  }) : assert(
         value >= 0 && value <= 1,
         'DsProgress.value must be between 0 and 1 (got $value).',
       );

  /// Public state: how full the indicator is, from 0 to 1. Unlike
  /// [DsButton]/[DsSwitch]'s boolean state, this can't sensibly default, so
  /// it's a required constructor param — same contract as
  /// [RemixProgress.value].
  final double value;

  /// Physical size — see [DsProgressSize].
  final DsProgressSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsProgressStyle]'s output) — e.g. to
  /// override `.trackColor(...)`/`.indicatorColor(...)`, same pattern
  /// [DsButton]/[DsSwitch] use for their own color overrides.
  final RemixProgressStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixProgressSpec] directly, bypassing style resolution entirely —
  /// forwarded as-is to [RemixProgress.styleSpec], which now takes the bare
  /// `RemixProgressSpec?`, same shape [DsButton]/[DsInput]'s own `styleSpec`
  /// fields have.
  final RemixProgressSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsProgressStyle(size: size).merge(style);

    return RemixProgress(
      value: value,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
