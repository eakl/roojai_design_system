# `label_2` (`DsLabel`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`) and
`input_2` (`DsInput` wrapping `RemixTextField`). This spec covers `label_2`
(`DsLabel`), the DS-2 replacement for the legacy hand-rolled `Label` widget —
a small, low-emphasis caption that sits above/beside a form field.

Unlike `button_2`/`input_2`, there is no Remix widget to wrap: Remix only
ships a `label_style_mixin.dart` used internally by other components (e.g.
`RemixTextField`'s own label slot), not a standalone `Label`/`Text` widget.
`label_2` is therefore built the way `icon_2` was — a plain `StatelessWidget`
rendering through Mix's `StyledText`/`TextStyler` primitives and the design
system's `light/*.dart` token set, rather than delegating interaction/state
handling to a wrapped Remix component. It keeps the same shape as the legacy
`Label` (text + `required` + `disabled` modifiers) and adds one new axis,
`DsLabelSize`, so it can visually pair with `DsInputSize`/`DsButtonSize`.

## File structure

Mirrors `icon_2` (closest precedent for a non-Remix-wrapping `_2` component):

```
lib/src/components/label_2/
  label_2.dart                 — DsLabel widget + doc comments
  label_2_style_resolver.dart  — part of label_2.dart; resolveDsLabelStyle()
  label_2_variants.dart        — DsLabelSize enum
```

## `DsLabelSize` (`label_2_variants.dart`)

```dart
enum DsLabelSize { sm, md, lg }
```

New relative to legacy `Label`, which intentionally had no size axis (always
rendered at a single fixed `labelMd` scale). `label_2` adds `DsLabelSize` so
a label can be sized to match the `DsInputSize`/`DsButtonSize` of the field
it's paired with, using the existing `$labelSm`/`$labelMd`/`$labelLg`
typography tokens (already defined in `theme/light/typography.dart`). `md`
is the default, preserving legacy `Label`'s visual size out of the box.

## `DsLabel` widget API

```dart
class DsLabel extends StatelessWidget {
  const DsLabel({
    super.key,
    required this.text,
    this.size = DsLabelSize.md,
    this.required = false,
    this.disabled = false,
  });

  final String text;
  final DsLabelSize size;
  final bool required;
  final bool disabled;
}
```

- `text` — always shown, same as legacy.
- `size` — new axis (see above), drives the text style token only; no
  layout/padding differences beyond the font's own metrics.
- `required` — when true, appends a `*` after `text` in the
  negative/error color (universal "field must be filled in" marker), same
  convention as legacy `Label.required`.
- `disabled` — mutes both `text` and the `*` marker to the placeholder
  color, matching a disabled sibling field. Always explicit, never
  inferred from a "peer" — same rule legacy `Label` documents (this
  package has no CSS-`peer-disabled`-style mechanism, and disabled is
  never inferred elsewhere in the DS either).

No `style`/`styleSpec` escape hatch: unlike `button_2`/`input_2`, `DsLabel`
doesn't wrap a Remix widget with its own `Styler` type, so there's no
natural merge target. If a future need arises for one, it can be added
following the same `TextStyler`/`.merge()` pattern `icon_2` uses.

## Rendering

Built as a `Row` (`mainAxisSize: MainAxisSize.min`) containing:
1. `StyledText(text, style: resolvedTextStyle)`
2. When `required`: `SizedBox(width: $spacing002())` + `StyledText('*', style: resolvedMarkerStyle)`

Same two-span shape as legacy `Label` (a `Text` + conditional `*` `Text` in
a `Row`), swapped from `Text`/`AppTokens` onto Mix's `StyledText`/
`TextStyler`, matching how `icon_2` renders through `StyledIcon` instead of
a raw `Icon` widget.

## Style resolver (`label_2_style_resolver.dart`)

One `resolveDsLabelStyle({required DsLabelSize size, required bool disabled})`
entry point returning a record of two `TextStyler`s (text, marker),
composed base → size → disabled per style, mirroring `resolveDsIconStyle`'s
base → variant → size merge:

```dart
({TextStyler text, TextStyler marker}) resolveDsLabelStyle({
  required DsLabelSize size,
  required bool disabled,
}) {
  final sizeToken = switch (size) {
    DsLabelSize.sm => $labelSm.mix(),
    DsLabelSize.md => $labelMd.mix(),
    DsLabelSize.lg => $labelLg.mix(),
  };

  final textColor = disabled ? $contentPlaceholder() : $contentPrimary();
  final markerColor = disabled ? $contentPlaceholder() : $negativeText();

  return (
    text: TextStyler().style(sizeToken).color(textColor),
    marker: TextStyler().style(sizeToken).color(markerColor),
  );
}
```

Token mapping carried over 1:1 from the legacy resolver
(`colors.content.primary` → `$contentPrimary`, `colors.content.placeholder`
→ `$contentPlaceholder`, `colors.negative.text` → `$negativeText`), just
re-pointed at the `_2` Mix token set and parameterized by the new `size`
axis on top.

`TextStyleToken` (`$labelSm`/`$labelMd`/`$labelLg`) needs `.mix()`, not a
bare call — its plain `call()` returns a `TextStyleRef` for raw `TextStyle`
contexts, while `TextStyler.style()` takes a `TextStyleMix`, which is what
`.mix()` returns (confirmed in `mix`'s `TextStyleToken` source). `ColorToken`
doesn't need this distinction — its `call()` result is directly usable
wherever a `Color` is expected, which is why `resolveDsIconStyle` calls
`$neutralText()` straight into `.color()`.

## Catalog registration

Add `example/lib/catalog/specs/label_2_showcase_spec.dart`, mirroring
`input_2_showcase_spec.dart`:

- `sizesBuilder`: one `DsLabel` per `DsLabelSize`, static `text: size.name`.
- `statesBuilder`: `default`, `required`, `disabled`, `required + disabled`.
- No `variantsBuilder` — there is no variant axis.
- No interactive/transient states to call out (unlike `input_2`'s
  focus/hover caveat) — `DsLabel` is a static, non-interactive caption.

Register the new spec in `example/lib/catalog/component_registry.dart`, and
export `label_2/label_2.dart` + `label_2/label_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`input_2`.

## Out of scope

- `DsLabelVariant` visual-skin enum — no precedent from legacy `Label`;
  single style only, matching `input_2`'s "no variant axis" precedent.
- Any click/focus/interaction handling — `DsLabel` is a static caption, not
  a control; same as legacy `Label`.
- `style`/`styleSpec` escape hatch — see API section above.
