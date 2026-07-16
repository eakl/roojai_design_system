import 'package:flutter/widgets.dart' hide Icon;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import 'checkbox_2_variants.dart';

// The `resolveDsCheckboxStyle` function consumed by `build()` below lives in
// checkbox_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsCheckbox while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'checkbox_2_style_resolver.dart';

/// A tri-state selection control built on top of the `remix` package's
/// [RemixCheckbox], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppCheckbox` (a `GestureDetector` +
/// `AnimatedContainer`/`CustomPaint` glyph painter), [DsCheckbox] delegates
/// all interaction handling (tap gesture, hover/press/focus, semantics) to
/// [RemixCheckbox] and only supplies a resolved [RemixCheckboxStyler] — see
/// [resolveDsCheckboxStyle] — for [size].
///
/// No label/description slot — same as legacy `AppCheckbox`, composing an
/// adjacent label is the caller's responsibility (e.g.
/// `Row([DsCheckbox(...), Text(...)])`).
class DsCheckbox extends StatelessWidget {
  const DsCheckbox({
    super.key,
    required this.selected,
    this.onChanged,
    this.size = DsCheckboxSize.md,
    this.enabled = true,
    this.tristate = false,
    this.checkedIcon,
    this.uncheckedIcon,
    this.indeterminateIcon,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = true,
    this.semanticLabel,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixCheckboxStyler.create(),
    this.styleSpec,
  });

  /// Public state: whether the checkbox is checked. When [tristate] is
  /// true, `null` renders the indeterminate glyph. Always reflects the
  /// caller's state — this widget holds no internal checked/unchecked
  /// state of its own, same convention as legacy `AppCheckbox.value` and
  /// `DsSwitch.selected`.
  final bool? selected;

  /// Called with the next value on tap. When [tristate] is false the value
  /// is always non-null. Ignored (and the checkbox rendered
  /// non-interactive) while [enabled] is false, or when null — same
  /// contract as `DsButton.onPressed`.
  final ValueChanged<bool?>? onChanged;

  /// Physical size — see [DsCheckboxSize].
  final DsCheckboxSize size;

  /// Public state: renders muted colors and suppresses taps/focus when
  /// false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether [selected] can be `null` (indeterminate) in addition to
  /// `true`/`false`. Mirrors legacy `AppCheckbox`'s
  /// `CheckboxValue.indeterminate` state.
  final bool tristate;

  /// Icon shown when [selected] is `true`. Defaults to a bold checkmark
  /// glyph from `phosphor_flutter`, matching the design system's
  /// preference for Phosphor icons over Material's `Icons`.
  final IconData? checkedIcon;

  /// Icon shown when [selected] is `false`. Defaults to none, same as
  /// [RemixCheckbox].
  final IconData? uncheckedIcon;

  /// Icon shown when [selected] is `null` (only reachable when [tristate]
  /// is true). Defaults to a bold dash glyph from `phosphor_flutter`.
  final IconData? indeterminateIcon;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixCheckbox]/`NakedCheckbox`.
  final FocusNode? focusNode;

  /// Whether this checkbox should request focus when first built.
  final bool autofocus;

  /// Whether to provide platform feedback (e.g. haptics) on toggle.
  final bool enableFeedback;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsCheckboxStyle]'s output).
  final RemixCheckboxStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixCheckboxSpec] directly, bypassing style resolution entirely.
  final RemixCheckboxSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCheckboxStyle(size: size).merge(style);

    return RemixCheckbox(
      selected: selected,
      onChanged: onChanged,
      enabled: enabled,
      tristate: tristate,
      checkedIcon: checkedIcon ?? PhosphorIcons.check(PhosphorIconsStyle.bold),
      uncheckedIcon: uncheckedIcon,
      indeterminateIcon:
          indeterminateIcon ?? PhosphorIcons.minus(PhosphorIconsStyle.bold),
      focusNode: focusNode,
      autofocus: autofocus,
      enableFeedback: enableFeedback,
      semanticLabel: semanticLabel,
      mouseCursor: mouseCursor,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
