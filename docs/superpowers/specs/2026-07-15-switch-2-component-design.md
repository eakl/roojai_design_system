# `switch_2` (`DsSwitch`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`) and
`input_2` (`DsInput` wrapping `RemixTextField`). This spec covers `switch_2`
(`DsSwitch`), a thin wrapper around Remix's `RemixSwitch`, replacing the
legacy hand-rolled `AppSwitch` widget (`lib/src/components/switch/switch.dart`,
a `GestureDetector` + `AnimatedContainer`/`AnimatedAlign` binary on/off
control).

## File structure

Mirrors `button_2`/`input_2`:

```
lib/src/components/switch_2/
  switch_2.dart                 — DsSwitch widget + doc comments
  switch_2_style_resolver.dart  — part of switch_2.dart; resolveDsSwitchStyle()
  switch_2_variants.dart        — DsSwitchSize enum
```

No loading-spinner part file (no async "loading" concept for a switch, same
reasoning as `input_2`).

## `DsSwitchSize` (`switch_2_variants.dart`)

```dart
enum DsSwitchSize { sm, md, lg }
```

Matches `DsButtonSize`/`DsInputSize`. The legacy `AppSwitch` had a single
fixed size (40×24 track, 20 thumb, 2px inset); that becomes the `md` default
here, with `sm`/`lg` added for consistency with the rest of the `_2` family.

There is no `DsSwitchVariant` enum: like `DsInput`, the legacy `AppSwitch` had
only one visual look (on/off track color + optional disabled dimming), so
`switch_2` keeps that — single style, states only.

## `DsSwitch` widget API

```dart
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
}
```

- A thin wrapper delegating to `RemixSwitch` for all interaction handling
  (toggle gesture, hover/press/focus, semantics), same relationship `DsButton`
  has to `RemixButton`.
- `selected` is the public on/off state — always explicit, never inferred,
  same convention as legacy `AppSwitch.value` and `DsButton`'s
  loading/enabled flags. (Named `selected`, not `value`, to match
  `RemixSwitch`'s own parameter name.)
- `onChanged` is `ValueChanged<bool>?` — **nullable**, unlike
  `RemixSwitch.onChanged` (which is required non-null). This mirrors
  `DsButton.onPressed`'s contract: "ignored, and the widget rendered
  non-interactive, when null." Since `RemixSwitch` itself requires a non-null
  callback, `DsSwitch.build()` computes effective interactivity itself:

  ```dart
  bool get _isEnabled => enabled && onChanged != null;
  ```

  and passes `enabled: _isEnabled` plus a non-null callback
  (`onChanged ?? (_) {}`, never invoked while `_isEnabled` is false because
  `RemixSwitch`/`NakedToggle` gates on its own `enabled` flag) through to
  `RemixSwitch`.
- `enabled` is likewise always explicit, never derived — same as
  `DsButton`/`DsInput`.
- No `leadingIcon`/`trailingIcon`-style props, no `label` — a switch has no
  content slots in Remix's `RemixSwitch`; any adjacent label is the caller's
  responsibility to compose (e.g. `Row([DsSwitch(...), Text(...)])`), same as
  the legacy `AppSwitch`.
- `style`/`styleSpec` are the escape hatch for full customization, same
  pattern as `DsButton`/`DsInput`.

## Style resolver (`switch_2_style_resolver.dart`)

One `resolveDsSwitchStyle({required DsSwitchSize size, required bool
disabled})` entry point, composing fragments merged in order — base, then
size, then state — mirroring `resolveDsButtonStyle`'s composition (minus the
variant fragment, since there is no variant axis here, same as
`resolveDsInputStyle`).

```dart
RemixSwitchStyle resolveDsSwitchStyle({
  required DsSwitchSize size,
  required bool disabled,
}) {
  final baseStyle = RemixSwitchStyle()
      .trackColor($borderStrong())
      .thumbColor($surfaceDefault())
      .borderRadiusAll($radiusFull())
      .thumb(BoxStyler().borderRadiusAll($radiusFull()))
      .onSelected(RemixSwitchStyle().trackColor($surfaceInverted()))
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  final sizeStyle = switch (size) {
    DsSwitchSize.sm => RemixSwitchStyle(
        container: BoxStyler()
            .width(32)
            .height(18)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(14, 14),
      ),
    DsSwitchSize.md => RemixSwitchStyle(
        container: BoxStyler()
            .width(40)
            .height(24)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(20, 20),
      ),
    DsSwitchSize.lg => RemixSwitchStyle(
        container: BoxStyler()
            .width(48)
            .height(28)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(24, 24),
      ),
  };

  final stateStyle = disabled
      ? RemixSwitchStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSwitchStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

Notes:

- On/off track color uses Remix's own `.onSelected()` state-variant helper
  (from `SelectedWidgetStateVariantMixin`, which `RemixSwitchStyle` mixes in
  directly — confirmed in Remix's own `fortal_switch_styles.dart`), not a
  hand-tracked bool branch like the legacy resolver's
  `_resolveTrackColor(colors, value, disabled)`.
- Disabled dimming uses a single `.wrap(WidgetModifierConfig.opacity(0.5))`
  over the whole switch — same mechanism `resolveDsButtonStyle` uses for
  disabled — replacing the legacy resolver's two separate
  `withOpacity(0.4)`/`withOpacity(0.8)` calls on track/thumb individually.
  Disabled wins over selected regardless of merge order here, since it's
  applied as the last-merged fragment (same "disabled always wins" comment
  as `resolveDsButtonStyle`'s `stateStyle`).
- Color tokens mirror the legacy resolver's mapping (`colors.surface.inverted`
  on-color → `$surfaceInverted`, `colors.border.strong` off-color →
  `$borderStrong`, `colors.surface.base` thumb → `$surfaceDefault`),
  translated to the new semantic token set — same "on" token `DsButton`'s
  `primary` variant uses, for visual continuity between the two migrated
  components.
- Track/thumb radius uses `$radiusFull` (new semantic radius token), replacing
  the legacy resolver's `AppRadius.radiusFull` primitive.
- `RemixSwitch`'s own `_buildStyle()` already sets `alignment(.centerLeft)` /
  `.onSelected(alignment(.centerRight))` to slide the thumb — the resolver
  here doesn't need to touch alignment at all, only track/thumb sizing,
  color, and radius.
- Animation duration/curve mirrors `resolveDsButtonStyle`'s 100ms
  `Curves.easeInOut` literal (same Mix token-reference limitation noted
  there — motion tokens aren't resolvable inline yet).

## Catalog registration

Add `example/lib/catalog/specs/switch_2_showcase_spec.dart`, mirroring
`button_2_showcase_spec.dart`/`input_2_showcase_spec.dart`:

- `sizesBuilder`: one `DsSwitch` per `DsSwitchSize`, all `selected: true`.
- `statesBuilder`: `on`, `off`, `disabled (on)`, `disabled (off)`.
- No `variantsBuilder` — there is no variant axis.
- Hover/press/focus states are transient and Naked-driven; verified
  interactively in the running catalog app, same caveat noted in the button
  and input specs.

Register the new spec in `example/lib/catalog/component_registry.dart`, and
export `switch_2/switch_2.dart` + `switch_2/switch_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`input_2`.

## Out of scope

- `DsSwitchVariant` visual-skin enum — no precedent from legacy `AppSwitch`;
  single style only for now, same decision `input_2` made.
- Label/description slots — composition is the caller's responsibility, same
  as legacy `AppSwitch`.
- Migrating/removing the legacy `AppSwitch` — out of scope for this spec,
  same as `button_2`/`input_2` leaving their legacy counterparts in place
  during the migration.
