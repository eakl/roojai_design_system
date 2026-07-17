import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import 'slider_2_variants.dart';

// The `resolveDsSliderStyle` function consumed by `build()` below lives in
// slider_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsSlider while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'slider_2_style_resolver.dart';

/// A continuous-value drag control built on top of the `remix` package's
/// [RemixSlider], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppSlider`, [DsSlider] delegates all
/// interaction handling (drag/tap, haptics, focus, semantics) to
/// [RemixSlider] and only supplies a resolved [RemixSliderStyler] — see
/// [resolveDsSliderStyle] — for [size] and the disabled state.
class DsSlider extends StatelessWidget {
  const DsSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.size = DsSliderSize.md,
    this.enabled = true,
    this.enableHapticFeedback = true,
    this.snapDivisions,
    this.focusNode,
    this.autofocus = false,
    this.style = const RemixSliderStyler.create(),
    this.styleSpec,
  });

  /// The slider's current value. Always reflects the caller's state — this
  /// widget holds no internal value of its own. Must fall within
  /// [min]..[max] (asserted by the underlying [RemixSlider]).
  final double value;

  /// Called during drag (and on track tap) with the new value. Ignored
  /// (and the slider rendered non-interactive) while [enabled] is false, or
  /// when null.
  final ValueChanged<double>? onChanged;

  /// The lower bound of the slider's range.
  final double min;

  /// The upper bound of the slider's range.
  final double max;

  /// Called when the user starts dragging the thumb.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done dragging the thumb.
  final ValueChanged<double>? onChangeEnd;

  /// Physical size — see [DsSliderSize].
  final DsSliderSize size;

  /// Public state: disables drag/tap/focus and renders a dimmed slider when
  /// false. [value] still governs thumb position while disabled, so the
  /// slider keeps communicating where it's set. Never inferred — always
  /// driven by this constructor param.
  final bool enabled;

  /// Whether to provide haptic feedback during value changes.
  final bool enableHapticFeedback;

  /// Optional interaction-only step snapping — the thumb snaps to this many
  /// discrete steps between [min] and [max], but no visual tick marks are
  /// rendered (matches [RemixSlider.snapDivisions]'s own doc comment).
  final int? snapDivisions;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixSlider]/`NakedSlider`.
  final FocusNode? focusNode;

  /// Whether this slider should request focus when first built.
  final bool autofocus;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsSliderStyle]'s output).
  final RemixSliderStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixSliderSpec] directly, bypassing style resolution entirely.
  final RemixSliderSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSliderStyle(
      size: size,
      disabled: !enabled,
    ).merge(style);

    return RemixSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      enabled: enabled,
      enableFeedback: enableHapticFeedback,
      snapDivisions: snapDivisions,
      focusNode: focusNode,
      autofocus: autofocus,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
