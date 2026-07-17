import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import 'radio_2_variants.dart';

// The `resolveDsRadioStyle` function consumed by `build()` below lives in
// radio_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsRadio while living in its own
// file — same split as `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'radio_2_style_resolver.dart';

/// Groups multiple [DsRadio] widgets, tracking a single selected value —
/// a thin wrapper over the `remix` package's [RemixRadioGroup].
///
/// Unlike the legacy hand-rolled `AppRadio` (which reports every tap via
/// `onSelect` and leaves exclusivity entirely up to the caller), [DsRadio]
/// only works inside a [DsRadioGroup] ancestor — same requirement
/// `RemixRadio` places on `RemixRadioGroup` — which owns [groupValue] and
/// calls [onChanged] with the newly-selected value.
class DsRadioGroup<T> extends StatelessWidget {
  const DsRadioGroup({
    super.key,
    required this.groupValue,
    this.onChanged,
    required this.child,
  });

  /// The currently selected value for the group. Always reflects the
  /// caller's state — this widget holds no internal selection state of its
  /// own, same convention as `DsSwitch`'s `selected`.
  final T? groupValue;

  /// Called with the newly-selected value when a [DsRadio] descendant is
  /// tapped. When null, the whole group is rendered non-interactive — same
  /// contract as [RemixRadioGroup.onChanged].
  final ValueChanged<T?>? onChanged;

  /// The [DsRadio] widgets (and any surrounding layout/labels) that make up
  /// this group.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RemixRadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// A single-select control built on top of the `remix` package's
/// [RemixRadio], styled through the design system's Mix semantic tokens.
/// Must be used within a [DsRadioGroup] ancestor.
///
/// Unlike the legacy hand-rolled `AppRadio` (a `GestureDetector` +
/// `AnimatedContainer`/`AnimatedScale` pair), [DsRadio] delegates all
/// interaction handling (tap gesture, hover/press/focus, semantics,
/// exclusive-select bookkeeping) to [RemixRadio]/[RemixRadioGroup] and only
/// supplies a resolved [RemixRadioStyler] — see [resolveDsRadioStyle] — for
/// [size].
///
/// No label/description slot — same as legacy `AppRadio`, composing an
/// adjacent label is the caller's responsibility (e.g.
/// `Row([DsRadio(...), Text(...)])`).
class DsRadio<T> extends StatelessWidget {
  const DsRadio({
    super.key,
    required this.value,
    this.size = DsRadioSize.md,
    this.enabled = true,
    this.toggleable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.style = const RemixRadioStyler.create(),
    this.styleSpec,
  });

  /// The value this radio represents within its [DsRadioGroup]. This radio
  /// renders selected when it equals the group's `groupValue`.
  final T value;

  /// Physical size — see [DsRadioSize].
  final DsRadioSize size;

  /// Public state: renders muted colors and suppresses taps/focus when
  /// false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether tapping an already-selected radio deselects it (setting the
  /// group's value back to `null`). Defaults to false — same exclusive,
  /// non-deselectable behavior as legacy `AppRadio`.
  final bool toggleable;

  /// Cursor shown while hovering. Defaults to [RemixRadio]'s own default
  /// when null.
  final MouseCursor? mouseCursor;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixRadio]/`NakedRadio`.
  final FocusNode? focusNode;

  /// Whether this radio should request focus when first built.
  final bool autofocus;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsRadioStyle]'s output).
  final RemixRadioStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixRadioSpec] directly, bypassing style resolution entirely.
  final RemixRadioSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsRadioStyle(size: size).merge(style);

    return RemixRadio<T>(
      value: value,
      enabled: enabled,
      toggleable: toggleable,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      autofocus: autofocus,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
