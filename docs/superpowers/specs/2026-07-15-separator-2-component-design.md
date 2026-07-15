# `separator_2` (`DsSeparator`) design

## Context

Continues the `_2` migration onto `remix`/`mix` established by `button_2`,
`input_2`, `select_2`, `switch_2`, `toggle_2`, `progress_2`, `spinner_2`,
`tabs_2`, `skeleton_2`. This spec covers `separator_2`, replacing the legacy
`Separator` (a hand-rolled `ColoredBox` + `FractionallySizedBox`) with a
thin wrapper around Remix's `RemixDivider`
(https://docs.page/btwld/remix/components/divider).
`lib/ui.dart` already has the legacy `separator`/`separator_orientation`
exports commented out, marking the slot `separator_2` is meant to fill.

Unlike the legacy widget, `RemixDivider` is horizontal-only by construction:
its `RemixDividerStyle.thickness(value)` always sets `minHeight`/`maxHeight`
on the underlying `Box` (never width), and the widget has no
`orientation`/length concept at all — a caller gets a hairline that stretches
to fill whatever width its parent offers, full stop. `DsSeparator` preserves
the legacy widget's `orientation` (horizontal/vertical) and `length`
(0–100 percentage) API on top of `RemixDivider` — this DS's own addition,
with no Remix/Fortal precedent, same kind of "own addition built from the
same semantic tokens" `tabs_2`'s `segmented` variant spec calls out.

## File structure

```
lib/src/components/separator_2/
  separator_2.dart                 — DsSeparator widget
  separator_2_style_resolver.dart  — part of separator_2.dart; resolveDsSeparatorStyle()
  separator_2_orientation.dart     — DsSeparatorOrientation enum
```

## `separator_2_orientation.dart`

Direct rename of the legacy `SeparatorOrientation` enum, doc comments
carried over unchanged:

```dart
enum DsSeparatorOrientation { horizontal, vertical }
```

## Widget API (`separator_2.dart`)

Same public shape as the legacy `Separator` (`orientation`, `length`),
`Ds`-prefixed per convention, plus `style`/`styleSpec` escape hatches
matching `DsToggle`/`DsSwitch`'s convention for direct `Remix*` wrappers
(`RemixDivider` itself takes both):

```dart
class DsSeparator extends StatelessWidget {
  const DsSeparator({
    super.key,
    this.orientation = DsSeparatorOrientation.horizontal,
    this.length = 100,
    this.style = const RemixDividerStyle.create(),
    this.styleSpec,
  }) : assert(
         length > 0 && length <= 100,
         'length is a percentage of the available space and must be in '
         'the range (0, 100].',
       );

  /// Which axis the line is drawn along — see [DsSeparatorOrientation].
  final DsSeparatorOrientation orientation;

  /// How much of the available space (as a percentage, 0 exclusive to 100
  /// inclusive) the line spans along [orientation]'s axis. Defaults to
  /// 100 — same full-bleed default as the legacy `Separator.length`.
  final double length;

  /// Escape hatch merged on top of [resolveDsSeparatorStyle]'s output —
  /// same convention as [DsToggle.style].
  final RemixDividerStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixDividerSpec] directly, bypassing style resolution entirely —
  /// same convention as [DsToggle.styleSpec]. `RemixDivider` extends Mix's
  /// `StyleWidget` directly (unlike `RemixToggle`, a `StatelessWidget`
  /// with its own `RemixToggleSpec?` field), so this takes the wrapped
  /// `StyleSpec<RemixDividerSpec>?` its `styleSpec` field actually expects.
  final StyleSpec<RemixDividerSpec>? styleSpec;
}
```

Same bounded-constraint requirement the legacy widget documents carries
over unchanged: `DsSeparator` needs a bounded constraint along its
`orientation` axis (e.g. inside a `Column` for horizontal, or a sized `Row`
cell/`SizedBox` for vertical) since `length` is resolved as a fraction of
the incoming layout constraints via `FractionallySizedBox`.

### `build()`

```dart
@override
Widget build(BuildContext context) {
  final resolvedStyle = resolveDsSeparatorStyle(orientation: orientation)
      .merge(style);
  final isHorizontal = orientation == DsSeparatorOrientation.horizontal;
  final lengthFactor = length / 100;

  return FractionallySizedBox(
    widthFactor: isHorizontal ? lengthFactor : null,
    heightFactor: isHorizontal ? null : lengthFactor,
    child: RemixDivider(style: resolvedStyle, styleSpec: styleSpec),
  );
}
```

Same `FractionallySizedBox` wrapper the legacy widget uses for `length`,
now wrapping `RemixDivider` instead of a raw `ColoredBox` — `RemixDivider`
has no `length`/percentage concept of its own, so this DS still owns that
part of the layout.

## Style resolver (`separator_2_style_resolver.dart`)

```dart
part of 'separator_2.dart';

RemixDividerStyle resolveDsSeparatorStyle({
  required DsSeparatorOrientation orientation,
}) {
  final base = RemixDividerStyle().color($borderDefault());

  return orientation == DsSeparatorOrientation.horizontal
      ? base.thickness(1)
      : base.constraints(BoxConstraintsMix(minWidth: 1, maxWidth: 1));
}
```

Notes:

- `$borderDefault()` replaces the legacy widget's
  `AppTokens.of(context).colors.border.base` — same semantic color, now
  sourced from this DS's Mix token set, matching every other `_2`
  resolver's token usage.
- `horizontal` uses `RemixDividerStyle.thickness()` directly — it already
  targets `minHeight`/`maxHeight`, which is exactly the cross-axis
  constraint a horizontal hairline needs.
- `vertical` cannot use `.thickness()` (it only ever writes to
  height/never width, per `RemixDividerStyle`'s own doc comment), so it
  calls `.constraints()` directly to fix `minWidth`/`maxWidth` to the same
  1px hairline instead. The long axis (height) is left unconstrained here,
  same as the legacy widget's `SizedBox(height: null)` — it's driven by
  `FractionallySizedBox.heightFactor` in `build()`.
- No variant × state matrix (no `disabled`, no visual variant axis), so a
  single resolver function keyed only on `orientation` — same "no
  `resolveX`/`_variantBaseStyle`/`sizeStyle`/`stateStyle` split needed"
  reasoning `skeleton_2`'s resolver spec gives.

## Catalog registration

Add `example/lib/catalog/specs/separator_2_showcase_spec.dart`. No variant
or size axis, so `variantsBuilder`/`sizesBuilder` are omitted — only
`statesBuilder`, same no-variant shape `skeleton_2_showcase_spec.dart`
uses:

- `statesBuilder`: a horizontal separator between two lines of text (full
  width), a horizontal separator with a shorter `length` (e.g. 50), and a
  vertical separator (wrapped in a fixed-height `SizedBox`, sized between
  two inline items in a `Row`) — covering both `orientation` values and
  the `length` percentage.

Register `'Separator 2': buildSeparator2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`separator_2/separator_2.dart` + `separator_2/separator_2_orientation.dart`
from `lib/ui.dart` in place of the currently-commented-out
`separator`/`separator_orientation` exports.

## Out of scope

- A `thickness`/size enum beyond the fixed 1px hairline — the legacy
  widget has no such axis (`_resolveThickness()` is a hard-coded `1`), and
  nothing in this migration calls for one. Callers needing a thicker line
  can already reach it via the `style` escape hatch
  (`RemixDividerStyle().thickness(...)`/`.constraints(...)`).
- Fortal's `FortalDividerSize`/`FortalDivider` — this DS ports styling
  from Remix's primitives onto its own semantic tokens directly, same as
  every other `_2` component; `FortalDivider`'s size ramp and
  `FortalTokens` coloring aren't used.
</content>
