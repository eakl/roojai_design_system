import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'toggle_2_variants.dart';

// The `resolveDsToggleStyle` function consumed by `build()` below lives in
// toggle_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsToggle while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'toggle_2_style_resolver.dart';

/// A pressable button that stays visually active when [selected], built on
/// top of the `remix` package's [RemixToggle], styled through the design
/// system's Mix semantic tokens.
///
/// Unlike [RemixSwitch]/[DsSwitch] (a sliding on/off track), [DsToggle] is
/// the whole button itself acting as the on/off affordance — for formatting
/// controls (e.g. "Bold" in a toolbar), filter chips, and tool-state
/// representation.
///
/// Unlike the legacy hand-rolled `Toggle` (a `GestureDetector` +
/// `AnimatedContainer` pair), [DsToggle] delegates all interaction handling
/// (tap gesture, hover/press/focus, semantics) to [RemixToggle] and only
/// supplies a resolved [RemixToggleStyler] — see [resolveDsToggleStyle] — for
/// [variant] and [size]. See
/// `docs/superpowers/specs/2026-07-15-toggle-2-component-design.md`.
class DsToggle extends StatelessWidget {
  const DsToggle({
    super.key,
    required this.selected,
    this.onChanged,
    this.label,
    this.icon,
    this.variant = DsToggleVariant.ghost,
    this.size = DsToggleSize.md,
    this.enabled = true,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixToggleStyler.create(),
    this.styleSpec,
  }) : assert(
         label != null || icon != null,
         'At least one of label or icon must be provided',
       );

  /// Public state: whether the toggle is currently "on". Always reflects
  /// the caller's state — this widget holds no internal on/off state of
  /// its own. Never inferred, same convention as [DsSwitch.selected].
  final bool selected;

  /// Called with the new value on tap. Ignored (and the toggle rendered
  /// non-interactive) while [enabled] is false, or when null — same
  /// contract as [DsSwitch.onChanged]. Nullable unlike [RemixToggle]'s own
  /// `onChanged` (required non-null): [_isEnabled] folds this null check
  /// in before forwarding to [RemixToggle].
  final ValueChanged<bool>? onChanged;

  /// Optional text label. At least one of [label]/[icon] must be provided
  /// (enforced by this constructor's assert), mirroring [RemixToggle]'s own
  /// contract.
  final String? label;

  /// Optional icon. Unlike [DsButton]'s `leadingIcon`/`trailingIcon` pair,
  /// [RemixToggle] exposes only a single icon slot, so [DsToggle] follows
  /// that shape rather than reintroducing the legacy `Toggle`'s
  /// `leading`/`trailing` pair.
  final IconData? icon;

  /// Visual treatment — see [DsToggleVariant].
  final DsToggleVariant variant;

  /// Physical size — see [DsToggleSize].
  final DsToggleSize size;

  /// Public state: renders muted colors and suppresses taps/focus when
  /// false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to provide platform feedback (e.g. haptics) on toggle.
  final bool enableFeedback;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixToggle]/`NakedToggle`.
  final FocusNode? focusNode;

  /// Whether this toggle should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsToggleStyle]'s output).
  final RemixToggleStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixToggleSpec] directly, bypassing style resolution entirely.
  final RemixToggleSpec? styleSpec;

  /// True when the toggle accepts taps at all. [enabled] always wins, and a
  /// null [onChanged] makes the toggle inert even when [enabled] is true —
  /// mirrors [DsSwitch]'s `_isEnabled` getter.
  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsToggleStyle(
      variant: variant,
      size: size,
      disabled: !_isEnabled,
    ).merge(style);

    return RemixToggle(
      selected: selected,
      // `RemixToggle.onChanged` is non-null; `_isEnabled` already gates
      // real interactivity via `enabled` below, so this fallback is never
      // invoked while non-interactive.
      onChanged: onChanged ?? (_) {},
      enabled: _isEnabled,
      label: label,
      icon: icon,
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
