import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import 'switch_2_variants.dart';

// The `resolveDsSwitchStyle` function consumed by `build()` below lives in
// switch_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsSwitch while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsInput`'s `input_2_style_resolver.dart`.
part 'switch_2_style_resolver.dart';

/// A binary on/off control built on top of the `remix` package's
/// [RemixSwitch], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppSwitch` (a `GestureDetector` +
/// `AnimatedContainer`/`AnimatedAlign` pair), [DsSwitch] delegates all
/// interaction handling (toggle gesture, hover/press/focus, semantics) to
/// [RemixSwitch] and only supplies a resolved [RemixSwitchStyle] — see
/// [resolveDsSwitchStyle] — for [size].
///
/// No label/description slot — same as legacy `AppSwitch`, composing an
/// adjacent label is the caller's responsibility (e.g.
/// `Row([DsSwitch(...), Text(...)])`). See
/// `docs/superpowers/specs/2026-07-15-switch-2-component-design.md`.
class DsSwitch extends StatelessWidget {
  const DsSwitch({
    super.key,
    required this.selected,
    this.onChanged,
    this.size = DsSwitchSize.md,
    this.enabled = true,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixSwitchStyle.create(),
    this.styleSpec,
  });

  /// Public state: whether the switch is on. Always reflects the caller's
  /// state — this widget holds no internal on/off state of its own. Never
  /// inferred, same convention as [DsButton]'s `loading`/`enabled`.
  final bool selected;

  /// Called with the new value on toggle. Ignored (and the switch rendered
  /// non-interactive) while [enabled] is false, or when null — same
  /// contract as [DsButton.onPressed]. Nullable unlike [RemixSwitch]'s own
  /// `onChanged` (required non-null): [_isEnabled] folds this null check
  /// in before forwarding to [RemixSwitch].
  final ValueChanged<bool>? onChanged;

  /// Physical size — see [DsSwitchSize].
  final DsSwitchSize size;

  /// Public state: renders muted track/thumb colors and suppresses toggling
  /// when false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to provide platform feedback (e.g. haptics) on toggle.
  final bool enableFeedback;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixSwitch]/`NakedToggle`.
  final FocusNode? focusNode;

  /// Whether this switch should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsSwitchStyle]'s output).
  final RemixSwitchStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixSwitchSpec] directly, bypassing style resolution entirely.
  final RemixSwitchSpec? styleSpec;

  /// True when the switch accepts toggles at all. [enabled] always wins,
  /// and a null [onChanged] makes the switch inert even when [enabled] is
  /// true — mirrors [DsButton]'s `_interactive` getter.
  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSwitchStyle(
      size: size,
      disabled: !_isEnabled,
    ).merge(style);

    return RemixSwitch(
      selected: selected,
      // `RemixSwitch.onChanged` is non-null; `_isEnabled` already gates
      // real interactivity via `enabled` below, so this fallback is never
      // invoked while non-interactive.
      onChanged: onChanged ?? (_) {},
      enabled: _isEnabled,
      enableFeedback: enableFeedback,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      mouseCursor: mouseCursor,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
