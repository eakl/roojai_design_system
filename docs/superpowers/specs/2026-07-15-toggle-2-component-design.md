# `toggle_2` (`DsToggle`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`),
`input_2` (`DsInput` wrapping `RemixTextField`), and `switch_2` (`DsSwitch`
wrapping `RemixSwitch`). This spec covers `toggle_2` (`DsToggle`), a thin
wrapper around Remix's `RemixToggle`, replacing the legacy hand-rolled
`Toggle` widget (`lib/src/components/toggle/toggle.dart`, a `GestureDetector`
+ `AnimatedContainer` two-state pressable button).

`RemixToggle` docs (https://docs.page/btwld/remix/components/toggle):
"a pressable toggle button that stays visually active when selected" — for
formatting controls (bold/italic in a toolbar), filter chips, and tool-state
representation. Distinct from `RemixSwitch`: no sliding track, the whole
button itself is the affordance.

## File structure

Mirrors `switch_2`:

```
lib/src/components/toggle_2/
  toggle_2.dart                 — DsToggle widget + doc comments
  toggle_2_style_resolver.dart  — part of toggle_2.dart; resolveDsToggleStyle()
  toggle_2_variants.dart        — DsToggleVariant, DsToggleSize enums
```

No loading-spinner part file — same reasoning as `switch_2`/`input_2`, no
async "loading" concept for a toggle.

## `toggle_2_variants.dart`

```dart
enum DsToggleVariant { ghost, outline }

enum DsToggleSize { sm, md, lg }
```

- `DsToggleVariant` names match Remix's own `FortalToggleVariant` vocabulary
  directly (`ghost`, `outline`), rather than the legacy `Toggle`'s
  `standard`/`outline` naming — consistent with how `switch_2` pulls Remix
  vocabulary straight through (e.g. `RemixSwitchStyle.onSelected`). `ghost`
  is the default, matching `FortalToggleStyles.create`'s own default.
- `DsToggleSize` uses the `sm`/`md`/`lg` names every other `_2` component
  uses (`DsButtonSize`, `DsSwitchSize`), not Remix's own
  `FortalToggleSize.size1/2/3` — those map internally in the resolver
  (`sm`→`size1`, `md`→`size2`, `lg`→`size3`).

## `DsToggle` widget API

```dart
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
    this.style = const RemixToggleStyle.create(),
    this.styleSpec,
  }) : assert(
         label != null || icon != null,
         'At least one of label or icon must be provided',
       );
}
```

- A thin wrapper delegating to `RemixToggle` for all interaction handling
  (tap gesture, hover/press/focus, semantics), same relationship `DsSwitch`
  has to `RemixSwitch`.
- `selected` is the public on/off state — always explicit, never inferred,
  same convention as `DsSwitch.selected`. Named `selected`, not `pressed`
  (the legacy `Toggle`'s name), to match `RemixToggle`'s own parameter name.
- `onChanged` is `ValueChanged<bool>?` — **nullable**, unlike
  `RemixToggle.onChanged` (required non-null). Same fold-in pattern as
  `DsSwitch`:

  ```dart
  bool get _isEnabled => enabled && onChanged != null;
  ```

  passed through as `enabled: _isEnabled` plus a non-null callback
  (`onChanged ?? (_) {}`, never invoked while `_isEnabled` is false).
- `label`/`icon`: both nullable, with Remix's own "at least one required"
  assert carried through verbatim. `icon` is a single `IconData?` — **not**
  a leading/trailing pair like the legacy `Toggle` — because `RemixToggle`
  itself only exposes one icon slot. Rendered via `RemixToggle`'s built-in
  `StyledIcon`; unlike `DsButton`, there's no icon-builder hook on
  `RemixToggle` to redirect rendering through this DS's own `Icon` widget,
  so none is added here.
- `enabled` is always explicit, never derived — same as `DsButton`/
  `DsSwitch`.
- `style`/`styleSpec` are the escape hatch for full customization, same
  pattern as the rest of the `_2` family.

## Style resolver (`toggle_2_style_resolver.dart`)

One `resolveDsToggleStyle({required DsToggleVariant variant, required
DsToggleSize size, required bool disabled})` entry point, composing
fragments merged in order — size, then variant, then state:

```dart
RemixToggleStyle resolveDsToggleStyle({
  required DsToggleVariant variant,
  required DsToggleSize size,
  required bool disabled,
}) {
  final sizeStyle = switch (size) {
    DsToggleSize.sm => FortalToggleStyles.base(size: FortalToggleSize.size1),
    DsToggleSize.md => FortalToggleStyles.base(size: FortalToggleSize.size2),
    DsToggleSize.lg => FortalToggleStyles.base(size: FortalToggleSize.size3),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsToggleVariant.ghost => RemixToggleStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand()),
        ),
    DsToggleVariant.outline => RemixToggleStyle()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand())
              .borderAll(color: $surfaceInverted()),
        ),
  };

  final stateStyle = disabled
      ? RemixToggleStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixToggleStyle();

  return sizeStyle.merge(variantStyle).merge(stateStyle);
}
```

Notes:

- `FortalToggleStyles.base(size: ...)` (from
  `package:remix/src/components/toggle/fortal_toggle_styles.dart`) supplies
  container `mainAxisSize`, padding/spacing/radius/icon-size/label-fontSize
  per size step, plus a focus-ring `onFocused` fragment and a disabled
  `onDisabled` fragment — reused as-is rather than re-derived, since it's
  pure layout/metrics with no DS-specific color baked in. This DS's own
  `variantStyle`/`stateStyle` fragments, merged after, override colors with
  semantic tokens.
- Selected color reuses the same `$surfaceInverted`/`$contentOnBrand` pair
  `DsButton.primary` and `DsSwitch`'s on-track color use, for visual
  continuity across the migrated `_2` family.
- Disabled dimming uses the same `.wrap(WidgetModifierConfig.opacity(0.5))`
  mechanism as `resolveDsButtonStyle`/`resolveDsSwitchStyle`, applied last so
  it always wins over variant/selected colors — same "disabled always wins"
  rule as those resolvers. `FortalToggleStyles.base`'s own `onDisabled`
  fragment (a grayed background/foreground swap) is superseded by this
  opacity wrap when `disabled` is true, since `stateStyle` merges in last.
- Animation: `RemixToggle`/`RemixToggleStyle` has no built-in transition set
  by `FortalToggleStyles`, so none is added here either — unlike
  `resolveDsButtonStyle`/`resolveDsSwitchStyle`, there's no legacy-`Toggle`
  precedent to match (the legacy widget's `AnimatedContainer` animated
  color/padding changes generically, not a deliberate design decision worth
  porting), and adding one isn't required by this spec's scope.

## Catalog registration

Add `example/lib/catalog/specs/toggle_2_showcase_spec.dart`, mirroring
`button_2_showcase_spec.dart`'s shape (this component has both a variant and
size axis, like `DsButton`, unlike `DsSwitch`):

- `variantsBuilder`: one `DsToggle` per `DsToggleVariant`, `label:
  variant.name`, `selected: false`, real `onChanged`.
- `sizesBuilder`: one `DsToggle` per `DsToggleSize`, `label: size.name`,
  `selected: false`.
- `statesBuilder`: `selected`, `unselected`, `disabled (selected)`,
  `disabled (unselected)`, `icon only`, `label + icon`. The `selected`
  entries use the same `_InteractiveToggle` stateful-wrapper pattern
  `switch_2_showcase_spec.dart` uses for `_InteractiveSwitch` (owns local
  `selected` state via `onChanged`, since `DsToggle` holds none itself) —
  a static `selected: true` prop would never visibly toggle on tap.
- Hover/press/focus states are transient and Naked-driven; verified
  interactively in the running catalog app, same caveat noted in the other
  `_2` specs.

Register `'Toggle 2': buildToggle2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`toggle_2/toggle_2.dart` + `toggle_2/toggle_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`switch_2`.

## Out of scope

- Migrating/removing the legacy `Toggle`/`toggle_group` widgets — out of
  scope for this spec, same as `button_2`/`input_2`/`switch_2` leaving their
  legacy counterparts in place during the migration.
- Leading/trailing icon pair — `RemixToggle` only exposes a single `icon`
  slot; `DsToggle` follows that shape rather than reintroducing the legacy
  `Toggle`'s `leading`/`trailing` pair.
- A `standard` variant alias for `ghost` — no precedent needed; `ghost` is
  used directly, matching Remix's own default.
