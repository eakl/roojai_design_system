# `slider_2` (`DsSlider`) design

## Context

Continues the `_2` migration onto `remix`/`mix`, following the pattern
established by `button_2` (`DsButton`/`RemixButton`), `input_2`
(`DsInput`/`RemixTextField`), and `switch_2` (`DsSwitch`/`RemixSwitch`). This
spec covers `slider_2` (`DsSlider`), a thin wrapper around Remix's
`RemixSlider` (https://docs.page/btwld/remix/components/slider), replacing
the legacy hand-rolled `AppSlider` (`lib/src/components/slider/slider.dart`).

The legacy `AppSlider` is a single-look continuous drag control built from
`GestureDetector` + `Stack` (no divisions/steps, no visual variants). Remix's
`RemixSlider` covers the same continuous-drag shape via `NakedSlider`, plus
adds optional interaction-only step snapping (`snapDivisions`) that
`AppSlider` never had. `slider_2` keeps `AppSlider`'s single-style, no-variant
character but picks up `snapDivisions` as new (opt-in) functionality.

## File structure

Mirrors `button_2`/`input_2`/`switch_2`:

```
lib/src/components/slider_2/
  slider_2.dart                 — DsSlider widget + doc comments
  slider_2_style_resolver.dart  — part of slider_2.dart; resolveDsSliderStyle()
  slider_2_variants.dart        — DsSliderSize enum
```

No loading-spinner part file (not applicable), no variants-of-look file
beyond size — same reasoning as `input_2`/`switch_2`.

## `DsSliderSize` (`slider_2_variants.dart`)

```dart
enum DsSliderSize { sm, md, lg }
```

Matches the sizing convention already used by `DsButtonSize`/`DsInputSize`/
`DsSwitchSize`. There is no `DsSliderVariant` enum: like `DsInput`/`DsSwitch`,
`AppSlider` had exactly one visual treatment (track/fill/thumb), varying only
by state (enabled/disabled) — `slider_2` keeps that. Remix's own
`FortalSliderVariant.surface/soft` axis has no legacy precedent to preserve
and is out of scope.

## `DsSlider` widget API

```dart
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
    this.style = const RemixSliderStyle.create(),
    this.styleSpec,
  });
}
```

- A thin wrapper delegating to `RemixSlider` for all drag/tap/focus mechanics
  and value-to-pixel positioning — the same relationship `DsButton` has to
  `RemixButton`. Widget-level props are a curated subset of `RemixSlider`'s
  (min/max/value/onChanged family, size, enabled, haptics, snapping, focus);
  `style`/`styleSpec` are the escape hatch for the rest, same as
  `DsButton`/`DsInput`.
- `value`/`onChanged` are required, mirroring `AppSlider`'s fully-controlled
  convention (no internal value state) and `RemixSlider`'s own required
  params.
- `enabled` is an explicit bool, never inferred — same convention as
  `AppSlider.disabled` (inverted to match this DS's `enabled`-flag convention
  used by `DsButton`/`DsInput`).
- `snapDivisions` passes straight through to `RemixSlider.snapDivisions` —
  new, opt-in functionality `AppSlider` never had (interaction-only step
  snapping, no visual tick marks per Remix's own doc comment).
- No `semanticLabel`/`semanticHint`: `RemixSlider` doesn't expose those
  (`NakedSlider` handles semantics internally per its own source comment), so
  there's nothing for `DsSlider` to forward.
- No `width` param (unlike `AppSlider.width`) — `RemixSlider` sizes itself
  from its parent's constraints via `LayoutBuilder`, so callers control width
  the normal Flutter way (wrap in `SizedBox`/`Expanded`), matching how
  `DsInput`/`DsButton` don't take an explicit width either.

## Style resolver (`slider_2_style_resolver.dart`)

One `resolveDsSliderStyle({required DsSliderSize size, required bool
disabled})` entry point, composing fragments merged in order — base, then
size, then disabled state — mirroring `resolveDsSwitchStyle`'s base → size →
state composition (no variant fragment, same reasoning as that resolver).

```dart
RemixSliderStyle resolveDsSliderStyle({
  required DsSliderSize size,
  required bool disabled,
}) {
  final baseStyle = RemixSliderStyle()
      .trackColor($surfaceAlternative())
      .rangeColor($accentUi())
      .thumb(
        BoxStyler()
            .color($surfaceDefault())
            .shapeCircle(
              side: BorderSideMix()
                  .color($borderStrong())
                  .strokeAlign(BorderSide.strokeAlignOutside),
            ),
      );

  final sizeStyle = switch (size) {
    DsSliderSize.sm => RemixSliderStyle(
        thumb: BoxStyler().size(14, 14),
        trackWidth: 3,
        rangeWidth: 3,
      ),
    DsSliderSize.md => RemixSliderStyle(
        thumb: BoxStyler().size(18, 18),
        trackWidth: 4,
        rangeWidth: 4,
      ),
    DsSliderSize.lg => RemixSliderStyle(
        thumb: BoxStyler().size(22, 22),
        trackWidth: 5,
        rangeWidth: 5,
      ),
  };

  final stateStyle = disabled
      ? RemixSliderStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSliderStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

Notes:

- Track color (`$surfaceAlternative`) and thumb ring treatment (white fill,
  bordered circle) are a direct port of legacy `AppSlider`'s
  `_resolveTrackColor`/`_resolveThumbRingColor` (`colors.surface.alternative`
  → `$surfaceAlternative`, `colors.surface.base` → `$surfaceDefault` thumb
  fill, ring border color mapped to `$borderStrong`).
- Range/fill color is **`$accentUi()`**, not a direct port of legacy's
  `colors.surface.inverted` — the accent group gives the slider a distinct
  brand-colored fill (matching Fortal's own default look) rather than the
  neutral black/white fill every other `_2` component currently uses. This is
  a deliberate divergence, confirmed during design.
- Disabled state uses `.wrap(WidgetModifierConfig.opacity(0.5))` — the
  established `_2`-migration convention (`button_2`/`switch_2`), replacing
  legacy `AppSlider`'s separate muted-fill-color approach
  (`colors.content.placeholder`).
- `md` size values (18×18 thumb, 4px track/range) match legacy `AppSlider`'s
  only size (`thumbDiameter: 18`, `trackHeight: 4`) exactly, so the default
  size renders identically to the widget it replaces. `sm`/`lg` scale down/up
  from there, matching the proportional scaling `switch_2` used for its own
  three sizes.
- No border radius set on track/range — `RemixSlider`'s track painter always
  draws round-capped strokes (`Paint()..strokeCap = .round`), so there's no
  separate radius knob to set, unlike `DsButton`/`DsInput`'s
  `.borderRadiusAll()`.

## Catalog registration

Add `example/lib/catalog/specs/slider_2_showcase_spec.dart`, mirroring
`input_2_showcase_spec.dart`:

- `sizesBuilder`: one `DsSlider` per `DsSliderSize`, static mid-range `value`.
- `statesBuilder`: `enabled` (value at 25%), `enabled` (value at 75%),
  `disabled`, `min value`, `max value`, `with snapDivisions` (e.g. 4 steps).
- No `variantsBuilder` — there is no variant axis.
- Drag/focus-visible states are transient and Naked-driven; verified
  interactively in the running catalog app, same caveat noted in the
  button/input specs.

Register the new spec in `example/lib/catalog/component_registry.dart`, and
export `slider_2/slider_2.dart` + `slider_2/slider_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`input_2`.

## Out of scope

- `DsSliderVariant` visual-skin enum — no precedent from legacy `AppSlider`;
  single style only for now (matches `input_2`/`switch_2`'s decision).
- Visual tick marks for `snapDivisions` — Remix's own `RemixSlider` doesn't
  render any (interaction-only snapping), so `slider_2` doesn't either.
- Vertical orientation — `RemixSlider` hardcodes `direction: .horizontal`
  internally; not exposed as a `DsSlider` param.
- `width` param — callers size the slider via normal Flutter layout, per
  the widget API section above.
